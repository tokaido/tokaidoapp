#import "TKDConfiguration.h"
#import "TKDFileUtilities.h"
#import "TKDAppDelegate.h"
#import "TKDTokaidoController.h"
#import "TKDTokaidoControllerHelper.h"
#import "TKDMuxrManager.h"
#import "TKDApp.h"

#import "TKDTerminalSessions.h"

@interface TKDTokaidoController ()
@property NSOpenPanel *openPanel;
@property TKDTokaidoControllerHelper *helpers;
@end

@implementation TKDTokaidoController

- (id)init {
    if (self = [super initWithWindowNibName:@"MainMenu" owner:self])
        return self;
    
    return nil;
}

- (void)windowWillClose:(NSNotification *)notification {
    TKDAppDelegate *del = (TKDAppDelegate *)[[NSApplication sharedApplication] delegate];
    
    if ([[_appsArrayController arrangedObjects] count] == 0) {
        [del.window makeKeyAndOrderFront:del.window];
        [NSApp activateIgnoringOtherApps:YES];
    }
}

- (void)awakeFromNib {
    
    self.helpers = [[TKDTokaidoControllerHelper alloc] initWithController:self];
    
    CGSize size = CGSizeMake(150, 162);
    [self.railsAppsView setMinItemSize:size];
      
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

- (IBAction)openTerminalPressed:(id)sender {
    [[TKDTerminalSessions sharedTerminalSessions] openForApplication:[self.helpers selectedApp]];
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
                newApp.appIconPath = [[[NSBundle mainBundle] URLForResource: @"TKIconRuby" withExtension:@"tiff"] absoluteString];
            }
            
            if (newApp) {
                [ac addObject:newApp];
                TKDAppDelegate *delegate = (TKDAppDelegate *)[[NSApplication sharedApplication] delegate];
                [delegate saveAppSettings];
                NSNotification *menuBarNotification = [NSNotification notificationWithName:kMenuBarNotification
                                                                                 object:nil
                                                                                  userInfo:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotification:menuBarNotification];
                });
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

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    NSNotification *menuBarNotification = [NSNotification notificationWithName:kMenuBarNotification
                                                                        object:nil
                                                                      userInfo:nil];
    
    [[NSNotificationCenter defaultCenter] postNotification:menuBarNotification];
    [sheet orderOut:self];
}

- (void)didEndLoadingSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [sheet orderOut:self];
    [self activateCubalog];
}

- (void)activateCubalog {
    [self activateApp:[self.helpers loggerApp]];
}

- (void)removeApp:(TKDApp *)app {
    [self.appsArrayController removeObject:app];
    NSLog(@"Deleted app... (%p) = %@", app, app.appDirectoryPath);
    
    TKDAppDelegate *delegate = (TKDAppDelegate *)[[NSApplication sharedApplication] delegate];
    [delegate saveAppSettings];
    
    NSNotification *menuBarNotification = [NSNotification notificationWithName:kMenuBarNotification
                                                                        object:nil
                                                                      userInfo:nil];
    
    [[NSNotificationCenter defaultCenter] postNotification:menuBarNotification];
    
    [TKDFileUtilities removeFileIfNonExistant:[[TKDConfiguration firewallInstalledDirectoryPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.tokaido.out", app.appName]]];
}

- (NSString *)appSelectionStringForCurrentCount
{
    
    return (([self.appsArrayController.arrangedObjects count] == 1) ? NSLocalizedString(@"App", nil) : NSLocalizedString(@"Apps", nil));
}

- (void)activateApp:(TKDApp *)app {
    [app enterState:TKDAppBooting];
    [[TKDMuxrManager defaultManager] addApp:app];
}

- (void)deactivateApp:(TKDApp *)app {
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
    
    NSLog(@"ACTION: %@", action);
    
    if ([action isEqualToString:@"ERR"]) {
        [app setStatus:NSLocalizedString(@"Booting failed. Review the logs or \"Open in Terminal\".", nil)];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Unable to activate app.", nil)
                                             defaultButton:@"OK"
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:NSLocalizedString(@"Booting failed. Tokaido currently uses the puma webserver. Check if `gem puma` entry is in your Gemfile and try again.", nil)];
            
            [alert runModal];
        });
    }
    
    if ([action isEqualToString:@"READY"]) {
        NSLog(@"Enabling App: %@", hostname);
        [app enterState:TKDAppOn];
    } else if ([action isEqualToString:@"FAILED"] || [action isEqualToString:@"REMOVED"] || [action isEqualToString:@"ERR"]) {
        NSLog(@"Disabling App: %@", hostname);
        [app enterState:TKDAppOff];
    }
    
}

#pragma mark Helper Methods

- (TKDApp *)appWithHostname:(NSString *)hostname {
    for (TKDApp *app in self.appsArrayController.arrangedObjects)
        if ([app.appHostname isEqualToString:hostname])
            return app;
    
    return nil;
}

- (BOOL)canAddURL:(NSURL *)url
{
    if (![self directoryContainsGemfile:url]) {
        
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Selected directory isn't a Rails app", nil)
                                         defaultButton:@"OK"
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:NSLocalizedString(@"Rails app should contain a Gemfile in the directory.", nil)];
        [alert runModal];
        
        return NO;
    }
    
    if ([self directoryAlreadyListed:url]) {
        
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Selected directory is already in Tokaido", nil)
                                         defaultButton:@"OK"
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:NSLocalizedString(@"Please choose a different directory.", nil)];
        [alert runModal];
        
        return NO;
    }
    
    return YES;
}

- (BOOL)directoryAlreadyListed:(NSURL *)url
{
    for (TKDApp *app in self.appsArrayController.arrangedObjects) {
        if ([app.appDirectoryPath isEqual:[url path]])
            return YES;
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