#import <Foundation/Foundation.h>

@interface TKDFileUtilities : NSObject

+(BOOL) fileExists:(NSString *)filePath;
+(BOOL) directoryExists:(NSString *)path;

+(NSDirectoryEnumerator *) lookIn:(NSString *)path;

+(void) removeFileIfNonExistant:(NSString *)filePath;

+(void) createDirectoryAtPathIfNonExistant:(NSString *)path;
+(void) unzipFileAtPath:(NSString *)path inDirectoryPath:(NSString *)directory;

@end