#import <Foundation/Foundation.h>

#import "TKDApp.h"
#import "TKDEditAppController.h"

@interface TKDTokaidoController : NSWindowController <NSWindowDelegate>

@property IBOutlet NSCollectionView *railsAppsView;
@property IBOutlet NSArrayController *appsArrayController;

@property (nonatomic, strong) TKDEditAppController *editAppController;

- (IBAction)openTerminalPressed:(id)sender;
- (IBAction)addAppPressed:(id)sender;

- (void)removeApp:(id)sender;
- (void)showEditWindowForApp:(TKDApp *)app;

- (void)activateApp:(TKDApp *)app;
- (void)deactivateApp:(TKDApp *)app;

@end