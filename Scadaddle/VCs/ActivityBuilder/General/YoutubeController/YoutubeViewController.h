//
//  FacebookAlbumsViewController.h
//  Scadaddle
//
//  Created by Roman Bigun on 9/09/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YoutubeAlbumCollectionViewCell.h"
#import "SocialsManager.h"
#import <MediaPlayer/MediaPlayer.h>

@interface YoutubeViewController : UIViewController<UIWebViewDelegate>
{

    SocialsManager *sm;
    UIWebView *youTubeWebView;
    
}
@property (nonatomic, weak) IBOutlet UICollectionView *youtubeVideoCollection;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, weak) IBOutlet UILabel *titleLbl;
@property (nonatomic, weak) IBOutlet UIButton *xButton;
@end
