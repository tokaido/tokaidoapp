#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class TKDApp;

@interface TKDAppLogViewerController : NSWindowController

@property (nonatomic, strong) TKDApp *app;
@property (nonatomic, strong) IBOutlet WebView *viewer;
@end
