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

typedef enum : NSUInteger {
    TKDAppBundling,
    TKDAppBundleFailed,
    TKDAppStartingServer
} TKDAppBootingSubstate;

@interface TKDApp : MTLModel

@property (nonatomic, copy) NSString *appName;
@property (nonatomic, copy) NSString *appDirectoryPath;
@property (nonatomic, copy) NSString *appHostname;
@property (nonatomic, copy) NSString *appIconPath;

@property (nonatomic, assign) TKDAppState state;
@property (nonatomic, assign) TKDAppBootingSubstate bootingSubstate;
@property (nonatomic, assign) BOOL usesYAMLfile;


/** 
 
 This can be used to init an TKD app instance with a directory, provided the
 directory includes a Tokaido.yaml file with the following entries:
 
 app_name: App Name
 hostname: app.local
 app_icon: ./icon.png
 
 */

- (id)initWithTokaidoDirectory:(NSURL *)url;


- (void)showInFinder;
- (void)openInBrowser;
- (void)serializeToYAML;

@end
