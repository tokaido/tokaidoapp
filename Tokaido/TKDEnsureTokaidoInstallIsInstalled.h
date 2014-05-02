#import <Foundation/Foundation.h>
#import "TKDAppSupportEnsure.h"
#import "TKDControlTask.h"

@interface TKDEnsureTokaidoInstallIsInstalled : NSObject <TKDControlTask>

@property (nonatomic, assign) id <TKDAppSupportEnsure> view;
-(TKDEnsureTokaidoInstallIsInstalled *) initWithView:(id <TKDAppSupportEnsure>)view;

-(Class) configuration;
-(Class) fileManager;

-(void) execute;

@end
