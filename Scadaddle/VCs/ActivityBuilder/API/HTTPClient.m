//
//  HTTPClient.m
//  ActivityCreator
//
//  Created by Roman Bigun on 5/6/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "HTTPClient.h"
#import <AssetsLibrary/AssetsLibrary.h>
@implementation HTTPClient

- (id)init
{
    self = [super init];
    if (self)
    {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(downloadImage:)
                                                     name:@"BLDownloadImageNotification"
                                                   object:nil];
        
    }
    return self;
}

+ (HTTPClient *)sharedInstance
{
    static HTTPClient * _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[HTTPClient alloc] init];
    });
    return _sharedInstance;
}
/*!
 @discussion Choose from where to load images
 */
-(void)downloadImage:(NSNotification *)notification
{
    NSString * coverUrl = notification.userInfo[@"activityUrl"];
    NSLog(@"Url: %@",coverUrl);
    UIImageView * imageView = notification.userInfo[@"imageView"];
    
    if([coverUrl containsString:@"assets"]){
        [self loadFromAssets:coverUrl addToImageView:imageView];
    }else{
   
        imageView.image = [UIImage imageNamed:coverUrl];
        if (imageView.image == nil)
        {
             [self downloadImage:coverUrl andIndicator:nil addToImageView:imageView];
        }
        
    }
}
/*!
 @discussion Makes image square-shaped
 */
-(UIImage *)makeSquare:(UIImage*)source
{
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([source CGImage], CGRectMake(source.size.width/2, source.size.height/2, source.size.height/2, source.size.height/2));
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
    
}
/*!
 @discussion Load from Library
 */
-(void)loadFromAssets:(NSString*)assetsUrl addToImageView:(UIImageView*)targetView
{
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    NSURL *yourAssetUrl = [NSURL URLWithString:assetsUrl];
    [library assetForURL:yourAssetUrl resultBlock:^(ALAsset *asset) {
        if (asset) {
            ALAssetRepresentation *imgRepresentation = [asset defaultRepresentation];
            CGImageRef imgRef = [imgRepresentation fullScreenImage];
            UIImage *img = [UIImage imageWithCGImage:imgRef];
            CGImageRelease(imgRef);
            if(img)
            {
                targetView.image = [self makeSquare:img];
            }
            
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"Error loading file %@",[error description]);
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
            if(image)
                targetView.image = [coverUrl containsString:@"i.ytimg.com"]?image:[self makeSquare:image];
        });
    });
    
}

@end
