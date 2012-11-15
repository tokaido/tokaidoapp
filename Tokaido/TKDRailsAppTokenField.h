//
//  TKDRailsAppTokenField.h
//  Tokaido
//
//  Created by Patrick B. Gibson on 11/15/12.
//  Copyright (c) 2012 Tilde. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
    TKDRailsAppTokenStateActivated = 0,
    TKDRailsAppTokenStateWorking,
    TKDRailsAppTokenStateDeactivated
} TKDRailsAppTokenState;

@interface TKDRailsAppTokenField : NSView

- (void)setState:(TKDRailsAppTokenState)newState;
- (void)setTitle:(NSString *)newTitle;

@end
