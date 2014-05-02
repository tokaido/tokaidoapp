#import "TKDRubyConfigPatches.h"
#import "TKDConfiguration.h"

@implementation TKDRubyConfigPatches

-(TKDRubyConfigPatches *) initWithConfigFile:(NSString *)rbConfig
                                    withView:(id <TKDAppSupportEnsure>)view {
    if (self = [super init]) {
        NSError *error = nil;
        _rbConfig = [[NSString stringWithContentsOfFile:rbConfig
                                               encoding:NSUTF8StringEncoding
                                                  error:&error] mutableCopy];
        
        if (error) {
            NSLog(@"ERROR patching rbconfig: %@", [error localizedDescription]);
            return nil;
        }
        
		_view = view;
	}
    
	return self;
}

-(Class) configuration {
    return [TKDConfiguration self];
}

-(void) execute {
    [_view applying_rbconfig_patches];
    
    NSError *error = nil;
    
    NSRegularExpression *topDirRegex = [NSRegularExpression regularExpressionWithPattern:@"TOPDIR\\s=.*"
                                                                                 options:0
                                                                                   error:&error];
    
    if (error) {
        [_view error_patching_rbconfig_with_message:[NSString stringWithFormat:@"%@", [error localizedDescription]]];
        NSLog(@"ERROR patching rbconfig: %@", [error localizedDescription]);
        return;
    }
    
    [_view replacing_config_topdir_line];
    NSLog(@"Replacing CONFIG[\"TOPDIR\"] rbconfig.rb...");
    NSString *newTopDir = [NSString stringWithFormat:@"TOPDIR = \"%@/2.1.1-p76\"", [self.configuration rubiesInstalledDirectoryPath]];
    [topDirRegex replaceMatchesInString:_rbConfig
                                options:0
                                  range:NSMakeRange(0, [_rbConfig length])
                           withTemplate:newTopDir];
    
    [_view replacing_config_cc_line];
    NSLog(@"Replacing CONFIG[\"CC\"] rbconfig.rb...");
    NSRegularExpression *ccRegex = [NSRegularExpression regularExpressionWithPattern:@"CONFIG\\[\\\"CC\\\"\\].*"
                                                                             options:0
                                                                               error:&error];
    
    if (error) {
        [_view error_patching_rbconfig_with_message:[NSString stringWithFormat:@"%@", [error localizedDescription]]];
        NSLog(@"ERROR patching rbconfig: %@", [error localizedDescription]);
        return;
    }
    
    NSString *newConfig = [NSString stringWithFormat:@"CONFIG[\"CC\"] = \"%@\"", [self.configuration compilerExecutableInstalledFile]];
    [ccRegex replaceMatchesInString:_rbConfig
                            options:0
                              range:NSMakeRange(0, [_rbConfig length])
                       withTemplate:newConfig];
    
    [_rbConfig writeToFile:[[self configuration] rubyConfigInstalledFile]
                atomically:YES
                  encoding:NSUTF8StringEncoding
                     error:&error];
    
    if (error) {
        [_view error_patching_rbconfig_with_message:[NSString stringWithFormat:@"%@", [error localizedDescription]]];
        NSLog(@"ERROR saving rbconfig: %@", [error localizedDescription]);
        return;
    } else {
        [_view patching_rbconfig_complete];
        NSLog(@"rbconfig.rb patch complete.");
    }
}
@end
