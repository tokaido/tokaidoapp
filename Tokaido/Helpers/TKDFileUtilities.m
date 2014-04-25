#import "TKDFileUtilities.h"

@implementation TKDFileUtilities

+(BOOL) fileExists:(NSString *)filePath {
  BOOL isDirectory = NO;
	return ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory] && !isDirectory);
}

+(BOOL) directoryExists:(NSString *)path {
	BOOL isDirectory = NO;
	return ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory);
}

+(NSEnumerator *) lookIn:(NSString *)path {
  return [[NSFileManager defaultManager] enumeratorAtPath:path];
}

+(void) createDirectoryAtPathIfNonExistant:(NSString *)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    
    // If the directory doesn't exist try to create it
    if ( !([fm fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) ) {
        // Create the directory
        NSError *error = nil;
        BOOL success = [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (!success && error) {
            NSLog(@"ERROR: Couldn't create the Tokaido directory at %@: %@", path, [error localizedDescription]);
        }
    }
}

+(void) unzipFileAtPath:(NSString *)path inDirectoryPath:(NSString *)directory {
    NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:10];
    [arguments addObject:@"-u"];
    [arguments addObject:path];
    
    NSTask *unzipTask = [[NSTask alloc] init];
    [unzipTask setLaunchPath:@"/usr/bin/unzip"];
    [unzipTask setCurrentDirectoryPath:directory];
    [unzipTask setArguments:arguments];
    [unzipTask launch];
    [unzipTask waitUntilExit];
}


@end