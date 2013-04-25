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

// plist replacement constants
static NSString * const kTokaidoBootstrapFirewallPlistCommandString = @"TOKAIDO_FIREWALL_COMMAND";
static NSString * const kTokaidoBootstrapFirewallPlistTmpDir = @"TOKAIDO_FIREWALL_TMPDIR";
static NSString * const kTokaidoBootstrapFirewallPlistSetupString = @"TOKAIDO_FIREWALL_SETUP";
static NSString * const kTokaidoBootstrapFirewallPlistScriptString = @"TOKAIDO_FIREWALL_SCRIPT";

// tokaido-bootstrap label
static NSString * const kTokaidoBootstrapLabel = @"io.tilde.tokaido.bootstrap";

@implementation TKDAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self ensureTokaidoAppSupportDirectoryIsUpToDate];
    [self ensureTokaidoInstallIsInstalled];
    [self ensureTokaidoBootstrapIsInstalled];
    sleep(1);
    [self stopTokaidoBootstrap];
    sleep(1);
    [self startTokaidoBootstrap];
    
    [self loadAppSettings];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)notification;
{
    [self stopTokaidoBootstrap];
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
                NSLog(@"Installing Ruby: %@...", rubyName);
                [self installRubyWithName:rubyName];
            }
        }
    }
    
    // Make sure we have a gems directory. If we don't, extract our default gems to that directory.
    BOOL gemsDirectoryExists = [fm fileExistsAtPath:[TKDAppDelegate tokaidoInstalledGemsDirectory]];
    if (!gemsDirectoryExists) {
        [TKDAppDelegate createDirectoryAtPathIfNonExistant:[TKDAppDelegate tokaidoInstalledGemsDirectory]];
        [self unzipFileAtPath:[TKDAppDelegate tokaidoBundledGemsFile]
              inDirectoryPath:[TKDAppDelegate tokaidoAppSupportDirectory]];
    }
    
    // Make sure we have a sqlite3 installed.
    NSString *gemsDirectory = [[TKDAppDelegate tokaidoInstalledGemsDirectory] stringByAppendingPathComponent:@"/gems"];
    NSString *sqliteDirectory = [gemsDirectory stringByAppendingPathComponent:@"sqlite3-1.3.7"];
    BOOL sqlite3Exists = [fm fileExistsAtPath:sqliteDirectory];
    if (!sqlite3Exists) {
        [TKDAppDelegate createDirectoryAtPathIfNonExistant:gemsDirectory];
        [self unzipFileAtPath:[TKDAppDelegate tokaidoBundledSqliteFile]
              inDirectoryPath:gemsDirectory];
    }
}


