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
@interface FacebookAlbumsViewController ()
{

    NSArray *facebookAlbumsArray;
    NSMutableArray *imagesForEditProfile;

}
@end

@implementation FacebookAlbumsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // - if editProfile
    if ( [[ABStoreManager sharedManager] editProfileMode] ){
    
        
        
        [self.xButton removeTarget:nil
                                    action:NULL
                          forControlEvents:UIControlEventAllEvents];
        
   
        
    }
    
    [self.xButton addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    imagesForEditProfile =[[NSMutableArray alloc] init];
    //--------
    isAlbum = YES;
    self.facebookAlbumsCollection.delegate = self;
    [self.facebookAlbumsCollection registerClass:[FBAlbumCollectionViewCell class] forCellWithReuseIdentifier:@"FBAlbumCollectionViewCell"];
    sm = [[SocialsManager alloc] init];
}
-(void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:YES];
    
    facebookAlbumsArray = [NSArray arrayWithArray:[sm fbUserAlbums]];
    [self.facebookAlbumsCollection reloadData];
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
    return [facebookAlbumsArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    static NSString *cellIdentifier = @"FBAlbumCollectionViewCell";
    FBAlbumCollectionViewCell *cell = (FBAlbumCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        
    if(isAlbum)
    {
       
        self.indicator.center = cell.albumCover.center;
        self.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self.indicator startAnimating];
        [cell.albumCover addSubview:self.indicator];
        NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=album&access_token=%@",facebookAlbumsArray[indexPath.row][@"cover_photo"],[FBSession activeSession].accessTokenData.accessToken] ;
        cell.picsCount.text = [[NSString stringWithFormat:@"%@",facebookAlbumsArray[indexPath.row][@"count"]] isEqualToString:@"(null)"]?@"0":[NSString stringWithFormat:@"%@",facebookAlbumsArray[indexPath.row][@"count"]];
        cell.picCountBg.alpha = 1;
        cell.picsCount.alpha = 1;
        cell.photoScript.alpha=1;
        [self downloadImage:url andIndicator:self.indicator addToImageView:cell.albumCover];
    }
    else
    {
        self.indicator.center = cell.albumCover.center;
        self.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self.indicator startAnimating];
        [cell.albumCover addSubview:self.indicator];
       [self downloadImage:facebookAlbumsArray[indexPath.row][@"images"][0][@"source"] andIndicator:self.indicator addToImageView:cell.albumCover];
        cell.picCountBg.alpha = 0;
        cell.picsCount.alpha = 0;
        cell.photoScript.alpha=0;
    }
    cell.albumName.text = facebookAlbumsArray[indexPath.row][@"name"];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *) indexPath {
    
    if(isAlbum==NO)
    {
        
        if ([[ABStoreManager sharedManager] chatMode])//НавКонтроллепр - его нет ((
        {
            
            [[ABStoreManager sharedManager] setImageForChat:[(FBAlbumCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath] albumCover].image];
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
            
        }else{
        
        [imagesForEditProfile  addObject:[(FBAlbumCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath] albumCover].image];
        
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ActivityBuilder_4"
                                                             bundle:nil];
        MediaPickerViewController *m = (MediaPickerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MediaPicker"];
         m.curImage = [(FBAlbumCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath] albumCover].image;
        [self presentViewController:m animated:YES completion:NULL];
        
        }
        /*
        UIImageView *check = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 0, 0)];
        [check setImage:[UIImage imageNamed:@"chek_icon_green_builder"]];
        [(FBAlbumCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath] addSubview:check];
        
        [UIView animateWithDuration:0.2 animations:^{
            
            check.frame = CGRectMake(50, 40, 60, 60);
           
                         
        } completion:^(BOOL finished) {
            [(FBAlbumCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath] setUserInteractionEnabled:NO];
            
            [UIView animateWithDuration:0.2 animations:^{
                check.frame = CGRectMake(50, 40, 40, 40);
               
            } completion:^(BOOL finished) {
                
            }];
        }];
        
        */
        
        
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

-(void)downloadImage:(NSString *)coverUrl andIndicator:(UIActivityIndicatorView*)indicator addToImageView:(UIImageView*)targetView{
    __block UIImage *image = [UIImage new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:coverUrl]];
        image  = [UIImage imageWithData:imageData];
        dispatch_sync(dispatch_get_main_queue(), ^{
            targetView.image = image;
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

    
    
    NSLog(@"%@",imagesForEditProfile);
    
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:imagesForEditProfile forKey:@"file" ];
    [dict setObject:[[UserDataManager sharedManager] serverToken] forKey:@"restToken"];
    
    [Server postProfileInfoandUserID:dict callback:^(NSDictionary *dictionary) {
        
        NSLog(@"%@",dictionary);
        
    }];
    

    
    
    [self presentViewController:[[emsEditProfileVC alloc] initWithData:nil] animated:YES completion:^{
        
    }];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
