#import <Foundation/Foundation.h>

#import "TKDApp.h"

extern  NSString * const kMuxrNotification;

@interface TKDMuxrManager : NSObject

+ (id)defaultManager;

- (void)addApp:(TKDApp *)app;
- (void)removeApp:(TKDApp *)app;
- (void)issueCommand:(NSString *)command;

@end
