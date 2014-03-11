#import "TKDConfiguration.h"
#import "TKDFileUtilities.h"
#import "TKDRubyBinaryFinder.h"
#import "TKDRubyBinary.h"

@implementation TKDRubyBinaryFinder

-(TKDRubyBinaryFinder *) init {
  if (self = [super init]) {}
	return self;												 
}

-(Class) configuration {
  return [TKDConfiguration self];
}

-(Class) fileManager {
  return [TKDFileUtilities self];
}

- (BOOL) didFindInstallationWithRuby:(TKDRubyBinary *)binary {
  return [[self fileManager] directoryExists:[[[self configuration] rubiesInstalledDirectoryPath] stringByAppendingPathComponent:[binary name]]];
}

@end
