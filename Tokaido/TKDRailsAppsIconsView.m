//
//  TKDRailsAppsIconsView.m
//  Tokaido
//
//  Created by Mucho Besos on 10/25/12.
//  Copyright (c) 2012 Tilde. All rights reserved.
//

#import "TKDRailsAppsIconsView.h"

@implementation TKDRailsAppsIconsView

- (void)awakeFromNib
{
    NSArray *nibObjects = nil;
    [[[NSNib alloc] initWithNibNamed:@"TKDRailsAppIcon" bundle:nil] instantiateWithOwner:nil topLevelObjects:&nibObjects];
    NSView *icon = nil;
    
    for (id object in nibObjects) {
        if ([object isKindOfClass:[NSView class]]) {
            icon = object;
        }
    }
    icon.frame = NSMakeRect(0, self.bounds.size.height - icon.bounds.size.height, icon.bounds.size.width, icon.bounds.size.height);
    icon.autoresizingMask = NSViewMaxXMargin|NSViewMinYMargin;
    
    [self addSubview:icon];
}


@end
