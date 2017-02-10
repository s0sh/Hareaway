//
//  FacebookAlbumsViewController.m
//  Scadaddle
//
//  Created by Roman Bigun on 6/20/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "FacebookAlbumsViewController.h"
#import "ABStoreManager.h"
#import "emsEditProfileVC.h"
#import "UserDataManager.h"
#import "MediaPickerViewController.h"
#import "emsScadProgress.h"

@interface FacebookAlbumsViewController ()
{

    NSArray *facebookAlbumsArray;
    NSMutableArray *imagesForEditProfile;
    emsScadProgress * subView;
}
@end

@implementation FacebookAlbumsViewController

/*!
 * @discussion  creates and launches progress indicator
 */
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
/*!
 * @discussion  hide progress indicator
 * @see emsScadProgress class
 */
-(void)stopSubview{
    
    [UIView animateWithDuration:0.5 animations:^{
        subView.alpha = 0;
    } completion:^(BOOL finished) {
        [subView removeFromSuperview];
        subView = nil;
    }];
}

-(IBAction)back
{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self progress:^{
    
    }];
    // - if editProfile
    
       if ( [[ABStoreManager sharedManager] editProfileMode] ){
    
        
        
        [self.xButton removeTarget:nil
                                    action:NULL
                          forControlEvents:UIControlEventAllEvents];
        
   
        [self.xButton addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    imagesForEditProfile =[[NSMutableArray alloc] init];
    //--------
    isAlbum = YES;
    self.facebookAlbumsCollection.delegate = self;
    [self.facebookAlbumsCollection registerClass:[FBAlbumCollectionViewCell class] forCellWithReuseIdentifier:@"FBAlbumCollectionViewCell"];
    sm = [[SocialsManager alloc] init];
    
}
/*!
 * @discussion  check whether image with path @param path cached or not.
 * If cached. add image to target else returns NO to start download
 * @param target image view to add retrived from cache image
 * @param path absolute path to image
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
-(void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:YES];
    
    facebookAlbumsArray = [NSArray arrayWithArray:[sm fbUserAlbums]];
    [self.facebookAlbumsCollection reloadData];
    
    if ([[ABStoreManager sharedManager] doneEditing]) {
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
    }
    [self stopSubview];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -CollectionView
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [facebookAlbumsArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"FBAlbumCollectionViewCell";
    FBAlbumCollectionViewCell *cell = (FBAlbumCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.albumCover.image = [UIImage imageNamed:@"placeholder"];
    if(isAlbum)
    {
       
        self.indicator.center = cell.albumCover.center;
        self.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self.indicator startAnimating];
        [cell.albumCover addSubview:self.indicator];
        NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=album&access_token=%@",facebookAlbumsArray[indexPath.row][@"cover_photo"],[[NSUserDefaults standardUserDefaults] objectForKey:@"FBToken"]] ;
        cell.picsCount.text = [[NSString stringWithFormat:@"%@",
                                facebookAlbumsArray[indexPath.row][@"count"]]
                                isEqualToString:@"(null)"]?@"0":[NSString stringWithFormat:@"%@",facebookAlbumsArray[indexPath.row][@"count"]];
        cell.picCountBg.alpha = 1;
        cell.picsCount.alpha =  1;
        cell.photoScript.alpha= 1;
        if(![self imageHandler:url andImageView:cell.albumCover]){
            [self downloadImage:url andIndicator:self.indicator addToImageView:cell.albumCover];
        }
    }
    else
    {
        self.indicator.center = cell.albumCover.center;
        self.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self.indicator startAnimating];
        [cell.albumCover addSubview:self.indicator];
        if(![self imageHandler:facebookAlbumsArray[indexPath.row][@"images"][0][@"source"] andImageView:cell.albumCover]){
           [self downloadImage:facebookAlbumsArray[indexPath.row][@"images"][0][@"source"] andIndicator:self.indicator addToImageView:cell.albumCover];
        }
        cell.picCountBg.alpha = 0;
        cell.picsCount.alpha =  0;
        cell.photoScript.alpha= 0;
    }
    cell.albumName.text = facebookAlbumsArray[indexPath.row][@"name"];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *) indexPath {
    
    if(isAlbum==NO)
    {
        
        [imagesForEditProfile  addObject:[(FBAlbumCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath] albumCover].image];
        [[ABStoreManager sharedManager] setImageForChat:[(FBAlbumCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath] albumCover].image];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ActivityBuilder_4" bundle:nil];
        MediaPickerViewController *m = (MediaPickerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MediaPicker"];
         m.curImage = [(FBAlbumCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath] albumCover].image;
        [self presentViewController:m animated:YES completion:NULL];
      
    }
    else
    {
    NSArray *tmp = [NSArray arrayWithArray:[sm fbUserImagesWithId:facebookAlbumsArray[indexPath.row][@"id"]]];
    if([tmp isKindOfClass:[NSArray class]] && tmp.count>0){
        facebookAlbumsArray = tmp;
        isAlbum = NO;
        [self.facebookAlbumsCollection reloadData];
    }
    }
    
}
/*!
 * @discussion to download image
 * @param coverUrl image path
 * @param targetView imageView to set downloaded image
 */
-(void)downloadImage:(NSString *)coverUrl andIndicator:(UIActivityIndicatorView*)indicator addToImageView:(UIImageView*)targetView{
    __block UIImage *image = [UIImage new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:coverUrl]];
        image  = [UIImage imageWithData:imageData];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [indicator stopAnimating];
            if (image == nil) {
                targetView.image = [UIImage imageNamed:@"placeholder"];
            }else{
                targetView.image = image;
            }
            if(image)
                [[[ABStoreManager sharedManager] imageCache] setObject:image forKey:coverUrl];
        });
       
    });
    
}
#pragma mark Collection view layout methods
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

    if ([[ABStoreManager sharedManager] chatMode] ) {
        [[ABStoreManager sharedManager] setDoneEditing:YES];
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
        
    }else{
        [[ABStoreManager sharedManager] setDoneEditing:YES];
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];

    }
}
@end
