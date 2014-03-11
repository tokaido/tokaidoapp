#import <Cocoa/Cocoa.h>
#import "TKDActivationProgress.h"
#import "TKDControlTask.h"

@interface TKDLoadingTokaidoController : NSWindowController {

  IBOutlet NSTextField *status;
  IBOutlet NSProgressIndicator *progress;
  IBOutlet NSButton *stopButton;

}

@property (nonatomic, strong) NSTextField *status;
@property (nonatomic, strong) NSProgressIndicator *progress;
@property (nonatomic, strong) NSButton *stopButton;

@property (nonatomic, strong) id <TKDActivationProgress> loader;
@property (nonatomic, strong) id <TKDControlTask> task;

-(id) initWithWindowNibName:(NSString *)windowNibName
                  forLoader:(id <TKDActivationProgress>)loader
                   withTask:(id <TKDControlTask>)task;
-(void) start;
@end
