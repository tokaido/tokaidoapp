#import "TKDEnsureTokaidoInstallIsInstalled.h"
#import "TKDConfiguration.h"
#import "TKDFileUtilities.h"


@implementation TKDEnsureTokaidoInstallIsInstalled

@synthesize view = _view;

-(TKDEnsureTokaidoInstallIsInstalled *) initWithView:(id <TKDAppSupportEnsure>)view {
  if (self = [super init]) {
	  _view = view;
	}
		
	return self;
}

-(Class) configuration {
  return [TKDConfiguration self];
}

-(Class) fileManager {
  return [TKDFileUtilities self];
}

-(void) execute {
  NSString *bootstrapInstalledDirectory = [self.configuration bootstrapInstalledDirectoryPath];
  NSString *bootstrapGemsInstalledFile = [self.configuration bootstrapGemsInstalledFile];
  NSString *bundledBootstrapFile = [self.configuration bundledBootstrapFile];
  NSString *applicationSupportDirectory = [self.configuration tokaidoLocalHomeDirectoryPath];
 
  [_view checking_tokaido_bootstrap_installation];
  if (![self.fileManager fileExists:bootstrapGemsInstalledFile]) {
    [self.fileManager createDirectoryAtPathIfNonExistant:bootstrapInstalledDirectory];
    
    [_view unzipping_tokaido_bootstrap_bundled];
    NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:10];
    [arguments addObject:@"-o"];
    [arguments addObject:bundledBootstrapFile];
        
    NSTask *unzipTask = [[NSTask alloc] init];
    [unzipTask setLaunchPath:@"/usr/bin/unzip"];
    [unzipTask setCurrentDirectoryPath:applicationSupportDirectory];
    [unzipTask setArguments:arguments];
    [unzipTask launch];
    [unzipTask waitUntilExit];
    [_view finished_unzipping_tokaido_bootstrap_bundled];
	 }
  [_view finished_checking_tokaido_bootstrap_installation];
}

@end
