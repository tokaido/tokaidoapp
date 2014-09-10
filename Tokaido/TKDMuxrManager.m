#import "TKDMuxrManager.h"

#include <sys/socket.h>
#include <sys/un.h>

#import "TKDConfiguration.h"

#define TAG_MUXR_RESPONSE  0
#define TAG_AWAIT_COMMAND  1

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

- (void)setup {
    self.backgroundQueue = dispatch_queue_create("socketQueue", DISPATCH_QUEUE_SERIAL);
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.backgroundQueue];
    [self connect];
}

-(void)connect {
    NSError *error = nil;
    
    if (![self.socket connectToUrl:[NSURL URLWithString:[TKDConfiguration muxrSocketPath]] withTimeout:-1 error:&error]) {
        NSLog(@"ERROR: Couldn't connect to socket: %@", [error localizedDescription]);
        return;
    }
    
    [self.socket readDataToData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:TAG_MUXR_RESPONSE];
    
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag;
{
    NSString *muxrLine = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Got back from muxr: %@", muxrLine);
    
    
    if (TAG_MUXR_RESPONSE == tag) {
        if ([muxrLine isEqualToString:@"TOKAIDO ACTIVE\n"]) {
            NSLog(@"Muxr Manager Ready");
            return;
        }
    } else if (TAG_AWAIT_COMMAND == tag) {
        NSArray *elements = [muxrLine componentsSeparatedByString:@" "];
        NSString *reply = [elements objectAtIndex:0];
        
        if ([reply isEqualToString:@"ADDED"]) {
            NSLog(@"App added, waiting for ready...");
            [self.socket readDataToData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1  tag:TAG_AWAIT_COMMAND];
        } else if ([reply isEqualToString:@"READY"] || [reply isEqualToString:@"REMOVED"] || [reply isEqualToString:@"ERR"]) {
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSDictionary *userInfo = @{@"action": [elements objectAtIndex:0],
                                           @"hostname": [elements objectAtIndex:1]};
                NSNotification *muxrNotification = [NSNotification notificationWithName:kMuxrNotification
                                                                                 object:nil
                                                                               userInfo:userInfo];
                
                [[NSNotificationCenter defaultCenter] postNotification:muxrNotification];
            });
        }
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToUrl:(NSURL *)url {
    NSLog(@"Connected to %@", url);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error {
    NSLog(@"Closed connection: %@", error);
    
    // socket not found? 2
    // connection refused? 61
    if ([error code] == 2 || [error code] == 61) {
        [self connect];
        return;
    }
    
    // connection reset by peer
    if ([error code] == 7) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Tokaido, we have a problem.", nil)
                                             defaultButton:@"OK"
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:NSLocalizedString(@"The connection with Muxr (Tokaido's app manager) was reset. Please close Tokaido and reopen.", nil)];
            
            [alert runModal];
        });
    }
}

- (void)addApp:(TKDApp *)app;
{
    [app runBundleInstall];
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
    [self.socket readDataToData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1  tag:TAG_AWAIT_COMMAND];
}

@end
