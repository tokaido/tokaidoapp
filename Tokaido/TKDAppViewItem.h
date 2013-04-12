//
//  TKDRailsAppIcon.h
//  Tokaido
//
//  Created by Mucho Besos on 10/26/12.
//  Copyright (c) 2012 Tilde. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TKDTokaidoController.h"

#import "TKDApp.h"
#import "TKDSelectableIcon.h"
#import "TKDRailsAppTokenField.h"

@interface TKDAppViewItem : NSCollectionViewItem <TKDRailsAppTokenFieldDelegate>

@property (nonatomic, weak) IBOutlet TKDTokaidoController *tokaidoController;

@property (nonatomic, strong) IBOutlet NSObjectController *appController;
@property (nonatomic, strong) IBOutlet TKDSelectableIcon *appIcon;
@property (nonatomic, strong) IBOutlet TKDRailsAppTokenField *tokenField;

@property (nonatomic, strong) IBOutlet NSMenu *appMenu;

@property (nonatomic, strong) IBOutlet NSMenuItem *activatedMenuItem;
@property (nonatomic, strong) IBOutlet NSMenuItem *shouldActivateOnLaunchMenuItem;

@property (nonatomic, strong) IBOutlet NSMenuItem *showInFinderMenuItem;

@property (nonatomic, strong) IBOutlet NSMenuItem *editMenuItem;
@property (nonatomic, strong) IBOutlet NSMenuItem *removeMenuItem;

@property (nonatomic, readonly) TKDApp *app;

@end
