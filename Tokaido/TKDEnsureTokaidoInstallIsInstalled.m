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
    NSString *bundledBootstrapFile = [self.configuration bundledBootstrapFile];
    NSString *applicationSupportDirectory = [self.configuration tokaidoLocalHomeDirectoryPath];
    
    [_view checking_tokaido_bootstrap_installation];
    [self.fileManager createDirectoryAtPathIfNonExistant:bootstrapInstalledDirectory];
    [_view unzipping_tokaido_bootstrap_bundled];
    [self.fileManager unzipFileAtPath:bundledBootstrapFile
                      inDirectoryPath:applicationSupportDirectory];
    [_view finished_unzipping_tokaido_bootstrap_bundled];
    [_view finished_checking_tokaido_bootstrap_installation];
}

@end
