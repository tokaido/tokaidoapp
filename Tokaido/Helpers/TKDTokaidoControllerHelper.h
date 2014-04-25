#import <Foundation/Foundation.h>
@class TKDTokaidoController, TKDApp;

@interface TKDTokaidoControllerHelper : NSObject

- (id) initWithController:(TKDTokaidoController *)controller;

- (TKDApp *)selectedApp;
- (BOOL)didSelectAnApp;


@property TKDTokaidoController *controller;

@end
