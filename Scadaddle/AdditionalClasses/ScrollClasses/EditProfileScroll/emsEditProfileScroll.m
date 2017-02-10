//
//  emsEditProfileScroll.m
//  Scadaddle
//
//  Created by developer on 07/07/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsEditProfileScroll.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ABStoreManager.h"
#import "EditProfileImage.h"

@interface emsEditProfileScroll ()


@property (nonatomic, weak) IBOutlet UIButton *addNewImaheButton;
@property(nonatomic, weak)IBOutlet UIScrollView *imageScroll;
@property(retain,nonatomic)NSMutableArray *imagesArray;

@property(retain,nonatomic)NSMutableArray *imagesForSent;
@end


@implementation emsEditProfileScroll

-(void)reloadData:(NSArray *)data{
    [self.imagesArray removeAllObjects];
    [self.imagesForSent removeAllObjects];
    self.imagesArray = [[NSMutableArray alloc] initWithArray:data];
    
    [self setUpInages ];
    
}
- (id)initWithFrame:(CGRect)frame andData:(NSArray *)data
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.imagesArray = [[NSMutableArray alloc] initWithArray:data];
        
        self.imagesForSent = [[NSMutableArray alloc] init];
        
        UINib *nib = [UINib nibWithNibName:@"emsEditProfileScroll" bundle:nil];
        
        [self addSubview:[[nib instantiateWithOwner:self options:nil] objectAtIndex:0]];
        
    }
    return self;
}

-(void)reloadScrol{
    [self setUpInages];
}
-(void)didMoveToWindow{
    
}

/*!
 *
 * @discussion  Method  sets  array of images and frame
 *
 */
-(void)setUpInages{
    
    CGFloat myDataScrollIndex = 8;
    
    [self.imageScroll.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (int i =0; i<[self.imagesArray count];i++ ) {
        
        EditProfileImage * editProfileImage = [self.imagesArray objectAtIndex:i];
        
        myDataScrollIndex = myDataScrollIndex+7 ;
        
        self.imageScroll.contentSize = CGSizeMake(myDataScrollIndex +100, 0);
        
        UIImageView *activityImage = [[UIImageView alloc] init];
        
        activityImage.frame = CGRectMake(myDataScrollIndex, 0, 54, 54);
        
        myDataScrollIndex = myDataScrollIndex+activityImage.frame.size.width;
        
        UIButton *zoomButton =[[UIButton alloc] initWithFrame:activityImage.frame];
        
        zoomButton.tag = i;
        
        
        [zoomButton addTarget:self action:@selector(showDetail:) forControlEvents:UIControlEventTouchUpInside];
        
        NSString *stringUrl =editProfileImage.path246x246 ;
        
        if([stringUrl containsString:@"photo_bg_small"]){
            
            activityImage.image = [UIImage imageNamed:@"photo_bg_small"];
            
        }else{
            
            if([stringUrl containsString:@"assets"])
            {
                [self loadFromAssets:stringUrl addToImageView:activityImage];
                
            }
            if([stringUrl containsString:@"https"]){
                
                [self downloadImage:stringUrl andIndicator:nil addToImageView:activityImage];
            }
            
            if([stringUrl containsString:@"246_246"]){//Проверка на файл с вервера - при змененнии входных данных - изменить усло
                
                [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,stringUrl] andIndicator:nil addToImageView:activityImage];
            }
            
        }
        
        [self.imageScroll addSubview:activityImage];
        
        if(![stringUrl containsString:@"photo_bg_small"]){
            
            [self.imageScroll addSubview:zoomButton];
        }
        
        [self.imagesForSent addObject:activityImage];
        
        
        if ([editProfileImage.isPrimary isEqualToString:@"1"]) {
            
            UIImageView *mainIm = [[UIImageView alloc] initWithFrame:CGRectMake(activityImage.frame.origin.x+15, activityImage.frame.origin.y+15, 24, 24)];
            
            mainIm.image = [UIImage imageNamed:@"main_photo_icon-1"];
            
            [self.imageScroll addSubview:mainIm];
        }
        
        if (editProfileImage.isDeleted == YES) {
            
            UIImageView *cancelDeleting =[[UIImageView alloc]initWithFrame:CGRectMake(activityImage.frame.origin.x+15, activityImage.frame.origin.y+15, 24, 24)];
            
            cancelDeleting.image = [UIImage imageNamed:@"delete_photo_icon"];
            
            [self.imageScroll addSubview:cancelDeleting];
            
        }
    }
}



/*
 *
 *  @discussion Load by path from WEB
 *
 */
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

/*
 *
 *  @discussion Load by path from gallary
 *
 */

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

    __block UIImage *image = [UIImage new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:coverUrl]];
        image  = [UIImage imageWithData:imageData];
        dispatch_sync(dispatch_get_main_queue(), ^{
                targetView.image = image;
        });
    });
}
/*
 *
 *  @discussion Send deteled image
 *
 */

-(void)showDetail:(UIButton*)sender{
    
    EditProfileImage * editProfileImage = [self.imagesArray objectAtIndex:(int)sender.tag];
    
    if([self.delegate respondsToSelector:@selector(selectrdImage:andIndex:)]) {
        
        [self.delegate selectrdImage:editProfileImage.path600x370 andIndex:(int)sender.tag];
    }
    
    
}

/*
 *
 *  @discussion CansilDeleting image
 *
 */
-(void)cansilDeleting:(UIButton*)sender{
    
    EditProfileImage * editProfileImage = [self.imagesArray objectAtIndex:(int)sender.tag];
    
    if([self.delegate respondsToSelector:@selector(selectrdImage:andIndex:)]) {
        
        [self.delegate selectrdImage:editProfileImage.path600x370 andIndex:(int)sender.tag];
    }
    
    
}

-(void)dealloc{

    NSLog(@"%@",self);

}

@end
