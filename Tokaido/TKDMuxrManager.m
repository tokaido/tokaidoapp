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

#import "TKDAppDelegate.h"

NSString * const kMuxrNotification = @"kMuxrNotification";

@interface TKDMuxrManager ()
@property (nonatomic, strong) NSMapTable *socketsToReadData;
@property (nonatomic, assign) int openSocket;
@property (nonatomic, assign) int writeSocket;
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
    self.openSocket = [self openNewSocket];
    [self readFromSocket:self.openSocket];
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
    NSString *socketPath = [TKDAppDelegate tokaidoMuxrSocketPath];
    const char *cSocketPath = [socketPath UTF8String];
    
    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    strncpy(addr.sun_path, cSocketPath, sizeof(addr.sun_path)-1);
    
    if (connect(fd, (struct sockaddr*)&addr, sizeof(addr)) == -1) {
        NSLog(@"ERROR: Could not connect to the Tokaido service.");
        return NULL;
    }
    
    return fd;
}

- (BOOL)readFromSocket:(int)fd
{
    // Set up our dispatch source
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t readSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, fd, 0, queue);
    if (!readSource) {
        close(fd);
        NSLog(@"ERROR: Couldn't create a read source for socket");
        return NO;
    }
    
    // Install the event handler
    dispatch_source_set_event_handler(readSource, ^{
        size_t estimated = dispatch_source_get_data(readSource) + 1;
        NSLog(@"size to read: %ld", estimated);
        
        if (estimated == 1) {
            NSLog(@"No more data to read.");
            dispatch_source_cancel(readSource);
            [self readFromSocket:fd];
            return;
        }

        // Read the data into a text buffer.
        char* buffer = (char*) malloc(estimated);
        memset(buffer, 0, estimated);
        if (buffer) {
            
            read(fd, buffer, estimated);
            NSLog(@"Read line from muxr: %s", buffer);

            NSString *muxrLine = [NSString stringWithUTF8String:buffer];
            NSLog(@"Got muxrLine: %@", muxrLine);
            if (!muxrLine) {
                NSLog(@"Unprocessable line. Failing.");
                return;
            }
            
            [self processMuxrLine:muxrLine];
            
            // Release the buffer when done.
            free(buffer);
            
//            dispatch_source_cancel(readSource);
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
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t writeSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_WRITE, fd, 0, queue);
    if (!writeSource) {
        close(fd);
        NSLog(@"ERROR: Couldn't open socket for writing.");
        return NO;
    }
    
    dispatch_source_set_event_handler(writeSource, ^{
        size_t bufferSize = [command lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        
        // This assumes we don't need to buffer our data
        NSLog(@"Writing command to muxr: %@", command);
        write(fd, [command UTF8String], bufferSize);
        
        dispatch_source_cancel(writeSource);
    });
    
    dispatch_resume(writeSource);
    return YES;
}

- (void)addApp:(TKDApp *)app;
{
    NSString *command = [NSString stringWithFormat:@"ADD \"%@\" \"%@\"\n", app.appDirectoryPath, app.appHostname];
    [self issueCommand:command];
}

- (void)removeApp:(TKDApp *)app;
{
    NSString *command = [NSString stringWithFormat:@"REMOVE \"%@\"\n", app.appHostname];
    [self issueCommand:command];
}

- (void)issueCommand:(NSString *)command
{
    // Create a new socket to muxr
//    int socket = [self openNewSocket];
    
    // Write out our socket command
    [self writeCommand:command toSocket:self.openSocket];
    
    // Setup a new reading buffer for that socket
//    [self readFromSocket:socket];
    
    // When our response is returned and finished reading, it will be called automatically.
}


- (void)processMuxrLine:(NSString *)muxrLine
{    
    // This happens on a background thread, so it should fire off UI updating notifications on
    // the main thread.
    
    NSArray *elements = [muxrLine componentsSeparatedByString:@" "];
    
    if ([elements count] < 2) {
        return;
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSDictionary *userInfo = @{@"action": [elements objectAtIndex:0],
                                   @"hostname": [elements objectAtIndex:1]};
        NSNotification *muxrNotification = [NSNotification notificationWithName:kMuxrNotification
                                                                         object:nil
                                                                       userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotification:muxrNotification];
    });
}

@end
