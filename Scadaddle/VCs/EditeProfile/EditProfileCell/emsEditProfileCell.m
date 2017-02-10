//
//  emsEditProfileCell.m
//  Scadaddle
//
//  Created by developer on 08/07/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsEditProfileCell.h"
#import "ABStoreManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "emsInterestsVC.h"
#import "emsAPIHelper.h"
@implementation emsEditProfileCell

- (void)awakeFromNib {

}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"emsEditProfileCell" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
        
        
        
    }
    return self;
}



-(void)configureCellItemsWithData:(NSString *)stringUrl
{
    
    
    NSLog(@" -------- %@",stringUrl);
    
    if([stringUrl containsString:@"photo_bg_small"]){
        
        self.userImage.image = [UIImage imageNamed:@"photo_bg_small"];
        
    }else{
        
        if([stringUrl containsString:@"assets"])
        {
            
            [self loadFromAssets:stringUrl addToImageView:self.userImage];
          
            
        }
        
        if([stringUrl containsString:@"https"]){
            
            [self downloadImage:stringUrl andIndicator:nil addToImageView:self.userImage];
        }
        
        
        if([stringUrl containsString:@"246_246"]){//Проверка на файл с вервера - при змененнии входных данных - изменить усло
            
          [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,stringUrl] andIndicator:nil addToImageView:self.userImage];
        }
        

    }
    
}

-(void)downloadImage:(NSNotification *)notification
{
    
    NSString * coverUrl = notification.userInfo[@"activityUrl"];
    NSLog(@"Url: %@",coverUrl);
    UIImageView * imageView = notification.userInfo[@"imageView"];
    if([coverUrl containsString:@"assets"])
    {
        
        [self loadFromAssets:coverUrl addToImageView:imageView];
        
    }
    else
    {
        imageView.image = [UIImage imageNamed:coverUrl];
        if (imageView.image == nil)
        {
            [self downloadImage:coverUrl andIndicator:nil addToImageView:imageView];
        }
    }
}



-(void)loadFromAssets:(NSString*)assetsUrl addToImageView:(UIImageView*)targetView
{
    
    ALAssetsLibrary *library = [[ABStoreManager sharedManager] getGallary] ;

    NSURL *yourAssetUrl = [NSURL URLWithString:assetsUrl];
    [library assetForURL:yourAssetUrl resultBlock:^(ALAsset *asset) {
        if (asset) {
            ALAssetRepresentation *imgRepresentation = [asset defaultRepresentation];
            CGImageRef imgRef = [imgRepresentation fullScreenImage];
            UIImage *img = [UIImage imageWithCGImage:imgRef];
            CGImageRelease(imgRef);
            targetView.image = img ;
        }
      
    } failureBlock:^(NSError *error) {
        
        
        NSLog(@"%@",error);
    }];
    
}
/*!
 * @discussion to download image by path and set image to appropriate image view
 * @param coverUrl absolute path to image
 * @param targetView set image here after download is complete
 */
-(void)downloadImage:(NSString *)coverUrl andIndicator:(UIActivityIndicatorView*)indicator addToImageView:(UIImageView*)targetView{
    UIImage *image = [UIImage new];
        NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:coverUrl]];
        image  = [UIImage imageWithData:imageData];
    [indicator stopAnimating];
    if (image == nil) {
        
        targetView.image = [UIImage imageNamed:@"placeholder"];
        
    }else{
            targetView.image = image;
    }
    
}




@end
