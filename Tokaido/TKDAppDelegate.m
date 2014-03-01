//
//  TKDAppDelegate.m
//  Tokaido
//
//  Created by Mucho Besos on 10/23/12.
//  Copyright (c) 2012 Tilde. All rights reserved.
//

#import "TKDAppDelegate.h"
#import "TKDUtilities.h"
#import "Terminal.h"
#import "TKDConfiguration.h"
#import "TKDFileUtilities.h"

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

#pragma mark Launch Steps

- (void)ensureTokaidoAppSupportDirectoryIsUpToDate
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // Go through the ruby bundles already in our app support directory
    // and create a list of already installed rubies.
    NSString *installedRubiesDirectory = [TKDConfiguration rubyInstallationDirectories];
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
    NSString *bundledRubiesDirectory = [TKDConfiguration tokaidoBundledRubiesDirectory];
    
    NSLog(@"Bundled Rubies Directory: %@", bundledRubiesDirectory);

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
    BOOL gemsDirectoryExists = [fm fileExistsAtPath:[TKDConfiguration tokaidoInstalledGemsDirectory]];
    if (!gemsDirectoryExists) {
        [TKDFileUtilities createDirectoryAtPathIfNonExistant:[TKDConfiguration tokaidoInstalledGemsDirectory]];
        [TKDFileUtilities unzipFileAtPath:[TKDConfiguration tokaidoBundledGemsFile]
              inDirectoryPath:[TKDConfiguration tokaidoAppSupportDirectory]];
    }

    BOOL binDirectoryExists = [fm fileExistsAtPath:[TKDConfiguration tokaidoInstalledBinDirectory]];
    if (!binDirectoryExists) {
        NSLog(@"Unzipping Bundled Tokaido binaries");
        [TKDFileUtilities createDirectoryAtPathIfNonExistant:[TKDConfiguration tokaidoInstalledBinDirectory]];
        [TKDFileUtilities unzipFileAtPath:[TKDConfiguration tokaidoBundledBinFile]
              inDirectoryPath:[TKDConfiguration tokaidoAppSupportDirectory]];
    }

    // Make sure we have a llvm-gcc installed, for gems that require compilation
    BOOL llvmExists = [fm fileExistsAtPath:[TKDConfiguration tokaidoInstalledLLVMGCC]];
    if (!llvmExists) {
        NSLog(@"Unzipping Bundlded LLVM GCC");
        [TKDFileUtilities createDirectoryAtPathIfNonExistant:[TKDConfiguration tokaidoInstalledLLVMGCC]];
        [TKDFileUtilities unzipFileAtPath:[TKDConfiguration tokaidoBundledLLVMGCCFile]
              inDirectoryPath:[TKDConfiguration tokaidoAppSupportDirectory]];
    }
    
    NSError *error = nil;
    NSString *rbConfigPath = [TKDConfiguration tokaidoInstalledRbConfig];
    NSMutableString *rbconfig = [[NSString stringWithContentsOfFile:rbConfigPath encoding:NSUTF8StringEncoding error:&error] mutableCopy];
 
 
    if (error) {
        NSLog(@"ERROR patching rbconfig: %@", [error localizedDescription]);
        return;
    }
 
 
    
    // Replace the TOPDIR line
    NSRegularExpression *topDirRegex = [NSRegularExpression regularExpressionWithPattern:@"TOPDIR\\s=.*"
                                                                           options:0
                                                                             error:&error];
    
    if (error) {
        NSLog(@"ERROR patching rbconfig: %@", [error localizedDescription]);
        return;
    }
 
 
    
    NSString *newTopDir = [NSString stringWithFormat:@"TOPDIR = \"%@/2.1.1-p76\"", [TKDConfiguration rubyInstallationDirectories]];
    [topDirRegex replaceMatchesInString:rbconfig
                          options:0
                            range:NSMakeRange(0, [rbconfig length])
                       withTemplate:newTopDir];
    
    // Replace the CONFIG["CC"] line
    NSRegularExpression *ccRegex = [NSRegularExpression regularExpressionWithPattern:@"CONFIG\\[\\\"CC\\\"\\].*"
                                                                           options:0
                                                                             error:&error];
    
    if (error) {
        NSLog(@"ERROR patching rbconfig: %@", [error localizedDescription]);
        return;
    }
    
    NSString *newConfig = [NSString stringWithFormat:@"CONFIG[\"CC\"] = \"%@\"", [TKDConfiguration tokaidoInstalledLLVMGCC]];
    [ccRegex replaceMatchesInString:rbconfig
                          options:0
                            range:NSMakeRange(0, [rbconfig length])
                     withTemplate:newConfig];
    
    [rbconfig writeToFile:[TKDConfiguration tokaidoInstalledRbConfig]
               atomically:YES
                 encoding:NSUTF8StringEncoding
                    error:&error];
    
    if (error) {
        NSLog(@"ERROR saving rbconfig: %@", [error localizedDescription]);
        return;
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
        NSString *executablePath = [[@"~/.tokaido/ruby" stringByExpandingTildeInPath] stringByResolvingSymlinksInPath];
        NSString *setupScriptPath = [[TKDConfiguration tokaidoInstalledBootstrapDirectory]stringByAppendingPathComponent:@"bundle/bundler/setup.rb"];
        NSString *firewallPlistPath = [[TKDConfiguration tokaidoInstalledBootstrapDirectory] stringByAppendingPathComponent:@"firewall/com.tokaido.firewall.plist"];
        NSString *firewallScriptPath = [[TKDConfiguration tokaidoInstalledBootstrapDirectory] stringByAppendingPathComponent:@"firewall/firewall_rules.rb"];
        NSString *firewallPath = [TKDConfiguration tokaidoInstalledFirewallDirectory];
        
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
        NSString *tokadioInstallScriptPath = [[TKDConfiguration tokaidoInstalledBootstrapDirectory] stringByAppendingPathComponent:@"bin/tokaido-install"];
                
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
    NSString *bootstrapDir = [TKDConfiguration tokaidoInstalledBootstrapDirectory];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL bootstrapGemsInstalled = [fm fileExistsAtPath:[bootstrapDir stringByAppendingFormat:@"/bundle/bundler/setup.rb"]];
 
    if (!bootstrapGemsInstalled) {
        NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:10];
        NSString *fullPathToBootstrapZip = [TKDConfiguration tokaidoBundledBootstrapFile];
        [arguments addObject:@"-o"];
        [arguments addObject:fullPathToBootstrapZip];
        
        NSTask *unzipTask = [[NSTask alloc] init];
        [unzipTask setLaunchPath:@"/usr/bin/unzip"];
        [unzipTask setCurrentDirectoryPath:[TKDConfiguration tokaidoAppSupportDirectory]];
        [unzipTask setArguments:arguments];
        [unzipTask launch];
        [unzipTask waitUntilExit];
    }
}

