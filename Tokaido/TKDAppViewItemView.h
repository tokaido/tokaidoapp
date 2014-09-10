#import <Cocoa/Cocoa.h>

@class TKDAppViewItem;
@interface TKDAppViewItemView : NSView

@property (nonatomic, weak) IBOutlet TKDAppViewItem *delegate;

@end
