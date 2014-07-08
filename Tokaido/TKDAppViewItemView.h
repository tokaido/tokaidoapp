//
//  TKDAppViewItemView.h
//  Tokaido
//
//  Created by Martin Schürrer on 06.07.13.
//  Copyright (c) 2013 Martin Schürrer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TKDAppViewItem;
@interface TKDAppViewItemView : NSView

@property (nonatomic, weak) IBOutlet TKDAppViewItem *delegate;

@end