#pragma mark App Settings

- (void)loadAppSettings
{
    NSString *appSettingsPath = [[TKDConfiguration tokaidoAppSupportDirectory] stringByAppendingPathComponent:@"AppSettings"];
    
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
    NSString *appSettingsPath = [[TKDConfiguration tokaidoAppSupportDirectory] stringByAppendingPathComponent:@"AppSettings"];
    BOOL success = [NSKeyedArchiver archiveRootObject:self.tokaidoController.apps toFile:appSettingsPath];
    if (!success) {
        NSLog(@"ERROR: Couldn't save app settings.");
    }
}

#pragma mark Helper Methods

- (void)installRubyWithName:(NSString *)rubyName
{
    NSString *fullPathToRubyZip = [[TKDConfiguration tokaidoBundledRubiesDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", rubyName]];
    [TKDFileUtilities unzipFileAtPath:fullPathToRubyZip inDirectoryPath:[TKDConfiguration rubyInstallationDirectories]];
        
    // We need a better way to decide what the default ruby should be. Right now we only have one, so just set it as default.
    NSTask *linkTask = [[NSTask alloc] init];
    [linkTask setLaunchPath:@"/bin/ln"];
    [linkTask setCurrentDirectoryPath:[TKDConfiguration tokaidoAppSupportDirectory]];
    [linkTask setArguments:@[ @"-s", [@"Rubies" stringByAppendingPathComponent:[rubyName stringByAppendingPathComponent:@"bin/ruby"]], @"ruby" ] ];
    [linkTask launch];
}

- (NSString *)rubyBinDirectory:(NSString *)rubyVersion {
    return [TKDUtilities rubyBinDirectory:rubyVersion];
}


#pragma mark start/stop tokaido-bootstrap

- (void)startTokaidoBootstrap
{
    NSString *executablePath = [[TKDConfiguration tokaidoAppSupportDirectory] stringByAppendingPathComponent:@"/ruby"];
    NSString *executableDirectory = [TKDConfiguration tokaidoAppSupportDirectory];
    NSString *setupScriptPath = [[TKDConfiguration tokaidoInstalledBootstrapDirectory] stringByAppendingPathComponent:@"bundle/bundler/setup.rb"];
    NSString *tokaidoBootstrapScriptPath = [[TKDConfiguration tokaidoInstalledBootstrapDirectory] stringByAppendingPathComponent:@"bin/tokaido-bootstrap"];
    NSString *firewallPath = [TKDConfiguration tokaidoInstalledFirewallDirectory];
    NSString *outPath = [[TKDConfiguration tokaidoInstalledFirewallDirectory] stringByAppendingPathComponent:@"/bootstrap.out"];
    NSString *errPath = [[TKDConfiguration tokaidoInstalledFirewallDirectory] stringByAppendingPathComponent:@"/bootstrap.err"];
    NSString *gemHome = [TKDConfiguration tokaidoInstalledGemsDirectory];
    NSString *gemPath = [[TKDConfiguration tokaidoInstalledGemsDirectory] stringByAppendingPathComponent:@"/bin"];
    NSString *path = [executableDirectory stringByAppendingFormat:@":%@", gemPath];
    
    //unlink current socket
    unlink([[TKDConfiguration tokaidoMuxrSocketPath] UTF8String]);
    
    NSMutableDictionary *plist = [NSMutableDictionary dictionary];
    [plist setObject:kTokaidoBootstrapLabel forKey:@"Label"];
    [plist setObject:[NSNumber numberWithBool:YES] forKey:@"RunAtLoad"];
    [plist setObject:outPath forKey:@"StandardOutPath"];
    [plist setObject:errPath forKey:@"StandardErrorPath"];
    [plist setObject:[NSNumber numberWithBool:YES] forKey:@"AbandonProcessGroup"];
    [plist setObject:@{
     @"TOKAIDO_TMPDIR": firewallPath,
     @"PATH": path,
     @"GEM_HOME": gemHome,
     @"GEM_PATH": gemHome // Think we need this? Not really sure.
     }  forKey:@"EnvironmentVariables"];
    
    [plist setObject:@[ executablePath, @"-r", setupScriptPath, tokaidoBootstrapScriptPath ]
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

- (BOOL)runBundleInstallForApp:(TKDApp *)app;
{
    [app enterSubstate:TKDAppBootingBundling];

    NSString *executablePath = [[TKDConfiguration tokaidoAppSupportDirectory] stringByAppendingPathComponent:@"/ruby"];
    NSString *setupScriptPath = [[TKDConfiguration tokaidoInstalledBootstrapDirectory] stringByAppendingPathComponent:@"bundle/bundler/setup.rb"];
    NSString *bundlerPath = [[TKDConfiguration tokaidoInstalledGemsDirectory] stringByAppendingPathComponent:@"bin/bundle"];
    NSString *gemHome = [TKDConfiguration tokaidoInstalledGemsDirectory];

    NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:10];
    [arguments addObject:@"-r"];
    [arguments addObject:setupScriptPath];
    [arguments addObject:bundlerPath];
    [arguments addObject:@"install"];

    NSTask *unzipTask = [[NSTask alloc] init];
    [unzipTask setEnvironment:@{@"GEM_HOME": gemHome}];
    [unzipTask setLaunchPath:executablePath];
    [unzipTask setCurrentDirectoryPath:app.appDirectoryPath];
    [unzipTask setArguments:arguments];
    [unzipTask launch];
    [unzipTask waitUntilExit];

    if ([unzipTask terminationStatus] != 0) {
        return NO;
    }
    
    return YES;
}

@end
