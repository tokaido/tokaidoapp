#import <Foundation/Foundation.h>

@interface TKDPostgresApp : NSObject

+(BOOL) isInstalled;
+(BOOL) isRunning;

+(NSString *) path;
+(NSString *) latestVersion;

@end

