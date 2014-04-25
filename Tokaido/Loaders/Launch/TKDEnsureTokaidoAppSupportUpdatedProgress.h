#import <Foundation/Foundation.h>
#import "TKDLoadingTokaidoController.h"
#import "TKDAppSupportEnsure.h"
#import "TKDActivationProgress.h"

@interface TKDEnsureTokaidoAppSupportUpdatedProgress : NSObject <TKDActivationProgress, TKDAppSupportEnsure> {
  TKDLoadingTokaidoController *_controller;
}

-(void) start;
-(void) configure:(id)controller;

@end
