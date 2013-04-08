//
//  TKDEditAppController.m
//  Tokaido
//
//  Created by Patrick B. Gibson on 4/8/13.
//  Copyright (c) 2013 Tilde. All rights reserved.
//

#import "TKDEditAppController.h"

@interface TKDEditAppController ()

@end

@implementation TKDEditAppController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    self.appImageView.image = [NSImage imageNamed:@"TKIconRuby.png"];
    [self.appNameField setStringValue:self.app.appName];
    [self.hostnameField setStringValue:self.app.appHostname];
    self.app.usesYAMLfile ? [self.usesYamlButton setState:NSOnState] : [self.usesYamlButton setState:NSOffState];
    
}

- (IBAction)saveChangesToApp:(id)sender;
{
    [NSApp endSheet:self.window];
}

- (IBAction)closeEditWindow:(id)sender
{
    [NSApp endSheet:self.window];
}

@end
