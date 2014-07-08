#import <Cocoa/Cocoa.h>

#import "TKDApp.h"

@interface TKDEditAppController : NSWindowController

@property (nonatomic, strong) TKDApp *app;

@property (nonatomic, strong) IBOutlet NSImageView *appImageView;
@property (nonatomic, strong) IBOutlet NSTextField *appNameField;
@property (nonatomic, strong) IBOutlet NSTextField *hostnameField;
@property (nonatomic, strong) IBOutlet NSButton *usesYamlButton;

- (IBAction)savePressed:(id)sender;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)chooseImagePressed:(id)sender;

@end
