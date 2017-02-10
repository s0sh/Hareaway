//
//  FacebookAlbumsViewController.h
//  Scadaddle
//
//  Created by Roman Bigun on 6/20/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBAlbumCollectionViewCell.h"
#import "SocialsManager.h"


@interface FacebookAlbumsViewController : UIViewController
{

    SocialsManager *sm;
    BOOL isAlbum;
    
}
@property (nonatomic, weak) IBOutlet UICollectionView *facebookAlbumsCollection;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, weak) IBOutlet UILabel *titleLbl;
@property (nonatomic, weak) IBOutlet UIButton *xButton;
@end
