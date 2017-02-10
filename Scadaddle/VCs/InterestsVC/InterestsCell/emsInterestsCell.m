//
//  emsInterestsCell.m
//  Scadaddle
//
//  Created by developer on 01/04/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsInterestsCell.h"
#import "ABStoreManager.h"


@implementation emsInterestsCell
@synthesize cellIndexPath;
-(void)addIndicators{
    interestsIndicator = [[UIActivityIndicatorView alloc] init];
    interestsIndicator.center = self.avatarImage.center;
    interestsIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [interestsIndicator startAnimating];
    [self addSubview:interestsIndicator];
}

- (void)awakeFromNib {
   
    self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.height/2;
    self.avatarImage.layer.masksToBounds = YES;
    self.facebookID = [[NSString alloc] init];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}
-(void)setBtnSelected{

    if ([self.selectBtn.imageView.image isEqual:[UIImage imageNamed:@"chek_interests"]]) {
        
        [self.selectBtn setImage:[UIImage imageNamed:@"non_chek_interests"] forState:UIControlStateNormal];
        isChecked = NO;
    }else if ([self.selectBtn.imageView.image isEqual:[UIImage imageNamed:@"non_chek_interests"]]) {
        [self.selectBtn setImage:[UIImage imageNamed:@"chek_interests"] forState:UIControlStateNormal];
        isChecked = YES;
    
    }
    

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
        self.avatarImage.image = image;
        return YES;
    }
    return NO;
}
-(void)configureCellItemsWithData:(NSDictionary*)data
{
    if(![self imageHandler:data[@"file"][@"filepath"]])
    {
         [self addIndicators];
         [self downloadImage:[NSString stringWithFormat:@"%@",data[@"file"][@"filepath"]]
           andIndicator:interestsIndicator addToImageView:self.avatarImage andImageName:data[@"file"][@"filepath"]];
    }
    
    
   self.interestName.text = data[@"name"];
   self.interestID = [[NSString stringWithFormat:@"%@", data[@"id"]] intValue];
   
    
}
/*!
 * @discussion to download image by path and set image to appropriate image view
 * @param coverUrl absolute path to image
 * @param targetView set image here after download is complete
 * @param imageName we use it as a unique key to save image in cache
 */
-(void)downloadImage:(NSString *)coverUrl andIndicator:(UIActivityIndicatorView*)indicator addToImageView:(UIImageView*)targetView andImageName:(NSString*)imageName{
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
                if(image)
                {
                   [[[ABStoreManager sharedManager] imageCache] setObject:image forKey:imageName];   
                }
            }
           // [indicator stopAnimating];
        });
    });
    
    
}
-(BOOL)isInterestChecked
{

    return isChecked;
    
}
@end
