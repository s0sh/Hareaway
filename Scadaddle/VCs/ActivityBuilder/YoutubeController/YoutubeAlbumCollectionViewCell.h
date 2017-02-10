//
//  FBAlbumCollectionViewCell.h
//  Scadaddle
//
//  Created by Roman Bigun on 6/20/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBAlbumCollectionViewCell : UICollectionViewCell<UICollectionViewDataSource,UICollectionViewDelegate>
{
    
}
@property (nonatomic, weak) IBOutlet UIImageView *albumCover;
@property (nonatomic, weak) IBOutlet UIImageView *picCountBg;
@property (nonatomic, weak) IBOutlet UILabel *albumName;
@property (nonatomic, weak) IBOutlet UILabel *picsCount;
@property (nonatomic, weak) IBOutlet UILabel *photoScript;
@property int albumId;
@end