- (void)ensureTokaidoBootstrapIsInstalled
{
    // Check if /etc/resolver/tokaido exists. If not, we need to run tokaido-install.
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL tokaidoBootstrapInstalled = [fm fileExistsAtPath:@"/Library/LaunchDaemons/com.tokaido.firewall.plist"];
    
    // If not, do the installation stuff.
    if (tokaidoBootstrapInstalled) {
        NSLog(@"tokaido-bootstrap detected...");
    } else {
        NSLog(@"tokaido-bootstrap NOT detected, installing...");
        
        // Setup a bunch of paths
        NSString *executablePath = [[@"~/Library/Application Support/Tokaido/ruby" stringByExpandingTildeInPath] stringByResolvingSymlinksInPath];
        NSString *setupScriptPath = [[TKDAppDelegate tokaidoInstalledBootstrapDirectory]stringByAppendingPathComponent:@"bundle/bundler/setup.rb"];
        NSString *firewallPlistPath = [[TKDAppDelegate tokaidoInstalledBootstrapDirectory] stringByAppendingPathComponent:@"firewall/com.tokaido.firewall.plist"];
        NSString *firewallScriptPath = [[TKDAppDelegate tokaidoInstalledBootstrapDirectory] stringByAppendingPathComponent:@"firewall/firewall_rules.rb"];
        NSString *firewallPath = [TKDAppDelegate tokaidoInstalledFirewallDirectory];
        
        // Rewrite the install plist to contain appropriate values
        NSError *error = nil;
        NSString *firewallPlistString = [NSString stringWithContentsOfFile:firewallPlistPath
                                                                  encoding:NSUTF8StringEncoding
                                                                     error:&error];
        if (error) {
            NSLog(@"ERROR: Couldn't read firewall plist: %@", [error localizedDescription]);
        } else {
            firewallPlistString = [firewallPlistString stringByReplacingOccurrencesOfString:kTokaidoBootstrapFirewallPlistCommandString
                                                                                 withString:executablePath];
            firewallPlistString = [firewallPlistString stringByReplacingOccurrencesOfString:kTokaidoBootstrapFirewallPlistTmpDir
                                                                                 withString:firewallPath];
            firewallPlistString = [firewallPlistString stringByReplacingOccurrencesOfString:kTokaidoBootstrapFirewallPlistSetupString
                                                                                 withString:setupScriptPath];
            firewallPlistString = [firewallPlistString stringByReplacingOccurrencesOfString:kTokaidoBootstrapFirewallPlistScriptString
                                                                                 withString:firewallScriptPath];
            [firewallPlistString writeToFile:firewallPlistPath
                                  atomically:YES
                                    encoding:NSUTF8StringEncoding
                                       error:&error];
        }
        
        if (error) {
            NSLog(@"ERROR: Coludn't write the firewall plist: %@", [error localizedDescription]);
        }
        
        
        // Run tokaido-install with the appropriate setup stuff beforehand
        
        NSString *tokaidoLabel = @"io.tilde.tokaido-install";
        NSString *tokadioInstallScriptPath = [[TKDAppDelegate tokaidoInstalledBootstrapDirectory] stringByAppendingPathComponent:@"bin/tokaido-install"];
        
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
            [plist setObject:[NSNumber numberWithBool:YES] forKey:@"AbandonProcessGroup"];
            [plist setObject:@[ executablePath, @"-r", setupScriptPath, tokadioInstallScriptPath ] forKey:@"ProgramArguments"];
            [plist setObject:@"/var/log/tokaido-install.log" forKey:@"StandardOutPath"];
            [plist setObject:@"/var/log/tokaido-install.error" forKey:@"StandardErrorPath"];
            
            CFErrorRef error;
            if ( SMJobSubmit( kSMDomainSystemLaunchd, (__bridge CFDictionaryRef)plist, auth, &error) ) {
                // Script is running
                NSLog(@"Ran successfully.");
                
            } else {
                NSLog( @"Authenticated install submit failed with error %@", error );
            }
            
            if (error) {
                NSLog(@"SMJobSubmit ERROR: %@", CFErrorCopyDescription(error));
                CFRelease(error);
            }
            
            AuthorizationFree(auth, 0);
                        
        } else {
            
            NSLog(@"Couldn't run tokaido-install. Quitting.");
            [[NSApplication sharedApplication] terminate:nil];
            
        }
    }
}


- (void)ensureTokaidoInstallIsInstalled
{
    // Check if tokaido-bootstrap is where we expect it to be
    NSString *bootstrapDir = [TKDAppDelegate tokaidoInstalledBootstrapDirectory];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL bootstrapGemsInstalled = [fm fileExistsAtPath:[bootstrapDir stringByAppendingFormat:@"/bundle/bundler/setup.rb"]];
    
    if (!bootstrapGemsInstalled) {
        NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:10];
        NSString *fullPathToBootstrapZip = [TKDAppDelegate tokaidoBundledBootstrapFile];
        [arguments addObject:@"-o"];
        [arguments addObject:fullPathToBootstrapZip];
        
        NSTask *unzipTask = [[NSTask alloc] init];
        [unzipTask setLaunchPath:@"/usr/bin/unzip"];
        [unzipTask setCurrentDirectoryPath:[TKDAppDelegate tokaidoAppSupportDirectory]];
        [unzipTask setArguments:arguments];
        [unzipTask launch];
        [unzipTask waitUntilExit];
    }
}

#pragma mark App Settings

- (void)loadAppSettings
{
    NSString *appSettingsPath = [[TKDAppDelegate tokaidoAppSupportDirectory] stringByAppendingPathComponent:@"AppSettings"];
    
    NSMutableArray *apps = nil;
    @try {
        apps = [NSKeyedUnarchiver unarchiveObjectWithFile:appSettingsPath];
    }
    @catch (NSException *exception) {
        NSLog(@"ERROR: Couldn't load app settings: %@", exception);
    }
    
    if (apps) {
        self.tokaidoController.apps = apps;
    } else {
        NSLog(@"ERROR: Could not load app settings.");
    }
}

- (void)saveAppSettings
{
    NSString *appSettingsPath = [[TKDAppDelegate tokaidoAppSupportDirectory] stringByAppendingPathComponent:@"AppSettings"];
    BOOL success = [NSKeyedArchiver archiveRootObject:self.tokaidoController.apps toFile:appSettingsPath];
    if (!success) {
        NSLog(@"ERROR: Couldn't save app settings.");
    }
}

#pragma mark Helper Methods

