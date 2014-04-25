#import <Foundation/Foundation.h>
#import "TKDControlTask.h"
#import "TKDAppSupportEnsure.h"

@interface TKDStartTokaido : NSObject <TKDControlTask>  

@property (nonatomic, assign) id <TKDAppSupportEnsure> view;
-(TKDStartTokaido *) initWithView:(id <TKDAppSupportEnsure>)view;

-(Class) configuration;
-(Class) fileManager;

-(void) execute;

@end
