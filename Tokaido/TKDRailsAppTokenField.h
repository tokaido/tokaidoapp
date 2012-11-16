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

@class TKDRailsAppTokenField;

@protocol TKDRailsAppTokenFieldDelegate <NSObject>
- (void)tokenField:(TKDRailsAppTokenField *)tokenField clickedWithEvent:(NSEvent *)event;
- (NSString *)titleForTokenField:(TKDRailsAppTokenField *)tokenField;
@end

@interface TKDRailsAppTokenField : NSView

@property (nonatomic, weak) id<TKDRailsAppTokenFieldDelegate> delegate;

- (void)setState:(TKDRailsAppTokenState)newState;
- (void)setTitle:(NSString *)newTitle;
- (void)configureForRepresentedObject;

@end
