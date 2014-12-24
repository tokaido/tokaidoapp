#import <Foundation/Foundation.h>
#import "TKDApp.h"

@class TerminalApplication;


@interface TKDTerminalSessions : NSObject {
    TerminalApplication *terminal;
}

+(id) sharedTerminalSessions;

-(void) open;
-(void) openForApplication:(TKDApp *)app;

@end
