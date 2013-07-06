//
//  TKDAppViewItemView.m
//  Tokaido
//
//  Created by Martin Schürrer on 06.07.13.
//  Copyright (c) 2013 Martin Schürrer. All rights reserved.
//

#import "TKDAppViewItemView.h"
#import "TKDAppViewItem.h"

@implementation TKDAppViewItemView

- (void)mouseDown:(NSEvent *)theEvent {
    if (theEvent.clickCount > 1) {
        // TODO: Maybe check theEvent.mouseLocation if we really only want double clicks
        // within a certain smaller area to count. Constrainting the maxItemSize of the
        // collection view already help
        [self.delegate doubleClick:self];
    }
    return [super mouseDown:theEvent];
}

@end