- (void)installRubyWithName:(NSString *)rubyName
{
    NSString *fullPathToRubyZip = [[TKDAppDelegate tokaidoBundledRubiesDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", rubyName]];
    [self unzipFileAtPath:fullPathToRubyZip inDirectoryPath:[TKDAppDelegate tokaidoInstalledRubiesDirectory]];
        
    // We need a better way to decide what the default ruby should be. Right now we only have one, so just set it as default.
    NSTask *linkTask = [[NSTask alloc] init];
    [linkTask setLaunchPath:@"/bin/ln"];
    [linkTask setCurrentDirectoryPath:[TKDAppDelegate tokaidoAppSupportDirectory]];
    [linkTask setArguments:@[ @"-s", [@"Rubies" stringByAppendingPathComponent:[rubyName stringByAppendingPathComponent:@"bin/ruby"]], @"ruby" ] ];
    [linkTask launch];
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

- (void)openTerminalWithPath:(NSString *)path;
{
    NSString *rubyVersion = @"1.9.3-p194";
    NSString *rubyBinDirectory = [rubyVersion stringByAppendingPathComponent:@"bin"];

    // First, set up a variable for our ruby installation.
    NSString *tokaidoSetupStep0 = [NSString stringWithFormat:@"export TOKAIDO_PATH=%@", [[[TKDAppDelegate tokaidoInstalledRubiesDirectory] stringByReplacingOccurrencesOfString:@" " withString:@"\\ "] stringByAppendingPathComponent:rubyBinDirectory]];
    
    
    // Second, set up a variable for our gems location.
    NSString *gemsDir = [TKDAppDelegate tokaidoInstalledGemsDirectory];
    NSString *tokaidoSetupStep1 = [tokaidoSetupStep0 stringByAppendingFormat:@"; export TOKAIDO_GEM_HOME=%@", [gemsDir stringByReplacingOccurrencesOfString:@" " withString:@"\\ "]];
    
    // Third, set up the directory we will cd to
    NSString *tokaidoSetupStep2 = [tokaidoSetupStep1 stringByAppendingFormat:@"; export TOKAIDO_APP_DIR=%@", [path stringByReplacingOccurrencesOfString:@" " withString:@"\\ "]];
    
    
    // Forth, source the SetupTokaido script, to load these variables into the shell and clear up the screen.
    NSString *tokaidoSetupStep3 = [tokaidoSetupStep2 stringByAppendingFormat:@"; source %@/SetupTokaido.sh", [[NSBundle mainBundle] resourcePath]];
    

    // Finally run everything.
    TerminalApplication *terminal = [SBApplication applicationWithBundleIdentifier:@"com.apple.Terminal"];
    [terminal doScript:tokaidoSetupStep3 in:nil];
    [terminal activate];
}

#pragma mark Directories

+ (NSString *)tokaidoInstalledGemsDirectory;
{
    NSString *tokaidoInstalledGemsDirectory = [[self tokaidoAppSupportDirectory] stringByAppendingPathComponent:@"Gems"];
    return tokaidoInstalledGemsDirectory;
}

+ (NSString *)tokaidoInstalledRubiesDirectory;
{
    NSString *tokaidoInstalledRubiesDirectory = [[self tokaidoAppSupportDirectory] stringByAppendingPathComponent:@"Rubies"];
    [self createDirectoryAtPathIfNonExistant:tokaidoInstalledRubiesDirectory];
    return tokaidoInstalledRubiesDirectory;
}

+ (NSString *)tokaidoInstalledBootstrapDirectory;
{
    NSString *tokaidoInstalledBootstrapDirectory = [[self tokaidoAppSupportDirectory] stringByAppendingPathComponent:@"Bootstrap"];
    [self createDirectoryAtPathIfNonExistant:tokaidoInstalledBootstrapDirectory];
    return tokaidoInstalledBootstrapDirectory;
}

+ (NSString *)tokaidoInstalledFirewallDirectory;
{
    NSString *tokaidoInstalledFirewallDirectory = [[self tokaidoAppSupportDirectory] stringByAppendingPathComponent:@"Firewall"];
    [self createDirectoryAtPathIfNonExistant:tokaidoInstalledFirewallDirectory];
    return tokaidoInstalledFirewallDirectory;
}

+ (NSString *)tokaidoMuxrSocketPath;
{
    NSString *tokaidoMuxrPath = [[self tokaidoAppSupportDirectory] stringByAppendingPathComponent:@"Firewall/muxr.sock"];
    return tokaidoMuxrPath;
}

+ (NSString *)tokaidoBundledRubiesDirectory;
{
    NSString *tokaidoBundledRubiesDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Rubies"];
    return tokaidoBundledRubiesDirectory;
}

+ (NSString *)tokaidoBundledGemsFile;
{
    NSString *tokaidoBundledRubiesDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"tokaido-gems.zip"];
    return tokaidoBundledRubiesDirectory;
}

+ (NSString *)tokaidoBundledSqliteFile;
{
    NSString *tokaidoBundledRubiesDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"sqlite3-1.3.7.zip"];
    return tokaidoBundledRubiesDirectory;
}


+ (NSString *)tokaidoBundledBootstrapFile
{
    NSString *tokaidoBundledRubiesDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"tokaido-bootstrap.zip"];
    return tokaidoBundledRubiesDirectory;
}


