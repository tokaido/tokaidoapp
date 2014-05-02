#import "TKDLoadingTokaidoController.h"

@implementation TKDLoadingTokaidoController

@synthesize loader = _loader;
@synthesize task = _task;
@synthesize status, progress, stopButton;

- (id)initWithWindowNibName:(NSString *)windowNibName
                  forLoader:(id <TKDActivationProgress>)loader
                   withTask:(id <TKDControlTask>)task {
    
    if (self = [super initWithWindowNibName:windowNibName]) {
        _loader = loader;
        _task = task;
    }
    
    return self;
}

-(void) awakeFromNib {
    [self start];
}

-(void) start {
    [_loader configure:self];
    [_loader start];
}

@end
