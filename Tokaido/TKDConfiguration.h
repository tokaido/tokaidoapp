#import <Foundation/Foundation.h>

@interface TKDConfiguration : NSObject

+(NSString *) rubyVersion;
+(NSString *) applicationName;
+(NSString *) bundlePath;
+(NSString *) applicationSupportDirectoryPath;
+(NSString *) tokaidoApplicationsConfigurations;
+(NSString *) assetsDirectoryInstalledPath;
+(NSString *) tokaidoLocalHomeDirectoryPath;

@end

@interface TKDConfiguration(BundledFilesAndPaths)
+(NSArray *) rubiesBundled;
+(NSString *) rubyExecutableInstalledFile;
+(NSString *) bundledGemsFile;
+(NSString *) bundledBinariesFile;
+(NSString *) setupScriptGemsInstalledFile;
+(NSString *) bundledBootstrapFile;
+(NSString *) gemsBundlerInstalledDirectoryPath;

+(NSString *) rubiesBundledDirectoryPath;
@end

@interface TKDConfiguration(Firewall)
+(NSString *) firewallStandardOutInstalledFile;
+(NSString *) firewallStandardErrorInstalledFile;
+(NSString *) firewallInstallScriptInstalledFile;
+(NSString *) firewallInstalledDirectoryPath;
@end

@interface TKDConfiguration(Bootstrap)
+(NSString *) bootstrapLaunchDaemonPlistFile;

+(NSString *) terminalSetupScriptInstalledDirectoryPath;
+(NSString *) bootstrapGemsInstalledFile;
+(NSString *) bootstrapFirewallPlistInstalledFile;
+(NSString *) bootstrapFirewallScriptInstalledFile;
+(NSString *) boostrapScriptInstalledFile;
+(NSString *) bootstrapInstalledDirectoryPath;
+(NSString *) cubalogInstalledDirectoryPath;
@end

@interface TKDConfiguration(InstalledPaths)
+(NSArray *) rubiesInstalled;
+(NSString *) rubyConfigInstalledFile;
+(NSString *) compilerExecutableInstalledFile;

+(NSString *) rubiesInstalledDirectoryPath;
+(NSString *) gemsInstalledDirectoryPath;
+(NSString *) gemsBinaryInstalledDirectoryPath;

+(NSString *) binariesInstalledDirectoryPath;

+(NSString *) compilerInstalledDirectoryPath;

+(NSString *) muxrSocketPath;
@end
