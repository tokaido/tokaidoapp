//
//  TKDApp.m
//  Tokaido
//
//  Created by Mucho Besos on 10/25/12.
//  Copyright (c) 2012 Tilde. All rights reserved.
//

#import "TKDApp.h"

@implementation TKDApp

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"appName": @"name",
             @"appDirectoryPath": @"directory_path",
             @"appHostname": @"hostname",
             @"appState" : @"state",
             };
}

+ (NSValueTransformer *)stateJSONTransformer {
    NSDictionary *states = @{
                             @"off": @(TKDAppOff),
                             @"booting": @(TKDAppBooting),
                             @"on": @(TKDAppOn),
                             @"shutting_down": @(TKDAppShuttingDown)
                             };
    
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return states[str];
    } reverseBlock:^(NSNumber *state) {
        return [states allKeysForObject:state].lastObject;
    }];
}

- (void)showInFinder;
{
    [[NSWorkspace sharedWorkspace] openFile:self.appDirectoryPath];
}

@end
