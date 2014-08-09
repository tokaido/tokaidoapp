#import "TKDAppViewItemView.h"
#import "TKDAppViewItem.h"

@implementation TKDAppViewItemView

- (void)mouseDown:(NSEvent *)theEvent {
    if (theEvent.clickCount > 1)
        [self.delegate doubleClick:self];
    return [super mouseDown:theEvent];
}

@end
