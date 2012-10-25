//
//  TKDTokaidoController.m
//  Tokaido
//
//  Created by Mucho Besos on 10/23/12.
//  Copyright (c) 2012 Tilde. All rights reserved.
//

#import "TKDAppDelegate.h"
#import "TKDTokaidoController.h"

#import "TKDRailsAppsIconsView.h"

@interface TKDTokaidoController ()
@property NSOpenPanel *openPanel;
@property TKDRailsAppsIconsView *railsAppsView;
@end

@implementation TKDTokaidoController

- (IBAction)openTerminalPressed:(id)sender;
{
    TKDAppDelegate *delegate = (TKDAppDelegate *)[[NSApplication sharedApplication] delegate];
    [delegate openTerminal];
}

- (IBAction)addAppPressed:(id)sender;
{
    if (!self.openPanel) {
        self.openPanel = [NSOpenPanel openPanel];
    }
    
    [NSApp beginSheet:self.openPanel
       modalForWindow:self.window
        modalDelegate:self
       didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
          contextInfo:nil];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
    self.openPanel = nil;
}


@end
