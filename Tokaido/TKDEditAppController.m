//
//  TKDEditAppController.m
//  Tokaido
//
//  Created by Patrick B. Gibson on 4/8/13.
//  Copyright (c) 2013 Tilde. All rights reserved.
//

#import <Quartz/Quartz.h>

#import "TKDEditAppController.h"
#import "TKDAppDelegate.h"

@interface TKDEditAppController ()
@property (nonatomic, copy) NSString *prevAppName;
@property (nonatomic, copy) NSString *prevHostname;
@property (nonatomic, copy) NSString *prevAppIconPath;
@property (nonatomic, assign) BOOL prevUsesYAML;
@end

@implementation TKDEditAppController

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    self.prevAppIconPath = self.app.appIconPath;
    self.prevAppName = self.app.appName;
    self.prevHostname = self.app.appHostname;
    self.prevUsesYAML = self.app.usesYAMLfile;
    
}

- (IBAction)chooseImagePressed:(id)sender;
{
    IKPictureTaker *pictureTaker = [IKPictureTaker pictureTaker];
    
    [pictureTaker beginPictureTakerSheetForWindow:self.window
                                     withDelegate:self
                                   didEndSelector:@selector(pictureTakerDidEnd:returnCode:contextInfo:)
                                      contextInfo:nil];
}

- (void)pictureTakerDidEnd:(IKPictureTaker *)pictureTaker returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
{
    self.appImageView.image = [pictureTaker outputImage];
}

- (IBAction)savePressed:(id)sender;
{
    // If we're using the YAML file, write changes to it.
    if (self.app.usesYAMLfile) {
        [self.app serializeToYAML];
    }
    
    // Save our own settings.
    TKDAppDelegate *delegate = (TKDAppDelegate *)[[NSApplication sharedApplication] delegate];
    [delegate saveAppSettings];
    
    [NSApp endSheet:self.window];
}

- (IBAction)cancelPressed:(id)sender;
{
    self.app.appIconPath = self.prevAppIconPath;
    self.app.appName = self.prevAppName;
    self.app.appHostname = self.prevHostname;
    self.app.usesYAMLfile = self.prevUsesYAML;
    
    [NSApp endSheet:self.window];
}

@end
