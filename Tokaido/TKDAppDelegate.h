//
//  TKDAppDelegate.h
//  Tokaido
//
//  Created by Mucho Besos on 10/23/12.
//  Copyright (c) 2012 Tilde. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TKDAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

- (void)openTerminalWithPath:(NSString *)path;

@end
