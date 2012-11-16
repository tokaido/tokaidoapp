//
//  TKDAppCollectionView.m
//  Tokaido
//
//  Created by Mucho Besos on 11/13/12.
//  Copyright (c) 2012 Tilde. All rights reserved.
//

#import "TKDAppCollectionView.h"
#import "TKDRailsAppIcon.h"

@implementation TKDAppCollectionView

- (NSCollectionViewItem *)newItemForRepresentedObject:(id)object;
{
    TKDRailsAppIcon *appIcon = (TKDRailsAppIcon *)[super newItemForRepresentedObject:object];
    TKDRailsAppIcon *prototype = (TKDRailsAppIcon *)self.itemPrototype;
    appIcon.tokaidoController = prototype.tokaidoController;
    [appIcon view]; // force load the view
    appIcon.tokenField.delegate = appIcon;
    return  appIcon;
}

@end
