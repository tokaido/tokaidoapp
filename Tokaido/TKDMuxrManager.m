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
@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) dispatch_queue_t backgroundQueue;
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
    self.backgroundQueue = dispatch_queue_create("socketQueue", DISPATCH_QUEUE_SERIAL);
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.backgroundQueue];
    NSError *error = nil;
    NSURL *socketURL = [NSURL URLWithString:[TKDAppDelegate tokaidoMuxrSocketPath]];
    if (![self.socket connectToUrl:socketURL withTimeout:-1 error:&error]) {
        NSLog(@"ERROR: Couldn't connect to socket: %@", [error localizedDescription]);
    }
    [self.socket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag;
{
    NSString *muxrLine = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Got back from muxr: %@", muxrLine);

    
    if ([muxrLine isEqualToString:@"TOKAIDO ACTIVE\n"]) {
        NSLog(@"Muxr Manager Ready");
        return;
    }
    
    NSArray *elements = [muxrLine componentsSeparatedByString:@" "];
    NSString *reply = [elements objectAtIndex:0];
    
    if ([reply isEqualToString:@"ADDED"]) {
        NSLog(@"App added, waiting for ready...");
        [self.socket readDataWithTimeout:-1 tag:0];
    } else if ([reply isEqualToString:@"READY"] || [reply isEqualToString:@"REMOVED"]) {
        
        // This happens on a background thread, so it should fire off UI updating notifications on
        // the main thread.
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSDictionary *userInfo = @{@"action": [elements objectAtIndex:0],
                                       @"hostname": [elements objectAtIndex:1]};
            NSNotification *muxrNotification = [NSNotification notificationWithName:kMuxrNotification
                                                                             object:nil
                                                                           userInfo:userInfo];
            [[NSNotificationCenter defaultCenter] postNotification:muxrNotification];
        });
    } else {
        [self.socket readDataWithTimeout:-1 tag:0];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToUrl:(NSURL *)url;
{
  NSLog(@"Connected to %@", url);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error;
{
  NSLog(@"Closed connection: %@", error);
}

- (void)addApp:(TKDApp *)app;
{
    TKDAppDelegate *delegate = (TKDAppDelegate *)[[NSApplication sharedApplication] delegate];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        BOOL bundleInstallWorked = [delegate runBundleInstallForApp:app];

        if (bundleInstallWorked) {
            [app enterSubstate:TKDAppBootingStartingServer];
            NSString *command = [NSString stringWithFormat:@"ADD \"%@\" \"%@\"\n", app.appHostname, app.appDirectoryPath];
            [self issueCommand:command];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSAlert *alert = [NSAlert alertWithMessageText:@"Unable to activate app."
                                                 defaultButton:@"OK"
                                               alternateButton:nil
                                                   otherButton:nil
                                     informativeTextWithFormat:@"`bundle install` failed. Make sure it works before proceeding."];

                [app enterSubstate:TKDAppBootingBundleFailed];
                [alert runModal];
            });

            [self postMessage:@"FAILED" forApp:app];
        }
        
    });
}

// Post a failure message, which will put the app back in the off state
- (void)postMessage:(NSString *)message forApp:(TKDApp *)app;
{
    NSDictionary *userInfo = @{@"action": message,
                               @"hostname": app.appHostname};

    NSNotification *muxrNotification = [NSNotification notificationWithName:kMuxrNotification
                                                                     object:nil
                                                                   userInfo:userInfo];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotification:muxrNotification];
    });
}

- (void)removeApp:(TKDApp *)app;
{
    NSString *command = [NSString stringWithFormat:@"REMOVE \"%@\"\n", app.appHostname];
    [self issueCommand:command];
}

- (void)issueCommand:(NSString *)command
{
    NSData *data = [command dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:data withTimeout:-1 tag:0];
    [self.socket readDataWithTimeout:-1 tag:0];
}

@end
