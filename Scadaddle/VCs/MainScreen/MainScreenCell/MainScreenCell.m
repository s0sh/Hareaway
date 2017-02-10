//
//  MainScreenCell.m
//  Scadaddle
//
//  Created by developer on 17/04/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "MainScreenCell.h"
#import "ABStoreManager.h"
#import "emsScadaddleActivityIndicator.h"
@interface MainScreenCell (){
   
    
}
@property (nonatomic, strong) emsScadaddleActivityIndicator *activityIndicatorView;
@end

@implementation MainScreenCell
@synthesize activityIndicatorView = _activityIndicatorView;
- (void)awakeFromNib {

        self.notificationImage.layer.cornerRadius = 2;
        self.notificationImage.layer.masksToBounds = YES;
        [self cornerIm:self.currentUserStatus];
}



-(BOOL)imageSatusHandler:(NSString*)path
{
    
    UIImage *image = [[[ABStoreManager sharedManager] imageCache] objectForKey:path];
    if(image)
    {
        
        self.currentUserStatus.image = image;
        
        return YES;
    }
    
   // self.currentUserStatus.image = [UIImage imageNamed:@"placeholder"];
    
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
            self.notificationImage.image = image;
            
            return YES;
        }

   // self.notificationImage.image = [UIImage imageNamed:@"placeholder"];
    
    return NO;
}
-(void)configureCellItemsWithData:(NSDictionary*)data
{
    
    if (data[@"userImg"] && ![data[@"userImg"] isEqualToString:@""]) {
        
  
        
        if(![self imageHandler:data[@"userImg"]])
        {
           // [self addIndicators];
            [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,data[@"userImg"]]
                   andIndicator:nil addToImageView:self.notificationImage andImageName:data[@"userImg"]];
        }
    }
    
    
     if (data[@"primaryInterestsImg"] && ![data[@"primaryInterestsImg"] isEqualToString:@""]) {
    
        if(![self imageSatusHandler:data[@"primaryInterestsImg"]])
        {
           // [self addIndicators];
            [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,data[@"primaryInterestsImg"]]
                   andIndicator:nil addToImageView:self.currentUserStatus andImageName:data[@"primaryInterestsImg"]];
        }
        
     }
    
    self.descriptionLbl.text = [data objectForKey:@"interestsStr"];
    self.distanceLbl.text = [data objectForKey:@"Distance"];
    self.nameTitle.text  = [[data objectForKey:@"name"] uppercaseString];
//    self.interestName.text = data[@"name"];
//    self.interestID = [[NSString stringWithFormat:@"%@", data[@"id"]] intValue];
}

- (void)active
{
    if (self.activityIndicatorView.isAnimating) {
        [self.activityIndicatorView stopAnimating];
    } else {
        
        [self.activityIndicatorView startAnimating];
    }
    
}

/*!
 * @discussion to download image by path and set image to appropriate image view
 * @param coverUrl absolute path to image
 * @param targetView set image here after download is complete
 * @param imageName we use it as a unique key to save image in cache
 */
-(void)downloadImage:(NSString *)coverUrl andIndicator:( emsScadaddleActivityIndicator *)indicator addToImageView:(UIImageView*)targetView andImageName:(NSString*)imageName{
    
   [self addScadaddleProgress];
    
    __block UIImage *image = [UIImage new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:coverUrl]];
        image  = [UIImage imageWithData:imageData];
        dispatch_sync(dispatch_get_main_queue(), ^{
           
            if (image == nil) {
                targetView.image = [UIImage imageNamed:@"placeholder"];
                [self.activityIndicatorView stopAnimating];
                [self.activityIndicatorView removeFromSuperview];
            }else{
                targetView.image = image;
                if(image)
                [[[ABStoreManager sharedManager] imageCache] setObject:image forKey:imageName];
                [self.activityIndicatorView stopAnimating];
            }
        });
    });
    
    
}


- (void)layoutSubviews
{
    self.grayline.frame = CGRectMake(self.grayline.frame.origin.x, self.grayline.frame.origin.y, self.grayline.frame.size.width, self.frame.size.height);
  
   
}




-(void)cornerIm:(UIImageView*)imageView{
    imageView .layer.cornerRadius = imageView.frame.size.height/2;
    imageView.layer.masksToBounds = YES;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}




-(void)addScadaddleProgress{
    
    [self addSubview: self.activityIndicatorView];
    
    self.activityIndicatorView.center = self.notificationImage.center;
    
    [self.activityIndicatorView startAnimating];
}

- (emsScadaddleActivityIndicator *)activityIndicatorView
{
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[emsScadaddleActivityIndicator alloc] initWithActivityIndicatorStyle:FishActivityIndicatorViewStyleNormal];
        _activityIndicatorView.hidesWhenStopped = YES;

        
    }
    return _activityIndicatorView;
}


@end
