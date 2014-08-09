#import <Cocoa/Cocoa.h>

#import "TKDApp.h"

@class TKDRailsAppTokenField;

@protocol TKDRailsAppTokenFieldDelegate <NSObject>
- (void)tokenField:(TKDRailsAppTokenField *)tokenField clickedWithEvent:(NSEvent *)event;
- (NSString *)titleForTokenField:(TKDRailsAppTokenField *)tokenField;
- (TKDApp *)app;
@end

@interface TKDRailsAppTokenField : NSView

@property (nonatomic, weak) id<TKDRailsAppTokenFieldDelegate> delegate;

- (void)setState:(TKDAppState)newState;
- (void)setTitle:(NSString *)newTitle;
- (void)configureForRepresentedObject;

@end
