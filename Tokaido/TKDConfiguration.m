#import "TKDConfiguration.h"
#import "TKDFileUtilities.h"
#import "TKDRubyBinary.h"

@implementation TKDConfiguration

+(NSString *) rubyVersion {
    return @"2.1.5-p273";
}

+(NSString *) rubyNamespace {
    return @"2.1.0";
}

+(NSArray *) rubiesBundled {
    return @[[[TKDRubyBinary alloc] initWithName:@"2.1.5-p273"]];
}

+(NSArray *) rubiesInstalled {
    NSMutableSet *installedRubies = [NSMutableSet set];
	
    NSDirectoryEnumerator *installedRubyPaths = [TKDFileUtilities lookIn:[self rubiesInstalledDirectoryPath]];
	NSString *installedFile;
	
	while (installedFile = [installedRubyPaths nextObject])
        if ([TKDFileUtilities directoryExists:[[self rubiesInstalledDirectoryPath] stringByAppendingPathComponent:installedFile]]) {
            [installedRubyPaths skipDescendents];
			[installedRubies addObject:[[TKDRubyBinary alloc] initWithName:installedFile]];
		}
    
	return [installedRubies allObjects];
}

+(NSString *) rubyConfigInstalledFile {
    return [[self rubiesInstalledDirectoryPath] stringByAppendingPathComponent:@"/2.1.5-p273/lib/ruby/2.1.0/x86_64-darwin12.0/rbconfig.rb"];
}

+(NSString *) applicationName {
    return @"Tokaido";
}

+ (NSString *) terminalSetupScriptInstalledDirectoryPath {
    return [[self bundlePath] stringByAppendingString:@"/SetupTokaido.sh"];
}

+(NSString *) bundlePath {
    return [[NSBundle mainBundle] resourcePath];
}

+(NSString *) rubiesBundledDirectoryPath {
    return [[self bundlePath] stringByAppendingPathComponent:@"Rubies"];
}

+(NSString *) rubiesInstalledDirectoryPath {
    return [[self tokaidoLocalHomeDirectoryPath] stringByAppendingPathComponent:@"Rubies"];
}

+(NSString *) gemsGlobalInstalledDirectoryPath {
    return [[self tokaidoLocalHomeDirectoryPath] stringByAppendingPathComponent:@"Gems"];
}

+(NSString *) gemsInstalledDirectoryPath {
    return [[self tokaidoLocalHomeDirectoryPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"Gems/%@", [self rubyNamespace]]];
}

+(NSString *) temporalWorkingSpace {
    return [[self tokaidoLocalHomeDirectoryPath] stringByAppendingPathComponent:@"Tmp"];
}

+(NSString *) gemsBinaryInstalledDirectoryPath {
    return [[self gemsInstalledDirectoryPath] stringByAppendingPathComponent:@"bin"];
}

+(NSString *) gemsBundlerInstalledDirectoryPath {
    return [[self gemsBinaryInstalledDirectoryPath] stringByAppendingPathComponent:@"bundle"];
}

+(NSString *) binariesInstalledDirectoryPath {
    return [[self tokaidoLocalHomeDirectoryPath] stringByAppendingPathComponent:@"bin"];
}

+(NSString *) compilerInstalledDirectoryPath {
    return [[self tokaidoLocalHomeDirectoryPath] stringByAppendingPathComponent:@"Clang"];
}

+(NSString *) magickInstalledDirectoryPath {
    return [[self gemsInstalledDirectoryPath] stringByAppendingPathComponent:@"/bin_files/magick"];
}

+(NSString *) bootstrapInstalledDirectoryPath {
    return [[self tokaidoLocalHomeDirectoryPath] stringByAppendingPathComponent:@"Bootstrap"];
}

+(NSString *) temporalBootstrapInstalledDirectoryPath {
    return [[self temporalWorkingSpace] stringByAppendingPathComponent:@"Bootstrap"];
}

+(NSString *) firewallInstalledDirectoryPath {
    return [[self tokaidoLocalHomeDirectoryPath] stringByAppendingPathComponent:@"Firewall"];
}

+(NSString *) cubalogInstalledDirectoryPath {
    return [[self tokaidoLocalHomeDirectoryPath] stringByAppendingPathComponent:@"Cubalog"];
}

