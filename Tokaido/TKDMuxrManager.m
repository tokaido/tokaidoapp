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

@interface TKDMuxrManager ()
@property (nonatomic, strong) NSMapTable *socketsToReadData;
@end

@implementation TKDMuxrManager

+ (id)defaultManager
{
    static dispatch_once_t once;
    static TKDMuxrManager *defaultManager;
    dispatch_once(&once, ^ {
        defaultManager = [[self alloc] init];
        [defaultManager setup];
    });
    return defaultManager;
}

- (void)setup
{
    self.socketsToReadData = [NSMapTable strongToStrongObjectsMapTable];
}

- (int)openNewSocket
{

    // Just open a socket
    int fd = socket(AF_UNIX, SOCK_STREAM, 0);
    if (fd == -1) {
        NSLog(@"Could not open socket.");
        return NULL;
    }
    
    struct sockaddr_un addr;
    char *socket_path = "/tmp/tokaido.sock";
    
    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    strncpy(addr.sun_path, socket_path, sizeof(addr.sun_path)-1);
    
    if (connect(fd, (struct sockaddr*)&addr, sizeof(addr)) == -1) {
        NSLog(@"ERROR: Could not connect to the Tokaido service.");
#warning Need a better way to communicate this to the user
        return NULL;
    }
    
    return fd;
}

- (BOOL)readFromSocket:(int)fd
{
    fcntl(fd, F_SETFL, O_NONBLOCK);  // Avoid blocking the read operation

    // Set up our dispatch source
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t readSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, fd, 0, queue);
    if (!readSource) {
//        close(fd);
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


- (BOOL)writeCommand:(NSString *)command toSocket:(int)fd
{
    fcntl(fd, F_SETFL); // Block during the write.
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t writeSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_WRITE, fd, 0, queue);
    if (!writeSource) {
        close(fd);
        return NO;
    }
    
    dispatch_source_set_event_handler(writeSource, ^{
        size_t bufferSize = [command lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        
        // This assumes we don't need to buffer our data
        write(fd, [command UTF8String], bufferSize);
        
        
        // Cancel and release the dispatch source when done.
        dispatch_source_cancel(writeSource);
    });
    
    dispatch_source_set_cancel_handler(writeSource, ^{close(fd);});
    dispatch_resume(writeSource);
    return YES;
}

- (void)addApp:(TKDApp *)app;
{
    NSString *command = [NSString stringWithFormat:@"ADD \"%@\" \"%@\" 4930", app.appDirectoryPath, app.appHostname];
    [self issueCommand:command];
}

- (void)removeApp:(TKDApp *)app;
{
    NSString *command = [NSString stringWithFormat:@"REMOVE \"%@\"", app.appHostname];
    [self issueCommand:command];
}

- (void)issueCommand:(NSString *)command
{
    // Create a new socket to muxr
    int socket = [self openNewSocket];
    
    // Write out our socket command
    [self writeCommand:command toSocket:socket];
    
    // Setup a new reading buffer for that socket
    [self readFromSocket:socket];
    
    // When our response is returned and finished reading, it will be called automatically.
}


- (void)processMuxrLine:(char *)buffer
{
    NSString *muxrLine = [NSString stringWithUTF8String:buffer];
    NSLog(@"Got muxrLine: %@", muxrLine);
    
    // This happens on a background thread, so it should fire off UI updating notifications on
    // the main thread.
}

@end
