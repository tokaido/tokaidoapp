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

#import "TKDStopTokaido.h"

@implementation TKDAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  [self loadAppSettings];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

-(void) starting_shutting_down_tokaido_bootstrap {
  NSLog(@"Shutting tokaido-bootstrap down.");
}

-(void) finished_tokaido_boostrap_shutdown {
   NSLog(@"tokaido-bootstrap off.");
}

- (void)applicationWillTerminate:(NSNotification *)notification {
  [[[TKDStopTokaido alloc] initWithView:(id)self] execute];
}


#pragma mark App Settings

- (void)loadAppSettings
{
    NSString *appSettingsPath = [TKDConfiguration applicationSettingsDirectoryPath];
    
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
        self.tokaidoController.apps = [[NSMutableArray alloc] init];
        NSLog(@"ERROR: Could not load app settings.");
    }
}

- (void)saveAppSettings
{
    NSString *appSettingsPath = [TKDConfiguration applicationSettingsDirectoryPath];
    BOOL success = [NSKeyedArchiver archiveRootObject:self.tokaidoController.apps toFile:appSettingsPath];
    if (!success) {
        NSLog(@"ERROR: Couldn't save app settings.");
    }
}

#pragma mark Helper Methods

- (void)installRubyWithName:(NSString *)rubyName
{
    NSString *fullPathToRubyZip = [[TKDConfiguration rubiesBundledDirectoryPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", rubyName]];
    [TKDFileUtilities unzipFileAtPath:fullPathToRubyZip inDirectoryPath:[TKDConfiguration rubiesInstalledDirectoryPath]];
        
    // We need a better way to decide what the default ruby should be. Right now we only have one, so just set it as default.
    NSTask *linkTask = [[NSTask alloc] init];
    [linkTask setLaunchPath:@"/bin/ln"];
    [linkTask setCurrentDirectoryPath:[TKDConfiguration applicationSupportDirectoryPath]];
    [linkTask setArguments:@[ @"-s", [@"Rubies" stringByAppendingPathComponent:[rubyName stringByAppendingPathComponent:@"bin/ruby"]], @"ruby" ] ];
    [linkTask launch];
}

- (NSString *)rubyBinDirectory:(NSString *)rubyVersion {
    return [TKDUtilities rubyBinDirectory:rubyVersion];
}

- (BOOL)runBundleInstallForApp:(TKDApp *)app;
{
    [app enterSubstate:TKDAppBootingBundling];

    NSString *executablePath = [TKDConfiguration rubyExecutableInstalledFile];
    NSLog(@"%@", executablePath);
    NSString *setupScriptPath = [TKDConfiguration setupScriptGemsInstalledFile];
    NSLog(@"%@", setupScriptPath);
    NSString *bundlerPath = [TKDConfiguration gemsBundlerInstalledDirectoryPath];
    NSLog(@"%@", bundlerPath);
    NSString *gemHome = [TKDConfiguration gemsInstalledDirectoryPath];
    NSLog(@"%@", gemHome);

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
