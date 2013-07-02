//
//  TKDApp.m
//  Tokaido
//
//  Created by Mucho Besos on 10/25/12.
//  Copyright (c) 2012 Tilde. All rights reserved.
//

#import "TKDApp.h"
#import "TKDAppDelegate.h"
#import <YAML-Framework/YAMLSerialization.h>

static NSString *kAppNameKey = @"app_name";
static NSString *kHostnameKey = @"hostname";
static NSString *kAppIconKey = @"app_icon";

@implementation TKDApp

- (id)init
{
    self = [super init];
    if (self) {
        self.usesYAMLfile = NO;
    }
    return self;
}

+ (NSDictionary *)YAMLKeyPathsByPropertyKey {
    return @{
             @"appName": @"app_name",
             @"appHostname": @"app_hostname",
             @"appIconPath" : @"app_icon_path"
             };
}


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"appName": @"app_name",
             @"appDirectoryPath": @"directory_path",
             @"appHostname": @"app_hostname",
             @"appState" : @"app_state",
             @"appIconPath" : @"app_icon_path"
             };
}

+ (NSValueTransformer *)stateJSONTransformer {
    NSDictionary *states = @{
                             @"off":            @(TKDAppOff),
                             @"booting":        @(TKDAppBooting),
                             @"on":             @(TKDAppOn),
                             @"shutting_down":  @(TKDAppShuttingDown)
                             };
    
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return states[str];
    } reverseBlock:^(NSNumber *state) {
        return [states allKeysForObject:state].lastObject;
    }];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

    if ([key isEqualToString:@"stateMessage"]) {
        keyPaths = [keyPaths setByAddingObjectsFromArray:@[@"state", @"substate"]];
    } else if ([key isEqualToString:@"needsStateChange"]) {
        keyPaths = [keyPaths setByAddingObjectsFromArray:@[@"state"]];
    } else if ([key isEqualToString:@"stateChangeString"]) {
        keyPaths = [keyPaths setByAddingObjectsFromArray:@[@"state"]];
    }

    return keyPaths;
}

- (id)initWithTokaidoDirectory:(NSURL *)tokaidoAppURL;
{
    self = [super init];
    if (self) {
        NSData *yamlData = [NSData dataWithContentsOfURL:[tokaidoAppURL URLByAppendingPathComponent:@"Tokaido.yaml"]];
        NSError *error = nil;
        NSMutableArray *tokaidoYAML = [YAMLSerialization YAMLWithData:yamlData
                                                       options:kYAMLReadOptionStringScalars
                                                         error:&error];
        
        if (error) {
            NSLog(@"ERROR: Couldn't load Tokaido.yaml file: %@", [error localizedDescription]);
            return nil;
        } else {
            NSDictionary *appDictionary = [tokaidoYAML objectAtIndex:0];
            
            self.appName = [appDictionary objectForKey:kAppNameKey];
            if (!self.appName) {
                self.appName = @"Undefined";
            }
            
            self.appHostname = [appDictionary objectForKey:kHostnameKey];
            if (!self.appHostname) {
                self.appHostname = @"Undefined.tokaido";
            }
            
            self.appDirectoryPath = [tokaidoAppURL path];
            self.appIconPath = [appDictionary objectForKey:kAppIconKey];
            self.usesYAMLfile = YES;
        }
        
    }
    return self;
}

- (NSString *)stateMessage {
    NSMapTable *substates = [NSMapTable new];
    [substates setObject:@"Running bundle install" forKey:[NSNumber numberWithInt:TKDAppBootingBundling]];
    [substates setObject:@"bundle install failed" forKey:[NSNumber numberWithInt:TKDAppBootingBundleFailed]];
    [substates setObject:@"Booting server" forKey:[NSNumber numberWithInt:TKDAppBootingStartingServer]];

    if (self.state == TKDAppBooting) {
        return [substates objectForKey:[NSNumber numberWithInt:self.substate]];
    } else if (self.state == TKDAppOff) {
        NSString *failureReason = self.failureReason;

        if (failureReason == nil) {
            return @"Not started";
        } else {
            return failureReason;
        }
    } else if (self.state == TKDAppOn) {
        return @"Started";
    } else if (self.state == TKDAppShuttingDown) {
        return @"Shutting Down";
    } else {
        return nil;
    }
}

- (NSString *)stateChangeString {
    if (self.state == TKDAppOn) {
        return @"Shut Down";
    } else if (self.state == TKDAppOff) {
        return @"Boot App";
    } else {
        return nil;
    }
}

- (bool)needsStateChange {
    return self.state == TKDAppOff || self.state == TKDAppOn;
}

- (void)enterSubstate:(TKDAppSubstate)substate;
{
    self.substate = substate;

    if (substate == TKDAppBootingBundleFailed) {
        self.failureReason = @"Bundling failed. Try \"Open in Terminal\".";
    }
}

- (void)showInFinder;
{
    [[NSWorkspace sharedWorkspace] openFile:self.appDirectoryPath];
}

- (void)openInBrowser;
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@", self.appHostname];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
}

- (void)serializeToYAML;
{
    NSMutableDictionary *yamlDictionary = [NSMutableDictionary dictionaryWithCapacity:10];
    NSDictionary *keys = [TKDApp YAMLKeyPathsByPropertyKey];
    NSError *error = nil;
    
    for (NSString *key in [keys allKeys]) {
        NSString *yamlKeyName = [keys valueForKey:key];
        [yamlDictionary setValue:[self valueForKey:key] forKey:yamlKeyName];
    }
    
    NSData *yamlData = [YAMLSerialization dataFromYAML:yamlDictionary
                                               options:kYAMLWriteOptionSingleDocument
                                                 error:&error];
    
    if (error) {
        NSLog(@"ERROR: Couldn't form YAML data from TKDApp: %@", [error localizedDescription]);
        return;
    }
    
    BOOL success = [yamlData writeToFile:[self.appDirectoryPath stringByAppendingPathComponent:@"/Tokaido.yaml"]
                              atomically:YES];
    
    if (!success) {
        NSLog(@"ERROR: Couldn't write YAML file.");
    }
}

- (BOOL)runBundleInstall {
    [self enterSubstate:TKDAppBootingBundling];

    NSString *executablePath = [[TKDAppDelegate tokaidoAppSupportDirectory] stringByAppendingPathComponent:@"/ruby"];
    NSString *setupScriptPath = [[TKDAppDelegate tokaidoInstalledBootstrapDirectory] stringByAppendingPathComponent:@"bundle/bundler/setup.rb"];
    NSString *bundlerPath = [[TKDAppDelegate tokaidoInstalledGemsDirectory] stringByAppendingPathComponent:@"bin/bundle"];
    NSString *gemHome = [TKDAppDelegate tokaidoInstalledGemsDirectory];

    NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:10];
    [arguments addObject:@"-r"];
    [arguments addObject:setupScriptPath];
    [arguments addObject:bundlerPath];
    [arguments addObject:@"install"];

    NSTask *unzipTask = [[NSTask alloc] init];
    [unzipTask setEnvironment:@{@"GEM_HOME": gemHome}];
    [unzipTask setLaunchPath:executablePath];
    [unzipTask setCurrentDirectoryPath:self.appDirectoryPath];
    [unzipTask setArguments:arguments];
    [unzipTask launch];
    [unzipTask waitUntilExit];

    if ([unzipTask terminationStatus] != 0) {
        return NO;
    }

    return YES;
}

@end
