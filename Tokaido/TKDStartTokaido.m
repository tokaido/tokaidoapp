#import "TKDStartTokaido.h"
#import "TKDConfiguration.h"
#import "TKDFileUtilities.h"

#import <ServiceManagement/ServiceManagement.h>

static NSString * const kTokaidoBootstrapLabel = @"io.tilde.tokaido.bootstrap";

@implementation TKDStartTokaido

-(TKDStartTokaido *) initWithView:(id <TKDAppSupportEnsure>)view {
    if (self = [super init])
        _view = view;
    
	return self;
}

-(Class) configuration {
    return [TKDConfiguration self];
}

-(Class) fileManager {
    return [TKDFileUtilities self];
}

-(void) execute {
    [_view starting_tokaido_bootstrap];
    NSString *executablePath = [[self configuration] rubyExecutableInstalledFile];
    NSString *executableDirectory = [[self configuration] applicationSupportDirectoryPath];
	NSString *setupScriptPath = [[self configuration] bootstrapGemsInstalledFile];
	NSString *tokaidoBootstrapScriptPath = [[self configuration] boostrapScriptInstalledFile];
	NSString *firewallPath = [[self configuration] firewallInstalledDirectoryPath];
	NSString *outPath = [[self configuration] firewallStandardOutInstalledFile];
	NSString *errPath = [[self configuration] firewallStandardErrorInstalledFile];
	NSString *gemHome = [[self configuration] gemsInstalledDirectoryPath];
	NSString *gemPath = [[self configuration] gemsBinaryInstalledDirectoryPath];
	NSString *path = [executableDirectory stringByAppendingFormat:@":%@", gemPath];
    
	[_view unlinking_current_socket];
	unlink([[self.configuration muxrSocketPath] UTF8String]);
    
	NSMutableDictionary *plist = [NSMutableDictionary dictionary];
	[plist setObject:kTokaidoBootstrapLabel forKey:@"Label"];
	[plist setObject:[NSNumber numberWithBool:YES] forKey:@"RunAtLoad"];
	[plist setObject:outPath forKey:@"StandardOutPath"];
	[plist setObject:errPath forKey:@"StandardErrorPath"];
	[plist setObject:[NSNumber numberWithBool:YES] forKey:@"AbandonProcessGroup"];
	[plist setObject:@{
                       @"TOKAIDO_TMPDIR": firewallPath,
                       @"PATH": path,
                       @"GEM_HOME": gemHome,
                       @"GEM_PATH": gemHome
                       } forKey:@"EnvironmentVariables"];
    
	[plist setObject:@[executablePath, @"-r", setupScriptPath, tokaidoBootstrapScriptPath]
              forKey:@"ProgramArguments"];
    
    CFErrorRef error;
	
	if ( SMJobSubmit( kSMDomainUserLaunchd, (__bridge CFDictionaryRef)plist, NULL, &error) )
        [_view tokaido_bootstrap_started];
	else
        [_view failed_starting_tokaido_bootstrap_with_error:[NSString stringWithFormat:@"%@", error]];
    
	if (error) {
        [_view failed_starting_tokaido_bootstrap_with_error:[NSString stringWithFormat:@"%@", CFErrorCopyDescription(error)]];
		CFRelease(error);
	}
    [_view finished_starting_tokaido_bootstrap];
}

@end
