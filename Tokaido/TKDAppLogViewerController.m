#import "TKDAppLogViewerController.h"
#import "TKDApp.h"

@interface TKDAppLogViewerController ()

@end

@implementation TKDAppLogViewerController


- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [[self.viewer mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://cubalog.tokaido/logs/%@?path=%@", self.app.appName, self.app.appDirectoryPath]]]];
}

-(NSArray *)webView:(WebView *)sender
contextMenuItemsForElement:(NSDictionary *)element
   defaultMenuItems:(NSArray *)defaultMenuItems {
    return nil;
}

@end
