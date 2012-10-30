//
//  TKDSelectableIcon.h
//  Tokaido
//
//  Created by Mucho Besos on 10/30/12.
//  Copyright (c) 2012 Tilde. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TKDSelectableIcon : NSControl

@property (assign) BOOL selected;

- (void)setSelectedBackgroundImage:(NSImage *)backgroundImage;
- (void)setIconImage:(NSImage *)iconImage;

@end
