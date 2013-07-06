//
//  TKDTokaidoController.m
//  Tokaido
//
//  Created by Mucho Besos on 10/23/12.
//  Copyright (c) 2012 Tilde. All rights reserved.
//

#import "TKDAppDelegate.h"
#import "TKDTokaidoController.h"
#import "TKDMuxrManager.h"
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
    [self.railsAppsView setMaxItemSize:size];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMuxrEvent:) name:kMuxrNotification object:nil];
}

- (void)toggleApp:(TKDApp *)app;
{
    if (app.state == TKDAppOn) {
        [self deactivateApp:app];
    } else if (app.state == TKDAppOff) {
        [self activateApp:app];
    } else if (app.state == TKDAppBooting) {
        [self deactivateApp:app];
    } else {
        NSAssert(false, @"should never be reached");
    }
}

- (IBAction)openTerminalPressed:(id)sender;
{
    TKDAppDelegate *delegate = (TKDAppDelegate *)[[NSApplication sharedApplication] delegate];
    NSString *path;
    
    if ([self.appsArrayController.selectedObjects count] > 0) {
        TKDApp *selectedApp = [self.appsArrayController.selectedObjects objectAtIndex:0];
        path = selectedApp.appDirectoryPath;
    } else {
        path = NSHomeDirectory();
    }

    [delegate openTerminalWithPath:path];
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
           TKDApp *newApp = nil;
           
           if ([self directoryContainsTokaidoYAMLFile:chosenURL]) {
               newApp = [[TKDApp alloc] initWithTokaidoDirectory:chosenURL];
           } else {
               newApp = [[TKDApp alloc] init];
               newApp.appName = [chosenURL lastPathComponent];
               newApp.appDirectoryPath = [chosenURL path];
               newApp.appHostname = [[newApp.appName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByAppendingString:@".tokaido"];
           }
           
           if (newApp) {
               [ac addObject:newApp];
               TKDAppDelegate *delegate = (TKDAppDelegate *)[[NSApplication sharedApplication] delegate];
               [delegate saveAppSettings];
           }
       }
   }];
}

- (void)showEditWindowForApp:(TKDApp *)app
{
    self.editAppController = [[TKDEditAppController alloc] initWithWindowNibName:@"EditAppWindow"];
    self.editAppController.app = app;
    
    [NSApp beginSheet:self.editAppController.window
       modalForWindow:self.window
        modalDelegate:self
       didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
          contextInfo:nil];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
}


- (void)removeApp:(TKDApp *)app;
{
    [self.appsArrayController removeObject:app];
    TKDAppDelegate *delegate = (TKDAppDelegate *)[[NSApplication sharedApplication] delegate];
    [delegate saveAppSettings];
}

- (NSString *)appSelectionStringForCurrentCount
{
    
    return (([self.appsArrayController.arrangedObjects count] == 1) ? @"App" : @"Apps");
}

- (void)activateApp:(TKDApp *)app;
{
    [app enterState:TKDAppBooting];
    [[TKDMuxrManager defaultManager] addApp:app];
}

- (void)deactivateApp:(TKDApp *)app;
{
    [app enterState:TKDAppShuttingDown];
    [[TKDMuxrManager defaultManager] removeApp:app];
}

#pragma mark NSNotification Handlers
- (void)handleMuxrEvent:(NSNotification *)note
{    
    NSMutableString *hostname = [[[note userInfo] objectForKey:@"hostname"] mutableCopy];
    [hostname replaceOccurrencesOfString:@"\""
                              withString:@""
                                 options:NSCaseInsensitiveSearch
                                   range:NSMakeRange(0, [hostname length])];
    [hostname replaceOccurrencesOfString:@"\n"
                              withString:@""
                                 options:NSCaseInsensitiveSearch
                                   range:NSMakeRange(0, [hostname length])];
    
    
    TKDApp *app = [self appWithHostname:hostname];
    
    // Check the event here and do the right thing.
    
    NSString *action = [[note userInfo] objectForKey:@"action"];
    if ([action isEqualToString:@"READY"]) {
        NSLog(@"Enabling App: %@", hostname);
        [app enterState:TKDAppOn];
    } else if ([action isEqualToString:@"FAILED"] || [action isEqualToString:@"REMOVED"]) {
        NSLog(@"Disabling App: %@", hostname);
        [app enterState:TKDAppOff];
    }
    
}

#pragma mark Helper Methods

- (TKDApp *)appWithHostname:(NSString *)hostname
{
    for (TKDApp *app in self.apps) {
        if ([app.appHostname isEqualToString:hostname]) {
            return app;
        }
    }
    
    return nil;
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

- (BOOL)directoryAlreadyListed:(NSURL *)url
{
    for (TKDApp *app in self.apps) {
        if ([app.appDirectoryPath isEqual:[url path]]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)directoryContainsGemfile:(NSURL *)url
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *gemfilePath = [[url path] stringByAppendingPathComponent:@"Gemfile"];
    return [fm fileExistsAtPath:gemfilePath];
}

- (BOOL)directoryContainsTokaidoYAMLFile:(NSURL *)url
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *tokaidoFilePath = [[url path] stringByAppendingPathComponent:@"Tokaido.yaml"];
    return [fm fileExistsAtPath:tokaidoFilePath];
}

@end
