#import <Foundation/Foundation.h>

@interface TKDConfiguration : NSObject


+ (NSString *) tokaidoInstalledLLVMGCC;
+ (NSString *) tokaidoMuxrSocketPath;
+ (NSString *) rubyInstallationDirectories;
+ (NSString *) tokaidoBundledGemsFile;
+ (NSString *) tokaidoBundledBinFile;
+ (NSString *) tokaidoBundledLLVMGCCFile;
+ (NSString *) tokaidoBundledBootstrapFile;
+ (NSString *) tokaidoBundledRubiesDirectory;


+ (NSString *) tokaidoInstalledBootstrapDirectory;
+ (NSString *) tokaidoInstalledGemsDirectory;
+ (NSString *) tokaidoInstalledBinDirectory;
+ (NSString *) tokaidoInstalledFirewallDirectory;
+ (NSString *) tokaidoInstalledRbConfig;


+ (NSString *) rubyVersion;
+ (NSString *) tokaidoTerminalSetupScriptPath;

+ (NSString *) tokaidoAppSupportDirectory;
+ (NSString *) applicationSupportDirectory;

@end
