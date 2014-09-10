#import <Foundation/Foundation.h>
#import "TKDControlTask.h"
#import "TKDAppSupportEnsure.h"

@interface TKDStopTokaido : NSObject <TKDControlTask>

@property (nonatomic, assign) id <TKDAppSupportEnsure> view;

-(TKDStopTokaido *) initWithView:(id <TKDAppSupportEnsure>)view;

-(Class) configuration;
-(Class) fileManager;

-(void) execute;

@end
