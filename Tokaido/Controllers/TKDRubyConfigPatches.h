#import <Foundation/Foundation.h>
#import "TKDAppSupportEnsure.h"
#import "TKDControlTask.h"

@interface TKDRubyConfigPatches : NSObject <TKDControlTask> {
	NSMutableString *_rbConfig;
}

@property (nonatomic, assign) id <TKDAppSupportEnsure> view;
-(TKDRubyConfigPatches *) initWithConfigFile:(NSString *)rbConfig 
                                    withView:(id <TKDAppSupportEnsure>)view;

-(void) execute;

@end
