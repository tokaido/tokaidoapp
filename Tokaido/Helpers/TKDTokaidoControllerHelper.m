#import "TKDTokaidoControllerHelper.h"
#import "TKDTokaidoController.h"
#import "TKDApp.h"

@implementation TKDTokaidoControllerHelper

- (id)init {
  if (self = [super init]) {
  }
  return self;
}

- (id) initWithController:(TKDTokaidoController *)controller {
  self = [super init];
 
  if (self) {
    self.controller = controller;
  }
 
  return self;
}

-(TKDApp *)selectedApp {
  if (![self didSelectAnApp])
    return [[TKDNullApp alloc] init];
 
  return [self.controller.appsArrayController.selectedObjects objectAtIndex:0];
}

- (BOOL)didSelectAnApp {
  return ([self.controller.appsArrayController.selectedObjects count] == 0) ? NO : YES;
}

@end

