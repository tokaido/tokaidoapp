#import <Foundation/Foundation.h>

@class TKDTokaidoController, TKDApp, TKDCubalogApp;

@interface TKDTokaidoControllerHelper : NSObject

- (id) initWithController:(TKDTokaidoController *)controller;

- (TKDApp *)selectedApp;
- (BOOL)didSelectAnApp;

-(TKDCubalogApp *)loggerApp;


@property TKDTokaidoController *controller;

@end
