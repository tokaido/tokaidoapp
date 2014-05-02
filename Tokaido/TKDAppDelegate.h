#import <Cocoa/Cocoa.h>
#import "TKDTokaidoController.h"

@interface TKDAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) IBOutlet TKDTokaidoController *tokaidoController;


- (NSString *)rubyBinDirectory:(NSString *)rubyVersion;

- (void)loadAppSettings;
- (void)saveAppSettings;

@end
