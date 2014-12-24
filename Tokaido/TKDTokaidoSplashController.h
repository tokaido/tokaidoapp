#import <Foundation/Foundation.h>
#import "TKDAppSupportEnsure.h"
#import "TKDActivationProgress.h"

@class TKDCubalogApp;

@interface TKDTokaidoSplashController : NSWindowController <TKDActivationProgress, TKDAppSupportEnsure, NSWindowDelegate>

@property (nonatomic, strong) IBOutlet NSTextField *status;
@property (nonatomic, strong) IBOutlet NSProgressIndicator *progress;

@property (nonatomic, strong) TKDCubalogApp *logger;

-(void) start;

@end
