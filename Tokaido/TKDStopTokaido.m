#import "TKDStopTokaido.h"
#import "TKDConfiguration.h"
#import "TKDFileUtilities.h"

#import <ServiceManagement/ServiceManagement.h>

static NSString * const kTokaidoBootstrapLabel = @"io.tilde.tokaido.bootstrap";

@implementation TKDStopTokaido

@synthesize view = _view;

-(TKDStopTokaido *) initWithView:(id <TKDAppSupportEnsure>)view {
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
    [_view starting_shutting_down_tokaido_bootstrap];
    SMJobRemove(kSMDomainUserLaunchd, (__bridge CFStringRef)kTokaidoBootstrapLabel, NULL, false, NULL);
    [_view finished_tokaido_boostrap_shutdown];
}

@end