+(NSString *) setupScriptGemsInstalledFile {
    return [[self bootstrapInstalledDirectoryPath] stringByAppendingPathComponent:@"/bundle/bundler/setup.rb"];
}

+(NSString *) bootstrapGemsInstalledFile {
    return [[self bootstrapInstalledDirectoryPath] stringByAppendingPathComponent:@"/bundle/bundler/setup.rb"];
}

+(NSString *) bootstrapLaunchDaemonPlistFile {
    return @"/Library/LaunchDaemons/com.tokaido.firewall.plist";
}

+(NSString *) bootstrapFirewallPlistInstalledFile {
    return [[self bootstrapInstalledDirectoryPath] stringByAppendingPathComponent:@"firewall/com.tokaido.firewall.plist"];
}

+(NSString *) bootstrapFirewallScriptInstalledFile {
    return [[self bootstrapInstalledDirectoryPath] stringByAppendingPathComponent:@"firewall/firewall_rules.rb"];
}

+(NSString *) temporalBootstrapFirewallScriptInstalledFile {
    return [[self temporalBootstrapInstalledDirectoryPath] stringByAppendingPathComponent:@"firewall/firewall_rules.rb"];
}

+(NSString *) boostrapScriptInstalledFile {
    return [[self bootstrapInstalledDirectoryPath] stringByAppendingPathComponent:@"bin/tokaido-bootstrap"];
}

+(NSString *) firewallInstallScriptInstalledFile {
    return [[self bootstrapInstalledDirectoryPath] stringByAppendingPathComponent:@"bin/tokaido-install"];
}

+(NSString *) firewallStandardOutInstalledFile {
    return [[self firewallInstalledDirectoryPath] stringByAppendingPathComponent:@"/bootstrap.out"];
}

+(NSString *) firewallStandardErrorInstalledFile {
    return [[self firewallInstalledDirectoryPath] stringByAppendingPathComponent:@"/bootstrap.err"];
}

+(NSString *) bundledBinariesFile {
    return [[self bundlePath] stringByAppendingPathComponent:@"tokaido-bin.zip"];
}

+(NSString *) bundledGemsFile {
    return [[self bundlePath] stringByAppendingPathComponent:@"tokaido-gems.zip"];
}

+(NSString *) bundledBootstrapFile {
    return [[self bundlePath] stringByAppendingPathComponent:@"tokaido-bootstrap.zip"];
}

+(NSString *) compilerExecutableInstalledFile {
    return [[[self compilerInstalledDirectoryPath] stringByAppendingPathComponent:@"clang"]  stringByResolvingSymlinksInPath];
}

+(NSString *) tokaidoLocalHomeDirectoryPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"/.tokaido"];
}

+(NSString *) tokaidoApplicationsConfigurations {
    return [[self tokaidoLocalHomeDirectoryPath] stringByAppendingPathComponent:@"AppSettings"];
}
    
+(NSString *) assetsDirectoryInstalledPath {
    return [[self tokaidoLocalHomeDirectoryPath] stringByAppendingPathComponent:@"/Assets"];
}

+(NSString *) rubyExecutableInstalledFile {
    return [[[self tokaidoLocalHomeDirectoryPath] stringByAppendingPathComponent:@"ruby"] stringByResolvingSymlinksInPath];
}

+(NSString *) applicationSupportDirectoryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportDirectory = [paths objectAtIndex:0];
    
    [TKDFileUtilities createDirectoryAtPathIfNonExistant:applicationSupportDirectory];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:applicationSupportDirectory]) {
        NSError *error = nil;
        [fm linkItemAtPath:applicationSupportDirectory
                    toPath:[self tokaidoLocalHomeDirectoryPath]
                     error:&error];
        if (error) {
            NSLog(@"ERROR: Couldn't create the .tokaido symlink. %@", error);
        }
    }
    
    return [self tokaidoLocalHomeDirectoryPath];
}


+(NSString *) muxrSocketPath {
    return [[self tokaidoLocalHomeDirectoryPath] stringByAppendingPathComponent:@"Firewall/muxr.sock"];
} 

@end
