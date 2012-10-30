//
//  TKDRailsAppIcon.m
//  Tokaido
//
//  Created by Mucho Besos on 10/26/12.
//  Copyright (c) 2012 Tilde. All rights reserved.
//

#import "TKDRailsAppIcon.h"

@interface TKDRailsAppIcon ()
@end

@implementation TKDRailsAppIcon

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.appController.content = self.representedObject;
}


- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self.appIcon setSelected:selected];
}

@end
