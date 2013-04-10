//
//  TKDEditAppController.h
//  Tokaido
//
//  Created by Patrick B. Gibson on 4/8/13.
//  Copyright (c) 2013 Tilde. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TKDApp.h"

@interface TKDEditAppController : NSWindowController

@property (nonatomic, strong) TKDApp *app;

@property (nonatomic, strong) IBOutlet NSImageView *appImageView;
@property (nonatomic, strong) IBOutlet NSTextField *appNameField;
@property (nonatomic, strong) IBOutlet NSTextField *hostnameField;
@property (nonatomic, strong) IBOutlet NSButton *usesYamlButton;

- (IBAction)savePressed:(id)sender;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)chooseImagePressed:(id)sender;

@end
