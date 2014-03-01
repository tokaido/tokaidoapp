#import "TKDFileUtilities.h"
#import "TKDConfiguration.h"

@implementation TKDConfiguration

+ (NSString *) rubyVersion {
  return @"2.1.1-p76";
}

+ (NSString *) tokaidoTerminalSetupScriptPath {
  return [[TKDConfiguration tokaidoMainBundlePath] stringByAppendingString:@"/SetupTokaido.sh"];
}

+ (NSString *) tokaidoMainBundlePath {
  return [[NSBundle mainBundle] resourcePath];
}

+ (NSString *)tokaidoInstalledGemsDirectory {
    return [[TKDConfiguration tokaidoAppSupportDirectory] stringByAppendingPathComponent:@"Gems"];
}

+ (NSString *)rubyInstallationDirectories {
    NSString *directory = [[TKDConfiguration tokaidoAppSupportDirectory] stringByAppendingPathComponent:@"Rubies"];
    [TKDFileUtilities createDirectoryAtPathIfNonExistant:directory];
    return directory;
}

+ (NSString *)tokaidoInstalledBootstrapDirectory {
    NSString *directory = [[TKDConfiguration tokaidoAppSupportDirectory] stringByAppendingPathComponent:@"Bootstrap"];
    [TKDFileUtilities createDirectoryAtPathIfNonExistant:directory];
    return directory;
}

+ (NSString *)tokaidoInstalledBinDirectory; {
    return [[TKDConfiguration tokaidoAppSupportDirectory] stringByAppendingPathComponent:@"bin"];
}

+ (NSString *)tokaidoInstalledFirewallDirectory {
    NSString *tokaidoInstalledFirewallDirectory = [[TKDConfiguration tokaidoAppSupportDirectory] stringByAppendingPathComponent:@"Firewall"];
    [TKDFileUtilities createDirectoryAtPathIfNonExistant:tokaidoInstalledFirewallDirectory];
    return tokaidoInstalledFirewallDirectory;
}

+ (NSString *)tokaidoInstalledRbConfig {
  return [[TKDConfiguration rubyInstallationDirectories] stringByAppendingPathComponent:@"/2.1.1-p76/lib/ruby/2.1.0/x86_64-darwin13.0/rbconfig.rb"];
}


+ (NSString *)tokaidoInstalledLLVMGCC {
    return [[TKDConfiguration tokaidoAppSupportDirectory] stringByAppendingPathComponent:@"llvm-gcc/llvm-gcc-4.2"];
}

+ (NSString *)tokaidoMuxrSocketPath {
    return [[TKDConfiguration tokaidoAppSupportDirectory] stringByAppendingPathComponent:@"Firewall/muxr.sock"];
}

+ (NSString *)tokaidoBundledRubiesDirectory {
    return [[TKDConfiguration tokaidoMainBundlePath] stringByAppendingPathComponent:@"Rubies"];
}

+ (NSString *)tokaidoBundledGemsFile {
    return [[TKDConfiguration tokaidoMainBundlePath] stringByAppendingPathComponent:@"tokaido-gems.zip"];
}

+ (NSString *)tokaidoBundledBinFile {
    return [[TKDConfiguration tokaidoMainBundlePath] stringByAppendingPathComponent:@"tokaido-bin.zip"];
}

+ (NSString *)tokaidoBundledLLVMGCCFile {
    return [[TKDConfiguration tokaidoMainBundlePath] stringByAppendingPathComponent:@"llvm-gcc-4.2.zip"];
}

+ (NSString *)tokaidoBundledBootstrapFile {
  return [[TKDConfiguration tokaidoMainBundlePath] stringByAppendingPathComponent:@"tokaido-bootstrap.zip"];
}


+ (NSString *) applicationSupportDirectory {
  return [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
}

+ (NSString *) tokaidoApplicationSupportDirectory {
  return [NSString stringWithFormat:@"%@/Tokaido", [TKDConfiguration applicationSupportDirectory]];
}

+ (NSString *) tokaidoLocalHomeDirectory {
  return [NSHomeDirectory() stringByAppendingPathComponent:@"/.tokaido"];
}

+ (NSString *)tokaidoAppSupportDirectory {
    [TKDFileUtilities createDirectoryAtPathIfNonExistant:[self applicationSupportDirectory]];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:[self tokaidoLocalHomeDirectory]]) {
        NSError *error = nil;
        [fm linkItemAtPath:[TKDConfiguration tokaidoApplicationSupportDirectory] toPath:[TKDConfiguration tokaidoLocalHomeDirectory] error:&error];
        if (error) {
            NSLog(@"ERROR: Couldn't create the .tokaido symlink. %@", error);
        }
    }
    
    return [TKDConfiguration tokaidoLocalHomeDirectory];
}


@end
