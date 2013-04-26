//
//  TKDApp.m
//  Tokaido
//
//  Created by Mucho Besos on 10/25/12.
//  Copyright (c) 2012 Tilde. All rights reserved.
//

#import "TKDApp.h"
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

@end
