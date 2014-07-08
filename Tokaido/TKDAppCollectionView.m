//
//  TKDAppCollectionView.m
//  Tokaido
//
//  Created by Mucho Besos on 11/13/12.
//  Copyright (c) 2012 Tilde. All rights reserved.
//

#import "TKDAppCollectionView.h"
#import "TKDAppViewItem.h"
#import "TKDRailsAppTokenField.h"

@implementation TKDAppCollectionView

- (NSCollectionViewItem *)newItemForRepresentedObject:(id)object;
{
    TKDAppViewItem *appIcon = (TKDAppViewItem *)[super newItemForRepresentedObject:object];
    TKDAppViewItem *prototype = (TKDAppViewItem *)self.itemPrototype;
    appIcon.tokaidoController = prototype.tokaidoController;
    [appIcon view]; // force load the view
    appIcon.tokenField.delegate = appIcon;
    [appIcon.tokenField configureForRepresentedObject];
    return  appIcon;
}

@end
