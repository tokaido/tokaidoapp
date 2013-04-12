//
//  TKDMuxrManager.h
//  Tokaido
//
//  Created by Patrick B. Gibson on 4/3/13.
//  Copyright (c) 2013 Tilde. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TKDApp.h"

extern  NSString * const kMuxrNotification;

@interface TKDMuxrManager : NSObject

+ (id)defaultManager;

- (void)addApp:(TKDApp *)app;
- (void)removeApp:(TKDApp *)app;

@end
