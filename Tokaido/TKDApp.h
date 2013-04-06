//
//  TKDApp.h
//  Tokaido
//
//  Created by Mucho Besos on 10/25/12.
//  Copyright (c) 2012 Tilde. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum : NSUInteger {
    TKDAppOff,
    TKDAppBooting,
    TKDAppOn,
    TKDAppShuttingDown
} TKDAppState;

@interface TKDApp : MTLModel

@property (nonatomic, strong) NSString *appName;
@property (nonatomic, strong) NSString *appDirectoryPath;
@property (nonatomic, strong) NSString *appHostname;
@property (nonatomic, assign) TKDAppState state;

- (void)showInFinder;

@end
