//
//  FacebookAlbumsViewController.m
//  Scadaddle
//
//  Created by Roman Bigun on 9/09/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "YoutubeViewController.h"
#import "ABStoreManager.h"
#import "emsEditProfileVC.h"
#import "UserDataManager.h"
#import "MediaPickerViewController.h"
#import "UIAlertView+showMessage.h"
#import "emsScadProgress.h"

#define kYoutubeVideoDownloadCount 100

@interface YoutubeViewController ()
{

    NSArray *youtubeUserVideos;
    NSMutableArray *imagesForEditProfile;
    emsScadProgress * subView;
}
@end

@implementation YoutubeViewController


-(void)progress:(void (^)())callback;{
    
    if (subView == nil) {
        subView = [[emsScadProgress alloc] initWithFrame:self.view.frame screenView:self.view andSize:CGSizeMake(320, 580)];
        [self.view addSubview:subView];
        subView.alpha = 0;
        
        [UIView animateWithDuration:0.5 animations:^{
            subView.alpha = 1;
        } completion:^(BOOL finished) {
            callback();
        }];
        
    }
}

-(void)stopSubview{
    
    [UIView animateWithDuration:0.5 animations:^{
        subView.alpha = 0;
    } completion:^(BOOL finished) {
        [subView removeFromSuperview];
        subView = nil;
    }];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [self progress:^{
    
    }];
    if ( [[ABStoreManager sharedManager] editProfileMode] ){
        
        
        
        [self.xButton removeTarget:nil
                            action:NULL
                  forControlEvents:UIControlEventAllEvents];
        
        
        [self.xButton addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    }

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(manipulations:) name:@"GooglePlusLoginSuccessful" object:nil];
    self.youtubeVideoCollection.delegate = self;
    [self.youtubeVideoCollection registerClass:[YoutubeAlbumCollectionViewCell class] forCellWithReuseIdentifier:@"YoutubeAlbumCollectionViewCell"];
    
}
-(void)manipulations:(NSNotification *)notification
{

    youtubeUserVideos = [NSArray arrayWithArray:[Server youtubeVideo:kYoutubeVideoDownloadCount]];
    [self.youtubeVideoCollection reloadData];

}
-(void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:YES];
    
    if ([[ABStoreManager sharedManager] doneEditing]) {
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
    }
    
    youtubeUserVideos = [NSArray arrayWithArray:[Server youtubeVideo:kYoutubeVideoDownloadCount]];
    
    [self.youtubeVideoCollection reloadData];
    [self stopSubview];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma CollectionView
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [youtubeUserVideos count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"YoutubeAlbumCollectionViewCell";
    YoutubeAlbumCollectionViewCell *cell = (YoutubeAlbumCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        
        cell.albumCover.image = [UIImage imageNamed:@"placeholder"];
       
        self.indicator.center = cell.albumCover.center;
        self.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self.indicator startAnimating];
        [cell.albumCover addSubview:self.indicator];
        cell.itemId = youtubeUserVideos[indexPath.row][@"id"];
        cell.itemPath = youtubeUserVideos[indexPath.row][@"img"];
        NSString *url = youtubeUserVideos[indexPath.row][@"img"];
        cell.item = youtubeUserVideos[indexPath.row];
    
        if(![self imageHandler:url andImageView:cell.albumCover])
        {
            [self downloadImage:url andIndicator:self.indicator addToImageView:cell.albumCover];
            cell.albumName.text = youtubeUserVideos[indexPath.row][@"title"];
        }
    
    return cell;
}
-(IBAction)playVideoWithURL:(UIButton*)sender
{



}
- (UIButton *)findButtonInView:(UIView *)view {
    UIButton *button = nil;
    
    if ([view isMemberOfClass:[UIButton class]]) {
        return (UIButton *)view;
    }
    
    if (view.subviews && [view.subviews count] > 0) {
        for (UIView *subview in view.subviews) {
            button = [self findButtonInView:subview];
            if (button) return button;
        }
    }
    
    return button;
}
- (void)webViewDidFinishLoad:(UIWebView *)_webView {
    UIButton *b = [self findButtonInView:_webView];
    [b sendActionsForControlEvents:UIControlEventTouchUpInside];
}
-(void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *) indexPath {
    
    
   //
    
    [[NSUserDefaults standardUserDefaults] setValue:youtubeUserVideos[indexPath.row][@"id"] forKey:@"currentYTVideoID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ActivityBuilder_4" bundle:nil];
    MediaPickerViewController *m = (MediaPickerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MediaPicker"];
    m.curImage = [(YoutubeAlbumCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath] albumCover].image;
    m.curYoutubeObject = youtubeUserVideos[indexPath.row];
    [self presentViewController:m animated:YES completion:NULL];
    
    
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:youtubeUserVideos[indexPath.row][@"link"]]];
    
   //[self playMovieAtURL:[NSURL URLWithString:youtubeUserVideos[indexPath.row][@"link"]]];
    
    
    
}
/*!
 * @discussion  check whether image with path @param path cached or not.
 * If cached. add image to target else returns NO to start download
 * @param target image view to add retrived from cache image
 * @param path path to image
 */
-(BOOL)imageHandler:(NSString*)path andImageView:(UIImageView*)target
{
    
    UIImage *image = [[[ABStoreManager sharedManager] imageCache] objectForKey:path];
    if(image)
    {
        target.image = image;
        return YES;
    }
    return NO;
}
/*!
 * @discussion to download image by path and set image to appropriate image view
 * @param coverUrl absolute path to image
 * @param targetView set image here after download is complete
 */
-(void)downloadImage:(NSString *)coverUrl andIndicator:(UIActivityIndicatorView*)indicator addToImageView:(UIImageView*)targetView{
    __block UIImage *image = [UIImage new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:coverUrl]];
        image  = [UIImage imageWithData:imageData];
        dispatch_sync(dispatch_get_main_queue(), ^{
            targetView.image = image;
            if(image)
                [[[ABStoreManager sharedManager] imageCache] setObject:image forKey:coverUrl];
            [indicator stopAnimating];
        });
    });
    
    
}
#pragma mark Collection view layout things

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0;
}


- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(0,8,0,8);
}
-(void)test{
    
    [[ABStoreManager sharedManager] setDoneEditing:YES];
    
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
    
    
}
-(IBAction)back
{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}
@end
