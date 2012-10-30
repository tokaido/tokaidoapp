//
//  TKDAppDelegate.m
//  Tokaido
//
//  Created by Mucho Besos on 10/23/12.
//  Copyright (c) 2012 Tilde. All rights reserved.
//

#import "TKDAppDelegate.h"
#import "Terminal.h"

#import <ServiceManagement/ServiceManagement.h>
#import <Security/Authorization.h>

@implementation TKDAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self ensureTokaidoAppSupportDirectoryIsUpToDate];
    [self ensureTokaidoBootstrapIsInstalled];
    
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

- (void)ensureTokaidoBootstrapIsInstalled
{
    // Check to see if we can communicate with tokaido-bootstrap
#warning Assume NO for now.

    // If not, do the installation stuff.
    if (YES) {
        
        NSString *executablePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"tokaido-bootstrap"];
        NSString *tokaidoLabel = @"io.tilde.tokaido-bootstrap";
        
        AuthorizationItem authItem = { kSMRightBlessPrivilegedHelper, 0, NULL, 0 };
        AuthorizationRights authRights = { 1, &authItem };
        AuthorizationFlags flags = kAuthorizationFlagInteractionAllowed | kAuthorizationFlagPreAuthorize | kAuthorizationFlagExtendRights;
        
        // Empty for now
        NSString *promptText = @"";
        AuthorizationItem dialogConfiguration[1] = {
            {kAuthorizationEnvironmentPrompt, [promptText length], (char *) [promptText UTF8String], 0}
        };
        
        AuthorizationEnvironment authorizationEnvironment = { 0 };
        authorizationEnvironment.items = dialogConfiguration;
        authorizationEnvironment.count = 1;
        
        AuthorizationRef auth;
        if( AuthorizationCreate( &authRights, &authorizationEnvironment, flags, &auth ) == errAuthorizationSuccess ) {
            (void) SMJobRemove( kSMDomainSystemLaunchd, (__bridge CFStringRef)tokaidoLabel, auth, false, NULL );
            
            NSMutableDictionary *plist = [NSMutableDictionary dictionary];
            [plist setObject:tokaidoLabel forKey:@"Label"];
            [plist setObject:[NSNumber numberWithBool:YES] forKey:@"RunAtLoad"];
            [plist setObject:@"/usr/bin/whoami" forKey:@"Program"];
            [plist setObject:@"/var/log/tokaido" forKey:@"StandardOutPath"];
            CFErrorRef error;
            if ( SMJobSubmit( kSMDomainSystemLaunchd, (__bridge CFDictionaryRef)plist, auth, &error) ) {
                // Script is running
                NSLog(@"Ran successfully.");
                
            } else {
                NSLog( @"Authenticated install submit failed with error %@", error );
            }
            
            if (error) {
                CFRelease(error);
            }
            
            (void) SMJobRemove(kSMDomainSystemLaunchd, (__bridge CFStringRef)tokaidoLabel, auth, false, NULL);
            AuthorizationFree(auth, 0);
        } else {
            
            NSLog(@"Couldn't install tokaido-bootstrap. Quitting.");
            [[NSApplication sharedApplication] terminate:nil];
            
        }

    }

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
    [terminal activate];
    
}

@end
