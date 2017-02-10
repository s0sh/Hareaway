//
//  MoodesViewController.m
//  Scadaddle
//
//  Created by Roman Bigun on 5/14/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "MoodesViewController.h"
#import "emsMoodesCell.h"
#import "ABStoreManager.h"
#import "emsAPIHelper.h"
#import "PrimaryInterestImage.h"



@interface MoodesViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    UIImage *currentImage;
}
@property (nonatomic, weak) IBOutlet UIImageView *interestView;
@property (nonatomic, weak) IBOutlet UIImageView *background;
@property (nonatomic, weak) IBOutlet UIView *viewForCollections;
@property (nonatomic, weak) IBOutlet UICollectionView *interesrtsCollection;
@property (retain, nonatomic) NSArray *interestsArray;

@end

@implementation MoodesViewController

-(void)awakeFromNib
{

    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadImage:)
                                                 name:@"MLDownloadImageNotification"
                                               object:nil];
    self.background.layer.cornerRadius = 0.9;
    [self cornerIm:self.interestView];
    //Get stored interest
    if([[ABStoreManager sharedManager] getABInterestImage]!=nil)
    {
        //is exist apply
        self.interestView.image = [[ABStoreManager sharedManager] getABInterestImage];
    }
    
    self. viewForCollections.layer.cornerRadius = 2;
    self.viewForCollections.layer.masksToBounds = YES;
    self.interesrtsCollection.layer.cornerRadius = 12;
    self.interesrtsCollection.layer.masksToBounds = YES;

}

-(void)setArray{
    
    if(self.interestsArray.count==0)
       self.interestsArray = [NSArray arrayWithArray:[Server profile][@"interestActivity"]];
    
    self.layer.cornerRadius = 2;
    self.viewForCollections.layer.masksToBounds = YES;
    self.interesrtsCollection.layer.cornerRadius = 12;
    self.interesrtsCollection.layer.masksToBounds = YES;
    
    
}
/*!
 * @discussion Download primary interest for current activity
 */
-(void)downloadPrimaryInterest
{
    if([[ABStoreManager sharedManager] ongoingActivity].count>1)
    {
        if(self.interestsArray.count==0)
            self.interestsArray = [NSArray arrayWithArray:[Server interests]];
        
        for (NSDictionary * obj in self.interestsArray){
            if([[NSString stringWithFormat:@"%@",[obj objectForKey:@"id"]] isEqualToString:[[ABStoreManager sharedManager] ongoingActivity][vInterest]]){
                [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,obj[@"file"][@"filepath"]] andIndicator:nil addToImageView:self.interestView];
            }
        }
        if(self.interestView.image == nil)
            self.interestView.image = [[PrimaryInterestImage sharedInstance] interestImage];
    }
    else
    {
    
        self.interestView.image = [[PrimaryInterestImage sharedInstance] interestImage];
        
        
    
    }
            

}
- (void)predefine{
   
    [self setUpInterestsView];
    [self cornerIm:self.interestView];
    [self setArray];
    [self.interesrtsCollection registerClass:[emsMoodesCell class] forCellWithReuseIdentifier:@"emsMoodesCell"];
    [self.interesrtsCollection reloadData];
    
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
   
    return [self.interestsArray count];
}
-(void)cornerIm:(UIImageView*)imageView{
    imageView .layer.cornerRadius = imageView.frame.size.height/2;
    imageView.layer.masksToBounds = YES;
}



-(void)hideInterests{
    
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 0;
        
    } completion:^(BOOL finished) {
        
    }];
}

-(void)setUpInterestsView{
    
    self.alpha=1;
    
}
/*!
 * @discussion  check whether image with path @param path cached or not.
 * If cached. add image to target else returns NO to start download
 * @param imageView image view to add retrived from cache image
 * @param path path to image
 */
-(BOOL)imageHandlerInterest:(NSString*)path andInterestView:(UIImageView *)imageView
{
    UIImage *image = [[[ABStoreManager sharedManager] imageCache] objectForKey:path];
    
    if(image)
    {
        imageView.image = image;
        
        return YES;
    }
    
    
    return NO;
}
/*!
 * @discussion  check whether image with path @param path cached or not.
 * If cached. add image to target else returns NO to start download
 * @param path path to image
 */
-(BOOL)imageHandler:(NSString*)path
{
    
    UIImage *image = [[[ABStoreManager sharedManager] imageCache] objectForKey:path];
    if(image)
    {
        self.interestView.image = image;
        [[ABStoreManager sharedManager] setActivityInterestImage:image];
        return YES;
    }
    return NO;
}
-(void)downloadImage:(NSNotification *)notification
{
    
    NSString * coverUrl = notification.userInfo[@"activityUrl"];
    if(![self imageHandler:coverUrl])
    {
        [self downloadImage:[coverUrl containsString:@"http"]?coverUrl:[NSString stringWithFormat:@"%@%@",SERVER_PATH,coverUrl] andIndicator:nil addToImageView:self.interestView];
    }
    
    
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
        [indicator stopAnimating];
        dispatch_sync(dispatch_get_main_queue(), ^{
            targetView.image = image;
            [[ABStoreManager sharedManager] setActivityInterestImage:image];
            if(image)
               [[[ABStoreManager sharedManager] imageCache] setObject:image forKey:coverUrl];
            
        });
    });
    
}

#pragma CollectionView
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"emsMoodesCell";
    
    emsMoodesCell *cell = (emsMoodesCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if(![self imageHandlerInterest:self.interestsArray[indexPath.row][@"img"] andInterestView:cell.interestsImage])
    {
       [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,self.interestsArray[indexPath.row][@"img"]] andIndicator:nil addToImageView:cell.interestsImage];
    }
    [self cornerIm:cell.interestsImage];
    cell.interestsName.text = self.interestsArray[indexPath.row][@"name"];
    cell.indexpath = indexPath;
    cell.selectInterest.tag = indexPath.row;
    [cell.selectInterest addTarget:self action:@selector(selectInterest:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}
-(IBAction)selectInterest:(emsMoodesCell*)sender{
    
    
    __block UIImage *image = [UIImage new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.interestsArray[sender.tag][@"img"]]];
        image  = [UIImage imageWithData:imageData];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[ABStoreManager sharedManager] setActivityInterestImage:image];
             self.interestView.image = image;
        });
    });
    
    
    [self hideInterests];
    [[ABStoreManager sharedManager] addData:[NSString stringWithFormat:@"%@",self.interestsArray[sender.tag][@"id"]] forKey:@"primaryInterest"];
    
}
-(void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    [[ABStoreManager sharedManager] setActivityInterestImage:[(emsMoodesCell*)[collectionView cellForItemAtIndexPath:indexPath] interestsImage].image];
    self.interestView.image = [(emsMoodesCell*)[collectionView cellForItemAtIndexPath:indexPath] interestsImage].image;
    
    [self hideInterests];
    [[ABStoreManager sharedManager] addData:[NSString stringWithFormat:@"%@",self.interestsArray[indexPath.row][@"id"]] forKey:@"primaryInterest"];
        
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
-(IBAction)clearImage{
    
    [UIView animateWithDuration:0.4 animations:^{
        self.interestView.image = [UIImage imageNamed:@"placeholder_menu"];
        [[ABStoreManager sharedManager] setActivityInterestImage:nil];
    }];
}
-(IBAction)selectInterests{
    
    [UIView animateWithDuration:0.4 animations:^{
        
        [self predefine];
        self.alpha=1;
        
        
    } completion:^(BOOL finished) {
        
    }];
    
}

@end
