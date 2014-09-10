#import <Cocoa/Cocoa.h>
#import "TKDApp.h"

@class TKDSelectableIcon;

@protocol TKDSelectableIconDelegate <NSObject>
- (NSString *)pathForIcon:(TKDSelectableIcon *)icon;
- (TKDApp *)app;
@end

@interface TKDSelectableIcon : NSControl

@property (assign) BOOL selected;

- (void)setSelectedBackgroundImage:(NSImage *)backgroundImage;
- (void)setIconImageWithString:(NSString *)path;

- (void)configureForRepresentedObject;

@property (nonatomic, weak) id<TKDSelectableIconDelegate> delegate;

@end
