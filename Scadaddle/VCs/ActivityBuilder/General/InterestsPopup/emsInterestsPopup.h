//
//  emsInterestsPopup.h
//  ActivityCreator
//
//  Created by Roman Bigun on 5/6/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InterestCollectionViewCell.h"
@interface emsInterestsPopup : UIView<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{

    UICollectionView * collectionView;
    
}
- (id)initWithFrame:(CGRect)frame;
@end
