//
//  TKDApp.m
//  Tokaido
//
//  Created by Mucho Besos on 10/25/12.
//  Copyright (c) 2012 Tilde. All rights reserved.
//

#import "TKDApp.h"

@implementation TKDApp

- (void)showInFinder;
{
    
    [[NSWorkspace sharedWorkspace] openFile:self.appDirectoryPath];
}

@end
