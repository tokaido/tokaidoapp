#import "TKDAppViewItem.h"
#import "TKDConfiguration.h"
#import "TKDAppLogViewerController.h"

@interface TKDAppViewItem ()
@end

@implementation TKDAppViewItem

- (void)awakeFromNib {
    [super awakeFromNib];
    self.appController.content = self.representedObject;
    
    [self.showInFinderMenuItem setTarget:self.representedObject];
    [self.showInFinderMenuItem setAction:@selector(showInFinder)];
    [self.showInFinderMenuItem setEnabled:YES];
    
    [self.openInBrowserMenuItem setTarget:self.representedObject];
    [self.openInBrowserMenuItem setAction:@selector(openInBrowser)];
    
    [self.editMenuItem setTarget:self];
    [self.editMenuItem setAction:@selector(editApp)];
    
    [self.removeMenuItem setTarget:self];
    [self.removeMenuItem setAction:@selector(removeApp)];
    [self.removeMenuItem setEnabled:YES];
    
    [self.activatedMenuItem setTarget:self];
    [self.activatedMenuItem setAction:@selector(activate)];
    [self configureActivatedMenuItem];
    
    [self.representedObject addObserver:self
                             forKeyPath:@"state"
                                options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                                context:NULL];
}

- (void)activate {
    TKDApp *app = self.representedObject;
    
    switch (app.state) {
        case TKDAppOff:
            [self.tokaidoController activateApp:app];
            break;
            
        case TKDAppOn:
            [self.tokaidoController deactivateApp:app];
            break;
            
        case TKDAppShuttingDown:
        case TKDAppBooting:
            break;
            
        default:
            break;
    }
}

- (void)configureActivatedMenuItem {
    TKDApp *app = [self app];
    
    switch (app.state) {
        case TKDAppOff:
            [self.activatedMenuItem setEnabled:YES];
            [self.activatedMenuItem setTarget:self];
            [self.activatedMenuItem setTitle:NSLocalizedString(@"Activate", nil)];
            [self.activatedMenuItem setAction:@selector(activate)];
            
            
            [self.openInBrowserMenuItem setTarget:nil];
            break;
            
        case TKDAppBooting:
            [self.activatedMenuItem setEnabled:NO];
            [self.activatedMenuItem setTarget:nil];
            [self.activatedMenuItem setTitle:NSLocalizedString(@"Starting up...", nil)];
            
            [self.openInBrowserMenuItem setTarget:nil];
            break;
            
        case TKDAppOn:
            [self.activatedMenuItem setEnabled:YES];
            [self.activatedMenuItem setTarget:self];
            [self.activatedMenuItem setTitle:NSLocalizedString(@"Deactivate", nil)];
            
            
            [self.openInBrowserMenuItem setTarget:self.representedObject];
            break;
            
        case TKDAppShuttingDown:
            [self.activatedMenuItem setEnabled:NO];
            [self.activatedMenuItem setTarget:nil];
            [self.activatedMenuItem setTitle:NSLocalizedString(@"Shutting down...", nil)];
            
            [self.openInBrowserMenuItem setTarget:nil];
            break;
            
        default:
            break;
    }
}

- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context {
    
	if ([keyPath isEqualToString:@"state"])
        [self configureActivatedMenuItem];
    else
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
}

- (void)tokenField:(TKDRailsAppTokenField *)tokenField clickedWithEvent:(NSEvent *)event {
    [NSMenu popUpContextMenu:self.appMenu withEvent:event forView:self.view];
}

- (NSString *)titleForTokenField:(TKDRailsAppTokenField *)tokenField {
    TKDApp *app = [self app];
    return app.appHostname;
}

- (NSString *)pathForIcon:(TKDSelectableIcon *)icon {
    TKDApp *app = [self app];
    return app.appIconPath;
}

- (void)editApp {
    [self.tokaidoController showEditWindowForApp:[self app]];
}

- (void)removeApp {
    [self.tokaidoController removeApp:[self app]];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self.appIcon setSelected:selected];
}

- (IBAction)showLogs:(id)sender {
    self.appLogViewerController = [[TKDAppLogViewerController alloc] initWithWindowNibName:@"LogViewerWindow"];
    self.appLogViewerController.app = self.app;
    [self.appLogViewerController showWindow:self];
}

- (void)doubleClick:(id)sender {
    if (self.app.state == TKDAppOff)
        [self activate];
}

- (TKDApp *)app {
    return self.representedObject;
}

@end
