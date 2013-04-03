//
//  TKDMuxrManager.m
//  Tokaido
//
//  Created by Patrick B. Gibson on 4/3/13.
//  Copyright (c) 2013 Tilde. All rights reserved.
//

#import "TKDMuxrManager.h"

#include <sys/socket.h>
#include <sys/un.h>

@implementation TKDMuxrManager

+ (id)defaultManager
{
    static dispatch_once_t once;
    static TKDMuxrManager *defaultManager;
    dispatch_once(&once, ^ { defaultManager = [[self alloc] init]; });
    return defaultManager;
}


- (BOOL)setupSocket
{
    // Prepare the file for reading.
    int fd = socket(AF_UNIX, SOCK_STREAM, 0);
    if (fd == -1) {
        NSLog(@"Could not open socket.");
        return NO;
    }
    fcntl(fd, F_SETFL, O_NONBLOCK);  // Avoid blocking the read operation
    
    struct sockaddr_un addr;
    char *socket_path = "/tmp/tokaido.sock";
    
    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    strncpy(addr.sun_path, socket_path, sizeof(addr.sun_path)-1);
    
    if (connect(fd, (struct sockaddr*)&addr, sizeof(addr)) == -1) {
        NSLog(@"ERROR: Could not connect to the Tokaido service.");
#warning Need a better way to communicate this to the user
        return NO;
    }
    
    // Set up our dispatch source
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t readSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, fd, 0, queue);
    if (!readSource) {
        close(fd);
        return NO;
    }
    
    // Install the event handler
    dispatch_source_set_event_handler(readSource, ^{
        size_t estimated = dispatch_source_get_data(readSource) + 1;
        
        // Read the data into a text buffer.
        char* buffer = (char*) malloc(estimated);
        if (buffer) {
            
            read(fd, buffer, (estimated));
            [self processMuxrLine:buffer];
            
            // Release the buffer when done.
            free(buffer);
            
//            // If there is no more data, cancel the source.
//            if (done)
//                dispatch_source_cancel(readSource);
        }
    });
    
    // Install the cancellation handler
    dispatch_source_set_cancel_handler(readSource, ^{
        close(fd);
    });
    
    // Start reading the socket.
    dispatch_resume(readSource);
    return YES;
}

- (void)processMuxrLine:(char *)buffer
{
    NSString *muxrLine = [NSString stringWithUTF8String:buffer];
    NSLog(@"Got muxrLine: %@", muxrLine);
    
    // This happens on a background thread, so it should fire off UI updating notifications on
    // the main thread.
}

@end
