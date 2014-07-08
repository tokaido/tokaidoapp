#import "TKDRubyBinary.h"
#import "TKDConfiguration.h"
#import "TKDRubyBinaryFinder.h"

@implementation TKDRubyBinary

@synthesize name = _name;
@synthesize searcher = _searcher;

-(TKDRubyBinary *) initWithName:(NSString *)name {
    if (self = [super init]) {
        _name = name;
	}
	
	return self;
}

-(TKDRubyBinaryFinder *)searcher {
    if (_searcher == nil)
        _searcher = [[TKDRubyBinaryFinder alloc] init];
    
    return _searcher;
}

-(BOOL) isInstalled {
    return ![self isNotInstalled];
}

-(BOOL) isNotInstalled {
    return ![self.searcher didFindInstallationWithRuby:self];
}

@end
