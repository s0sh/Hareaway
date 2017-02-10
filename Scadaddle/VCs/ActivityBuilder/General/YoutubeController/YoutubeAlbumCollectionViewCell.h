//
//  FBAlbumCollectionViewCell.h
//  Scadaddle
//
//  Created by Roman Bigun on 6/20/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YoutubeAlbumCollectionViewCell : UICollectionViewCell<UICollectionViewDataSource,UICollectionViewDelegate>
{
    
}
@property (nonatomic, weak) IBOutlet UIImageView *albumCover;
@property (nonatomic, weak) IBOutlet UIImageView *picCountBg;
@property (nonatomic, weak) IBOutlet UILabel *albumName;
@property (nonatomic, weak) IBOutlet UILabel *picsCount;
@property (nonatomic, weak) IBOutlet UILabel *photoScript;
@property (nonatomic, weak) IBOutlet UIButton *playBtn;
@property (nonatomic, weak) IBOutlet UIButton *checkBtn;
@property (nonatomic, strong) NSString *itemId;
@property (nonatomic, strong) NSString *itemPath;
@property (nonatomic, strong) NSString *itemLink;
@property (nonatomic, strong) NSString *itemTitle;
@property (nonatomic, strong) NSDictionary *item;
@property int albumId;
@property BOOL isChecked;

-(IBAction)check;
@end
