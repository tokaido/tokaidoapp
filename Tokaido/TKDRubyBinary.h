#import <Foundation/Foundation.h>

@class TKDRubyBinaryFinder;

@interface TKDRubyBinary : NSObject

@property (nonatomic, assign) NSString *name;
@property (nonatomic, retain) TKDRubyBinaryFinder *searcher;

-(TKDRubyBinary *) initWithName:(NSString *)name;

-(BOOL) isNotInstalled;

@end
