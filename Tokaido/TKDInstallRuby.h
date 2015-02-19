#import <Foundation/Foundation.h>
#import "TKDAppSupportEnsure.h"

@class TKDRubyBinary;

@interface TKDInstallRuby : NSObject {
@private id <TKDAppSupportEnsure> _view;
}

@property (nonatomic, copy) TKDRubyBinary *bin;

-(TKDInstallRuby *) initWithRubyBinary:(TKDRubyBinary *)bin withView:(id <TKDAppSupportEnsure>)view;

-(void) install;
-(void) symlink;

@end
