//
//  TKDSelectableIcon.m
//  Tokaido
//
//  Created by Mucho Besos on 10/30/12.
//  Copyright (c) 2012 Tilde. All rights reserved.
//

#import "TKDSelectableIcon.h"

@interface TKDSelectableIcon ()

@property NSImageView *iconImageView;
@property NSImageView *backgroundImageView;

@end

@implementation TKDSelectableIcon

@synthesize selected = _selected;

- (void)awakeFromNib
{
    self.iconImageView = [[NSImageView alloc] initWithFrame:self.bounds];
    [self.iconImageView setImage:[NSImage imageNamed:@"TKIconRuby"]];
    self.backgroundImageView = [[NSImageView alloc] initWithFrame:self.bounds];
    [self.backgroundImageView setImage:[NSImage imageNamed:@"TKAppIconBackground"]];
    [self.backgroundImageView setHidden:YES];
    
    [self addSubview:self.backgroundImageView];
    [self addSubview:self.iconImageView];
}

- (void)setSelectedBackgroundImage:(NSImage *)backgroundImage;
{
    self.backgroundImageView.image = backgroundImage;
}

- (void)setIconImage:(NSImage *)iconImage;
{
    self.iconImageView.image = iconImage;
}

- (void)setSelected:(BOOL)selected
{
    if (_selected != selected) {
        [self.backgroundImageView setHidden:!selected];
        _selected = selected;
    }
    [self setNeedsDisplay:YES];
}

- (BOOL)selected
{
    return _selected;
}


@end
