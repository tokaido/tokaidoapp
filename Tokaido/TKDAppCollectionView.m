#import "TKDAppCollectionView.h"
#import "TKDAppViewItem.h"
#import "TKDRailsAppTokenField.h"

@implementation TKDAppCollectionView

- (NSCollectionViewItem *)newItemForRepresentedObject:(id)object {
    TKDAppViewItem *appIcon = (TKDAppViewItem *)[super newItemForRepresentedObject:object];
    TKDAppViewItem *prototype = (TKDAppViewItem *)self.itemPrototype;
    
    appIcon.tokaidoController = prototype.tokaidoController;
    [appIcon view];
    
    appIcon.tokenField.delegate = appIcon;
    appIcon.appIcon.delegate = appIcon;
    
    [appIcon.appIcon configureForRepresentedObject];
    [appIcon.tokenField configureForRepresentedObject];
    
    return  appIcon;
}

@end
