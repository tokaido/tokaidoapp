//
//  TKDTokaidoController.h
//  Tokaido
//
//  Created by Mucho Besos on 10/23/12.
//  Copyright (c) 2012 Tilde. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TKDApp.h"

@interface TKDTokaidoController : NSWindowController

@property IBOutlet NSCollectionView *railsAppsView;
@property IBOutlet NSArrayController *appsArrayController;

@property (nonatomic, strong) IBOutlet NSWindow *editWindow;
@property NSMutableArray *apps;

- (IBAction)openTerminalPressed:(id)sender;
- (IBAction)addAppPressed:(id)sender;

- (void)removeApp:(id)sender;
- (void)showEditWindowForApp:(TKDApp *)app;

- (IBAction)closeEditWindow:(id)sender;
- (IBAction)saveChangesToApp:(id)sender;

@end
