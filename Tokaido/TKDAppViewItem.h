#import <Cocoa/Cocoa.h>

#import "TKDTokaidoController.h"
#import "TKDAppLogViewerController.h"

#import "TKDApp.h"
#import "TKDSelectableIcon.h"
#import "TKDRailsAppTokenField.h"

@interface TKDAppViewItem : NSCollectionViewItem <TKDRailsAppTokenFieldDelegate, TKDSelectableIconDelegate>

@property (nonatomic, weak) IBOutlet TKDTokaidoController *tokaidoController;

@property (nonatomic, strong) IBOutlet TKDAppLogViewerController *appLogViewerController;
@property (nonatomic, strong) IBOutlet NSObjectController *appController;
@property (nonatomic, strong) IBOutlet TKDSelectableIcon *appIcon;
@property (nonatomic, strong) IBOutlet TKDRailsAppTokenField *tokenField;
@property (nonatomic, strong) IBOutlet NSTextField *appNameTextField;

@property (nonatomic, strong) IBOutlet NSMenu *appMenu;

@property (nonatomic, strong) IBOutlet NSMenuItem *activatedMenuItem;
@property (nonatomic, strong) IBOutlet NSMenuItem *shouldActivateOnLaunchMenuItem;

@property (nonatomic, strong) IBOutlet NSMenuItem *showInFinderMenuItem;
@property (nonatomic, strong) IBOutlet NSMenuItem *openInBrowserMenuItem;

@property (nonatomic, strong) IBOutlet NSMenuItem *editMenuItem;
@property (nonatomic, strong) IBOutlet NSMenuItem *removeMenuItem;

- (IBAction)showLogs:(id)sender;
- (IBAction)doubleClick:(id)sender;

@property (nonatomic, readonly) TKDApp *app;

@end
