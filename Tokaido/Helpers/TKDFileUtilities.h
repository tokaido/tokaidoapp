#import <Foundation/Foundation.h>

@interface TKDFileUtilities : NSObject

+ (void)createDirectoryAtPathIfNonExistant:(NSString *)path;
+ (void)unzipFileAtPath:(NSString *)path inDirectoryPath:(NSString *)directory;

@end
