#import "TKDAppDelegate.h"
#import "TKDUtilities.h"
#import "Terminal.h"
#import "TKDConfiguration.h"
#import "TKDFileUtilities.h"
#import "TKDTerminalSessions.h"

#import "TKDEnsureAppSupportUpdated.h"
#import "TKDEnsureTokaidoInstallIsInstalled.h"
#import "TKDEnsureTokaidoBootstrapIsInstalled.h"
#import "TKDStopTokaido.h"
#import "TKDStartTokaido.h"

#import "TKDApp.h"
#import "TKDPostgresApp.h"

NSString * const kMenuBarNotification = @"kMenuBarNotification";

@interface TKDAppDelegate()
@property NSOpenPanel *openPanel;
@end

@implementation TKDAppDelegate

- (void) home:(id) sender {
    [self.window makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification {
    if (!_tokaidoController.window.visible) {
        [self.window makeKeyAndOrderFront:self];
        [NSApp activateIgnoringOtherApps:YES];
    }
}

-(void) openTerminal:(id) sender {
    [[TKDTerminalSessions sharedTerminalSessions] open];
}

-(void) add:(id)sender {
    
    if (!self.openPanel) {
        self.openPanel = [NSOpenPanel openPanel];
    
        [self.openPanel setCanChooseDirectories:YES];
        [self.openPanel setCanChooseFiles:NO];
        [self.openPanel setCanCreateDirectories:NO];
        [self.openPanel setAllowsMultipleSelection:NO];
    }
        
    [self.openPanel beginWithCompletionHandler:^(NSInteger result) {
        NSURL *chosenURL = [self.openPanel URL];
        
        if ((result == NSFileHandlingPanelOKButton && chosenURL) && [self canAddURL:chosenURL]) {
            TKDApp *newApp = nil;
            
            newApp = [[TKDApp alloc] init];
            newApp.appName = [chosenURL lastPathComponent];
            newApp.appDirectoryPath = [chosenURL path];
            newApp.appHostname = [[newApp.appName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByAppendingString:@".tokaido"];
            newApp.appIconPath = [[[NSBundle mainBundle] URLForResource: @"TKIconRuby" withExtension:@"tiff"] absoluteString];
            
            [(TKDAppDelegate *) [[NSApplication sharedApplication] delegate] record:chosenURL];
        }
    }];
}

-(void)record:(NSURL *)chosenURL {
    TKDApp *newApp = [[TKDApp alloc] init];
    newApp.appName = [chosenURL lastPathComponent];
    newApp.appDirectoryPath = [chosenURL path];
    newApp.appHostname = [[newApp.appName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByAppendingString:@".tokaido"];
    newApp.appIconPath = [[[NSBundle mainBundle] URLForResource: @"TKIconRuby" withExtension:@"tiff"] absoluteString];
    
    [self.apps addObject:newApp];
    [self saveAppSettings];
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


-(void) menuBar {
    NSMenu *tkdMenu = [[NSMenu alloc] init];
    
    [tkdMenu addItemWithTitle:@"Home" action:@selector(home:) keyEquivalent:@"H"];
    [tkdMenu addItem:[NSMenuItem separatorItem]];
    
    
    NSMenuItem *totalApps = [[NSMenuItem alloc] init];
    totalApps.enabled = NO;
    
    if ([self.apps count] == 0)
        [tkdMenu addItem:[NSMenuItem separatorItem]];
    else {
        for (TKDApp *tkdApp in self.apps)
            [tkdMenu addItemWithTitle:tkdApp.appName action:@selector(edit:) keyEquivalent:@""];
    
        [tkdMenu addItem:[NSMenuItem separatorItem]];
    }
    
    [tkdMenu addItemWithTitle:@"Manage Apps..." action:@selector(manage:) keyEquivalent:@"A"];
    [tkdMenu addItemWithTitle:@"Open Terminal..." action:@selector(openTerminal:) keyEquivalent:@"T"];
    [tkdMenu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem *rubyVersion = [[NSMenuItem alloc] init];
    rubyVersion.title = [NSString stringWithFormat:@"Using Ruby %@", [TKDConfiguration rubyVersion]];
    rubyVersion.enabled = NO;
    
    NSMenuItem *postgresApp = [[NSMenuItem alloc] init];
    
    NSMutableString *postgresAppReport = [[NSMutableString alloc] initWithString:@"Postgres.app "];
    
    if ([TKDPostgresApp isInstalled]) {
        [postgresAppReport appendString:[TKDPostgresApp latestVersion]];
        
        if ([TKDUtilities isAppRunning:@"com.postgresapp.Postgres"])
            [postgresAppReport appendString:@" running"];
        else
            [postgresAppReport appendString:@" installed"];
    } else
        [postgresAppReport appendString:@"not installed"];
    
    
    postgresApp.title = postgresAppReport;
    postgresApp.enabled = NO;
    
    [tkdMenu addItem:rubyVersion];
    [tkdMenu addItem:postgresApp];
    
    _statusItem.menu = tkdMenu;
}

#pragma mark NSNotification Handlers
- (void)handleMenuBarEvent:(NSNotification *)note  {
    [self menuBar];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.title = @"";
    _statusItem.image = [NSImage imageNamed:@"TKIconRubyStatusBar"];
    
    NSNib *tokaidoControllerNibs = [[NSNib alloc] initWithNibNamed:@"MainWindow" bundle:[NSBundle mainBundle]];
    [tokaidoControllerNibs instantiateWithOwner:self topLevelObjects:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuBarEvent:) name:kMenuBarNotification object:nil];
    
    [self loadAppSettings];
    [self menuBar];
    
    if ([self.apps count] == 0)
        [self.window makeKeyAndOrderFront:self];
}

-(void) manage:(id) sender {
    [self.tokaidoController.window makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return NO;
}

-(void) starting_shutting_down_tokaido_bootstrap {
    NSLog(@"Shutting tokaido-bootstrap down.");
}

-(void) finished_tokaido_boostrap_shutdown {
    NSLog(@"tokaido-bootstrap off.");
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    for (TKDApp *app in self.apps)
        [app enterState:TKDAppOff];
    
    [self saveAppSettings];
    [[[TKDStopTokaido alloc] initWithView:(id)self] execute];
}


#pragma mark App Settings

- (void)loadAppSettings {
    NSString *appSettingsPath = [TKDConfiguration tokaidoApplicationsConfigurations];
    
    NSMutableArray *savedApps;
    
    @try {
        savedApps = [NSKeyedUnarchiver unarchiveObjectWithFile:appSettingsPath];
    }
    @catch (NSException *exception) {
        NSLog(@"ERROR: Couldn't load app settings: %@", exception);
    }
    
    if (savedApps) {
        self.apps = savedApps;
    } else {
        self.apps = [[NSMutableArray alloc] init];
        NSLog(@"ERROR: Could not load app settings.");
    }
}

- (void)saveAppSettings {
    NSString *appSettingsPath = [TKDConfiguration tokaidoApplicationsConfigurations];

    BOOL success = [NSKeyedArchiver archiveRootObject:self.apps toFile:appSettingsPath];
    
    if (!success)
        NSLog(@"ERROR: Couldn't save app settings.");
    
}

#pragma mark Helper Methods

- (void)installRubyWithName:(NSString *)rubyName
{
    NSString *fullPathToRubyZip = [[TKDConfiguration rubiesBundledDirectoryPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", rubyName]];
    [TKDFileUtilities unzipFileAtPath:fullPathToRubyZip inDirectoryPath:[TKDConfiguration rubiesInstalledDirectoryPath]];

    NSTask *linkTask = [[NSTask alloc] init];
    [linkTask setLaunchPath:@"/bin/ln"];
    [linkTask setCurrentDirectoryPath:[TKDConfiguration applicationSupportDirectoryPath]];
    [linkTask setArguments:@[ @"-s", [@"Rubies" stringByAppendingPathComponent:[rubyName stringByAppendingPathComponent:@"bin/ruby"]], @"ruby" ] ];
    [linkTask launch];
}

- (NSString *)rubyBinDirectory:(NSString *)rubyVersion {
    return [TKDUtilities rubyBinDirectory:rubyVersion];
}

- (BOOL)runBundleInstallForApp:(TKDApp *)app;
{
    [app enterSubstate:TKDAppBootingBundling];
    
    NSString *executablePath = [TKDConfiguration rubyExecutableInstalledFile];
    NSString *setupScriptPath = [TKDConfiguration setupScriptGemsInstalledFile];
    NSString *bundlerPath = [TKDConfiguration gemsBundlerInstalledDirectoryPath];
    NSString *gemHome = [TKDConfiguration gemsInstalledDirectoryPath];
    
    NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:10];
    [arguments addObject:@"-r"];
    [arguments addObject:setupScriptPath];
    [arguments addObject:bundlerPath];
    [arguments addObject:@"install"];
    
    NSTask *unzipTask = [[NSTask alloc] init];
    [unzipTask setEnvironment:@{@"GEM_HOME": gemHome}];
    [unzipTask setLaunchPath:executablePath];
    [unzipTask setCurrentDirectoryPath:app.appDirectoryPath];
    [unzipTask setArguments:arguments];
    [unzipTask launch];
    [unzipTask waitUntilExit];
    
    if ([unzipTask terminationStatus] != 0) {
        return NO;
    }
    
    return YES;
}

@end
