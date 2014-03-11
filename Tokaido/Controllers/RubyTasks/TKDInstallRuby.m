#import "TKDConfiguration.h"
#import "TKDFileUtilities.h"
#import "TKDRubyBinary.h"
#import "TKDInstallRuby.h"

@implementation TKDInstallRuby

@synthesize bin = _bin;

-(TKDInstallRuby *) initWithRubyBinary:(TKDRubyBinary *)bin withView:(id <TKDAppSupportEnsure>)view {
  if (self = [super init]) {
	  _bin = bin;
    _view = view;
	}
	
	return self;
}

-(Class) configuration { return [TKDConfiguration self]; }
-(Class) fileManager { return [TKDFileUtilities self]; }

-(void) install {
  NSString *pathBinary = [[self configuration] rubiesBundledDirectoryPath];
  NSString *zipFile = [pathBinary stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", [_bin name]]];

  [_view unzipping_ruby_bundled];
	[self.fileManager unzipFileAtPath:zipFile inDirectoryPath:[[self configuration] rubiesInstalledDirectoryPath]];
  
  NSTask *linkTask = [[NSTask alloc] init];
    [linkTask setLaunchPath:@"/bin/ln"];
    [linkTask setCurrentDirectoryPath:[self.configuration tokaidoLocalHomeDirectoryPath]];
    [linkTask setArguments:@[ @"-s", [@"Rubies" stringByAppendingPathComponent:[[_bin name] stringByAppendingPathComponent:@"bin/ruby"]], @"ruby" ] ];
    [linkTask launch];
  [_view finished_unzipping_ruby_bundled];
}

@end