+ (NSString *)tokaidoAppSupportDirectory;
{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportDirectory = [paths objectAtIndex:0];
    NSString *tokaidoDirectory = [NSString stringWithFormat:@"%@/Tokaido", applicationSupportDirectory];
    [self createDirectoryAtPathIfNonExistant:tokaidoDirectory];

    NSString *homeDirectory = NSHomeDirectory();
    NSString *tokaidoDirectorySymlink = [homeDirectory stringByAppendingPathComponent:@"/.tokaido"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:tokaidoDirectorySymlink]) {
        NSError *error = nil;
        [fm createSymbolicLinkAtPath:tokaidoDirectorySymlink withDestinationPath:tokaidoDirectory error:&error];
        if (error) {
            NSLog(@"ERROR: Couldn't create the .tokaido symlink.");
        }
    }
    
    return tokaidoDirectorySymlink;
}

#pragma mark start/stop tokaido-bootstrap

- (void)startTokaidoBootstrap
{
    NSString *executablePath = [[TKDAppDelegate tokaidoAppSupportDirectory] stringByAppendingPathComponent:@"/ruby"];
    NSString *executableDirectory = [TKDAppDelegate tokaidoAppSupportDirectory];
    NSString *setupScriptPath = [[TKDAppDelegate tokaidoInstalledBootstrapDirectory] stringByAppendingPathComponent:@"bundle/bundler/setup.rb"];
    NSString *tokadioBootstrapScriptPath = [[TKDAppDelegate tokaidoInstalledBootstrapDirectory] stringByAppendingPathComponent:@"bin/tokaido-bootstrap"];
    NSString *firewallPath = [TKDAppDelegate tokaidoInstalledFirewallDirectory];
    NSString *gemHome = [TKDAppDelegate tokaidoInstalledGemsDirectory];
    NSString *gemPath = [[TKDAppDelegate tokaidoInstalledGemsDirectory] stringByAppendingPathComponent:@"/bin"];
    NSString *path = [executableDirectory stringByAppendingFormat:@":%@", gemPath];
    
    
    NSMutableDictionary *plist = [NSMutableDictionary dictionary];
    [plist setObject:kTokaidoBootstrapLabel forKey:@"Label"];
    [plist setObject:[NSNumber numberWithBool:YES] forKey:@"RunAtLoad"];
    [plist setObject:@"/tmp/bootstrap.out" forKey:@"StandardOutPath"];
    [plist setObject:@"/tmp/bootstrap.err" forKey:@"StandardErrorPath"];
    [plist setObject:[NSNumber numberWithBool:YES] forKey:@"AbandonProcessGroup"];
    [plist setObject:@{
     @"TOKAIDO_TMPDIR": firewallPath,
     @"PATH": path,
     @"GEM_HOME": gemHome,
     @"GEM_PATH": gemHome // Think we need this? Not really sure.
     }  forKey:@"EnvironmentVariables"];
    
    [plist setObject:@[ executablePath, @"-r", setupScriptPath, tokadioBootstrapScriptPath ]
              forKey:@"ProgramArguments"];
    
    CFErrorRef error;
    if ( SMJobSubmit( kSMDomainUserLaunchd, (__bridge CFDictionaryRef)plist, NULL, &error) ) {
        // Script is running
        NSLog(@"tokaido-bootstrap started successfully.");
        
    } else {
        NSLog(@"tokaido-bootstrap failed to start – error %@", error);
    }
    
    if (error) {
        NSLog(@"SMJobSubmit ERROR: %@", CFErrorCopyDescription(error));
        CFRelease(error);
    }
}

- (void)stopTokaidoBootstrap
{
    NSLog(@"tokaido-bootstrap shutting down...");
     SMJobRemove(kSMDomainUserLaunchd, (__bridge CFStringRef)kTokaidoBootstrapLabel, NULL, false, NULL);
}

#pragma mark Helpers

- (void)unzipFileAtPath:(NSString *)path inDirectoryPath:(NSString *)directory
{
    NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:10];
    [arguments addObject:@"-u"];
    [arguments addObject:path];
    
    NSTask *unzipTask = [[NSTask alloc] init];
    [unzipTask setLaunchPath:@"/usr/bin/unzip"];
    [unzipTask setCurrentDirectoryPath:directory];
    [unzipTask setArguments:arguments];
    [unzipTask launch];
    [unzipTask waitUntilExit];
}

@end
