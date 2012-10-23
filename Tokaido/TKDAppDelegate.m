//
//  TKDAppDelegate.m
//  Tokaido
//
//  Created by Mucho Besos on 10/23/12.
//  Copyright (c) 2012 Tilde. All rights reserved.
//

#import "TKDAppDelegate.h"
#import "Terminal.h"

@implementation TKDAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

+ (NSString *)documentsDirectory;
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportDirectory = [paths objectAtIndex:0];
    NSString *tokaidoDirectory = [NSString stringWithFormat:@"%@/Tokaido", applicationSupportDirectory];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    
    // If the directory doesn't exist (or if it's not a directory) try to create it
    if ( !([fm fileExistsAtPath:tokaidoDirectory isDirectory:&isDirectory] && isDirectory) ) {
        // Create the directory
        NSError *error = nil;
        BOOL success = [fm createDirectoryAtPath:tokaidoDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (!success && error) {
            NSLog(@"ERROR: Couldn't create the Tokaido app support directory at %@: %@", tokaidoDirectory, [error localizedDescription]);
        }
    }
    
    return tokaidoDirectory;
}

- (void)openTerminal;
{
    NSBundle *appBundle = [NSBundle mainBundle];
    NSString *setupTokaidoScriptPath = [NSString stringWithFormat:@"%@/SetupTokaido.sh", [appBundle resourcePath]];
    
    TerminalApplication *terminal = [SBApplication applicationWithBundleIdentifier:@"com.apple.Terminal"];
    [terminal doScript:setupTokaidoScriptPath in:nil];
}

@end
