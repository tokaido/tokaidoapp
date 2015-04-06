#import <Foundation/Foundation.h>

@interface TKDUtilities : NSObject

+ (NSString *)rubyBinDirectory:(NSString *)version;
+ (NSString *)sanitizePath:(NSString *)input;
+ (BOOL) isAppRunning:(NSString *)appName;


@end
