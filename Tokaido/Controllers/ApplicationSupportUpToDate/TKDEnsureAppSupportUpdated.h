#import <Foundation/Foundation.h>
#import "TKDControlTask.h"
#import "TKDAppSupportEnsure.h"

@class TKDConfiguration, TKDFileUtilities;

@interface TKDEnsureAppSupportUpdated : NSObject <TKDControlTask> {
  @private NSMutableArray *_rubyInstallationTasks;
}

@property (nonatomic, assign) id <TKDAppSupportEnsure> view;
-(TKDEnsureAppSupportUpdated *) initWithView:(id <TKDAppSupportEnsure>)view;

-(Class) configuration;
-(Class) fileManager;

-(void) execute;
-(NSArray *) rubyInstallations;

@end
