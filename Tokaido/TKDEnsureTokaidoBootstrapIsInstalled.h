#import <Foundation/Foundation.h>
#import "TKDAppSupportEnsure.h"
#import "TKDControlTask.h"

@interface TKDEnsureTokaidoBootstrapIsInstalled : NSObject <TKDControlTask>

@property (nonatomic, assign) id <TKDAppSupportEnsure> view;

-(TKDEnsureTokaidoBootstrapIsInstalled *) initWithView:(id <TKDAppSupportEnsure>)view;

-(Class) configuration;
-(Class) fileManager;

-(void) execute;

@end
