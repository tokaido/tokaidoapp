#import <Cocoa/Cocoa.h>
#import "TKDTokaidoController.h"
#import "TKDTokaidoSplashController.h"

extern  NSString * const kMenuBarNotification;

@interface TKDAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong, nonatomic) NSStatusItem *statusItem;

@property (nonatomic, strong) IBOutlet TKDTokaidoController *tokaidoController;
@property (nonatomic, strong) IBOutlet TKDTokaidoSplashController *tokaidoSplashController;

@property (atomic, strong) NSMutableArray *apps;


- (NSString *)rubyBinDirectory:(NSString *)rubyVersion;

- (void)loadAppSettings;
- (void)saveAppSettings;

@end
