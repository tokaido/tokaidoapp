//
//  TKDAppDelegate.h
//  Tokaido
//
//  Created by Mucho Besos on 10/23/12.
//  Copyright (c) 2012 Tilde. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TKDTokaidoController.h"

@interface TKDAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) IBOutlet TKDTokaidoController *tokaidoController;


- (NSString *)rubyBinDirectory:(NSString *)rubyVersion;

- (void)loadAppSettings;
- (void)saveAppSettings;

@end
