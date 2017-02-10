//
//  emsInterestsPopup.m
//  ActivityCreator
//
//  Created by Roman Bigun on 5/6/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsInterestsPopup.h"
#import "emsAPIHelper.h"
@implementation emsInterestsPopup
{

     NSArray *interests;

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupCollectionView];
        
    }
    return self;
}
-(void)awakeFromNib
{
    interests = [[NSArray alloc] initWithArray:[Server interests]];
    [super awakeFromNib];

}
-(void)setupCollectionView
{

    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    collectionView=[[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:layout];
    [collectionView setDataSource:self];
    [collectionView setDelegate:self];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"InterestCollectionViewCell"];
    [collectionView setBackgroundColor:[UIColor clearColor]];
    collectionView.layer.cornerRadius = 12;
    
    [self addSubview:collectionView];

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 15;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionViewOuter cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"InterestCollectionViewCell";
    
    InterestCollectionViewCell *cell = (InterestCollectionViewCell *)[collectionViewOuter dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell.interestImage setImage:[UIImage imageNamed:@"surfing_interests"]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(70, 70);
}
@end
