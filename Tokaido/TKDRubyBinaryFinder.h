#import <Foundation/Foundation.h>

@class TKDRubyBinary;

@interface TKDRubyBinaryFinder : NSObject

-(BOOL) didFindInstallationWithRuby:(TKDRubyBinary *)binary;

@end
