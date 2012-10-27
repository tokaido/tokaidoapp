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
    [self ensureTokaidoAppSupportDirectoryIsUpToDate];
    
    [self loadPrefs];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (void)ensureTokaidoAppSupportDirectoryIsUpToDate
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // Go through the ruby bundles already in our app support directory
    // and create a list of already installed rubies.
    NSString *installedRubiesDirectory = [TKDAppDelegate tokaidoInstalledRubiesDirectory];
    NSMutableSet *installedRubies = [NSMutableSet set];
    
    NSDirectoryEnumerator *installedRubiesEnum = [fm enumeratorAtPath:installedRubiesDirectory];
    NSString *installedFile;
    while (installedFile = [installedRubiesEnum nextObject]) {
        BOOL isDirectory = NO;
        NSString *fullInstalledPath = [installedRubiesDirectory stringByAppendingPathComponent:installedFile];
        if ([fm fileExistsAtPath:fullInstalledPath isDirectory:&isDirectory] && isDirectory) {
            [installedRubiesEnum skipDescendents];
            [installedRubies addObject:installedFile];
        }
    }
    
    // Go through all the ruby bundles we shipped with.
    // If there are any that aren't already installed, then install them.
    NSString *bundledRubiesDirectory = [TKDAppDelegate tokaidoBundledRubiesDirectory];
    
    NSDirectoryEnumerator *bundledRubiesEnum = [fm enumeratorAtPath:bundledRubiesDirectory];
    NSString *bundledFile;
    while (bundledFile = [bundledRubiesEnum nextObject]) {
        if ([[bundledFile pathExtension] isEqualToString: @"zip"]) {
            NSString *rubyName = [bundledFile stringByDeletingPathExtension];
            if ([installedRubies containsObject:rubyName]) {
                continue;
            } else {
                NSLog(@"Installing %@...", rubyName);
                [self installRubyWithName:rubyName];
            }
        }
    }
    
}


- (void)loadPrefs
{
    
}


- (void)installRubyWithName:(NSString *)rubyName
{
    NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:10];
    NSString *fullPathToRubyZip = [[TKDAppDelegate tokaidoBundledRubiesDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", rubyName]];
    [arguments addObject:fullPathToRubyZip];
    
    NSTask *unzipTask = [[NSTask alloc] init];
    [unzipTask setLaunchPath:@"/usr/bin/unzip"];
    [unzipTask setCurrentDirectoryPath:[TKDAppDelegate tokaidoInstalledRubiesDirectory]];
    [unzipTask setArguments:arguments];
    [unzipTask launch];
}

+ (void)createDirectoryAtPathIfNonExistant:(NSString *)path
{
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    
    // If the directory doesn't exist try to create it
    if ( !([fm fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) ) {
        // Create the directory
        NSError *error = nil;
        BOOL success = [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (!success && error) {
            NSLog(@"ERROR: Couldn't create the Tokaido directory at %@: %@", path, [error localizedDescription]);
        }
    }
}

+ (NSString *)tokaidoInstalledGemsDirectoryForRuby:(NSString *)ruby;
{
    NSString *tokaidoInstalledGemsDirectory = [[self tokaidoAppSupportDirectory] stringByAppendingPathComponent:@"Gems"];
    [self createDirectoryAtPathIfNonExistant:tokaidoInstalledGemsDirectory];
    NSString *tokaidoInstalledGemsDirectoryForRuby = [tokaidoInstalledGemsDirectory stringByAppendingPathComponent:ruby];
    [self createDirectoryAtPathIfNonExistant:tokaidoInstalledGemsDirectoryForRuby];
    return tokaidoInstalledGemsDirectoryForRuby;
}

+ (NSString *)tokaidoInstalledRubiesDirectory;
{
    NSString *tokaidoInstalledRubiesDirectory = [[self tokaidoAppSupportDirectory] stringByAppendingPathComponent:@"Rubies"];
    [self createDirectoryAtPathIfNonExistant:tokaidoInstalledRubiesDirectory];
    return tokaidoInstalledRubiesDirectory;
}

+ (NSString *)tokaidoBundledRubiesDirectory;
{
    NSString *tokaidoBundledRubiesDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Rubies"];
    [self createDirectoryAtPathIfNonExistant:tokaidoBundledRubiesDirectory];
    return tokaidoBundledRubiesDirectory;
}

+ (NSString *)tokaidoAppSupportDirectory;
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportDirectory = [paths objectAtIndex:0];
    NSString *tokaidoDirectory = [NSString stringWithFormat:@"%@/Tokaido", applicationSupportDirectory];
    [self createDirectoryAtPathIfNonExistant:tokaidoDirectory];
    return tokaidoDirectory;
}

- (void)openTerminal;
{
#warning This is hardcoded for now.
    NSString *rubyVersion = @"1.9.3-p194";
    NSString *rubyBinDirectory = [rubyVersion stringByAppendingPathComponent:@"bin"];

    // First, set up a variable for our ruby installation.
    NSString *tokaidoSetupStep0 = [NSString stringWithFormat:@"export TOKAIDO_PATH=%@", [[[TKDAppDelegate tokaidoInstalledRubiesDirectory] stringByReplacingOccurrencesOfString:@" " withString:@"\\ "] stringByAppendingPathComponent:rubyBinDirectory]];
    
    
    // Second, set up a variable for our gems location.
    NSString *gemsDir = [TKDAppDelegate tokaidoInstalledGemsDirectoryForRuby:rubyVersion];
    NSString *tokaidoSetupStep1 = [tokaidoSetupStep0 stringByAppendingFormat:@"; export TOKAIDO_GEM_HOME=%@", [gemsDir stringByReplacingOccurrencesOfString:@" " withString:@"\\ "]];
    
    
    // Third, source the SetupTokaido script, to load these variables into the shell and clear up the screen.
    NSString *tokaidoSetupStep2 = [tokaidoSetupStep1 stringByAppendingFormat:@"; source %@/SetupTokaido.sh", [[NSBundle mainBundle] resourcePath]];
    

    // Finally run everything.
    TerminalApplication *terminal = [SBApplication applicationWithBundleIdentifier:@"com.apple.Terminal"];
    [terminal doScript:tokaidoSetupStep2 in:nil];
}

@end
