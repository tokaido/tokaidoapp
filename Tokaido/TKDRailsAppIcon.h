//
//  TKDRailsAppIcon.h
//  Tokaido
//
//  Created by Mucho Besos on 10/26/12.
//  Copyright (c) 2012 Tilde. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TKDApp.h"

#import "TKDSelectableIcon.h"


@interface TKDRailsAppIcon : NSCollectionViewItem

@property (readwrite) BOOL selected;

@property (nonatomic, strong) IBOutlet NSObjectController *appController;
@property (nonatomic, strong) IBOutlet TKDSelectableIcon *appIcon;

@end
