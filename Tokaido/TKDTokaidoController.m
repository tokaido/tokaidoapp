//
//  TKDTokaidoController.m
//  Tokaido
//
//  Created by Mucho Besos on 10/23/12.
//  Copyright (c) 2012 Tilde. All rights reserved.
//

#import "TKDAppDelegate.h"
#import "TKDTokaidoController.h"

#import "TKDApp.h"

@interface TKDTokaidoController ()
@property NSOpenPanel *openPanel;
@end

@implementation TKDTokaidoController

- (void)awakeFromNib
{
    self.apps = [[NSMutableArray alloc] init];
    CGSize size = CGSizeMake(150, 162);
    [self.railsAppsView setMinItemSize:size];
//    [self.railsAppsView setMaxItemSize:size];

}

- (IBAction)openTerminalPressed:(id)sender;
{
    TKDAppDelegate *delegate = (TKDAppDelegate *)[[NSApplication sharedApplication] delegate];
    
    if ([self.appsArrayController.selectedObjects count] > 0) {
        TKDApp *selectedApp = [self.appsArrayController.selectedObjects objectAtIndex:0];
        [delegate openTerminalWithPath:selectedApp.appDirectoryPath];
    }

}

- (IBAction)addAppPressed:(id)sender;
{
    if (!self.openPanel) {
        self.openPanel = [NSOpenPanel openPanel];
        [self.openPanel setCanChooseDirectories:YES];
        [self.openPanel setCanChooseFiles:NO];
        [self.openPanel setCanCreateDirectories:NO];
        [self.openPanel setAllowsMultipleSelection:NO];
    }
    
    NSArrayController *ac = self.appsArrayController;
    
    [self.openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {                               
       NSURL *chosenURL = [self.openPanel URL];
       
       if ((result == NSFileHandlingPanelOKButton && chosenURL) && [self canAddURL:chosenURL]) {
            TKDApp *newApp = [[TKDApp alloc] init];
            newApp.appName = [chosenURL lastPathComponent];
            newApp.appDirectoryPath = [chosenURL path];
            newApp.appHostname = [[newApp.appName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByAppendingString:@".tokaido"];

            [ac addObject:newApp];
            TKDAppDelegate *delegate = (TKDAppDelegate *)[[NSApplication sharedApplication] delegate];
            [delegate saveAppSettings];
       }
   }];
}

- (void)showEditWindowForApp:(TKDApp *)app
{
    // Configure edit window here...
    
    [NSApp beginSheet:self.editWindow
       modalForWindow:self.window
        modalDelegate:self
       didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
          contextInfo:nil];
}

- (IBAction)closeEditWindow:(id)sender;
{
    [NSApp endSheet:self.editWindow];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
}

- (IBAction)saveChangesToApp:(id)sender;
{
    [self closeEditWindow:sender];
}


- (void)removeApp:(TKDApp *)app;
{
    [self.appsArrayController removeObject:app];
    TKDAppDelegate *delegate = (TKDAppDelegate *)[[NSApplication sharedApplication] delegate];
    [delegate saveAppSettings];
}

- (BOOL)canAddURL:(NSURL *)url
{
    if (![self directoryContainsGemfile:url]) {
        
        NSAlert *alert = [NSAlert alertWithMessageText:@"Selected directory isn't a Rails app"
                                         defaultButton:@"OK"
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@"Rails app should contain a Gemfile in the directory."];
        [alert runModal];
        
        return NO;
    }
    
    if ([self directoryAlreadyListed:url]) {
        
        NSAlert *alert = [NSAlert alertWithMessageText:@"Selected directory is already in Tokaido"
                                         defaultButton:@"OK"
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@"Please choose a different directory."];
        [alert runModal];
        
        return NO;
    }
    
    return YES;
}

- (BOOL)directoryContainsGemfile:(NSURL *)url
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *gemfilePath = [[url path] stringByAppendingPathComponent:@"Gemfile"];
    return [fm fileExistsAtPath:gemfilePath];
}

- (BOOL)directoryAlreadyListed:(NSURL *)url
{
    for (TKDApp *app in self.apps) {
        if ([app.appDirectoryPath isEqual:[url path]]) {
            return YES;
        }
    }
    return NO;
}

@end
