//
//  TKDMuxrManager.h
//  Tokaido
//
//  Created by Patrick B. Gibson on 4/3/13.
//  Copyright (c) 2013 Tilde. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TKDMuxrManager : NSObject

+ (id)defaultManager;
- (BOOL)setupSocket;

@end
