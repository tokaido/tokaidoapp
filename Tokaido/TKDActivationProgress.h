#import <Foundation/Foundation.h>

@protocol TKDActivationProgress <NSObject>
-(void) start;
-(void) configure:(id)loadingController;
@end
