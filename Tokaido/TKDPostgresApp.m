#import "TKDUtilities.h"
#import "TKDFileUtilities.h"
#import "TKDPostgresApp.h"

@interface TKDPostgresApp(FinderMethods)
+(NSString *) latestVersionPath;
@end

@implementation TKDPostgresApp

+(BOOL) isRunning {
    return [TKDUtilities isAppRunning:[self bundleIdentifier]];
}

+(BOOL) isInstalled {
    return [TKDFileUtilities directoryExists:[self appPath]];
}

+(NSString *) bundleIdentifier {
    return @"com.postgresapp.Postgres";
}

+(NSString *) appPath {
    return @"/Applications/Postgres.app";
}

+(NSString *) versionsPath {
    return @"Contents/Versions";
}

+(NSString *) latestVersion {
    NSString *postgresAppVersions = [[self appPath] stringByAppendingPathComponent:[self versionsPath]];
    return [[TKDFileUtilities directories:postgresAppVersions] lastObject];
}

+(NSString *) path {
    if ([self isInstalled])
        return [NSString stringWithFormat:@"%@/%@/%@/%@", [self appPath], [self versionsPath], [self latestVersion], @"bin"];
    return @"/bin";
}


@end