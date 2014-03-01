#import "TKDUtilities.h"
#import "TKDConfiguration.h"

@implementation TKDUtilities

+ (NSString *)rubyBinDirectory:(NSString *)version {
    NSString *installedRubies = [TKDConfiguration rubyInstallationDirectories];
    NSString *sanitizedInstalledRubies = [TKDUtilities sanitizePath:installedRubies];
    NSString *rubyBinDirectory = [version stringByAppendingPathComponent:@"bin"];
    
    return [sanitizedInstalledRubies stringByAppendingPathComponent:rubyBinDirectory];
}

+ (NSString *)sanitizePath:(NSString *)input {
    return [input stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
}



@end
