#import "Terminal.h"
#import "TKDTerminalSessions.h"
#import "TKDUtilities.h"
#import "TKDConfiguration.h"

@implementation TKDTerminalSessions

+ (id)sharedTerminalSessions {
    static TKDTerminalSessions *sharedTKDTerminalSessions = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTKDTerminalSessions = [[self alloc] init];
    });
    return sharedTKDTerminalSessions;
}

- (id)init {
    if (self = [super init]) {
        terminal = [SBApplication applicationWithBundleIdentifier:@"com.apple.Terminal"];
    }
    return self;
}

- (NSString *) sessionFor:(TKDApp *)app {
    
    NSString *rubyBinPath  = [TKDUtilities rubyBinDirectory:[TKDConfiguration rubyVersion]];
    NSString *appDirectory = [TKDUtilities sanitizePath:app.appDirectoryPath];
    
    NSArray *commands = @[
                          [NSString stringWithFormat:@"export TOKAIDO_PATH=%@", rubyBinPath],
                          [NSString stringWithFormat:@"export TOKAIDO_APP_DIR=%@", appDirectory],
                          [NSString stringWithFormat:@"source %@", [TKDConfiguration terminalSetupScriptInstalledDirectoryPath]]
                          ];
    
    return [commands componentsJoinedByString:@"\n"];
}

-(void)openForApplication:(TKDApp *)app {
    
    if ([terminal isRunning] == NO)
        [terminal activate];
    else
        [terminal doScript:@"sleep 1;" in:nil];
    
    TerminalWindow *window = [terminal.windows firstObject];
    [terminal doScript:[self sessionFor:app] in:window];
    window.frontmost = [NSNumber numberWithBool:YES];
}

@end
