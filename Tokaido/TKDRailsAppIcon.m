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
    
    [self.showInFinderMenuItem setTarget:self.representedObject];
    [self.showInFinderMenuItem setAction:@selector(showInFinder)];
    
    [self.editMenuItem setTarget:self];
    [self.editMenuItem setAction:@selector(editApp)];
    
    [self.removeMenuItem setTarget:self];
    [self.removeMenuItem setAction:@selector(removeApp)];

    TKDApp *app = self.appController.content;    
    [self.tokenField setTitle:app.appHostname];
    self.tokenField.delegate = self;
}

- (void)tokenField:(TKDRailsAppTokenField *)tokenField clickedWithEvent:(NSEvent *)event;
{
    [NSMenu popUpContextMenu:self.appMenu withEvent:event forView:self.view];
}

- (void)editApp
{
    [self.tokaidoController showEditWindowForApp:self.representedObject];
}

- (void)removeApp
{
    [self.tokaidoController removeApp:self.representedObject];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self.appIcon setSelected:selected];
}

@end
