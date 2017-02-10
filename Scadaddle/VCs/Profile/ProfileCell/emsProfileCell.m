//
//  emsProfileCell.m
//  Scadaddle
//
//  Created by developer on 06/04/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsProfileCell.h"
#import "ABStoreManager.h"


@implementation emsProfileCell

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
        self.cellInterestView.image = image;
        
        return YES;
    }
    
    self.cellInterestView.image = [UIImage imageNamed:@"placeholder"];
    
    return NO;
}
/*!
 * @discussion to download image by path and set image to appropriate image view
 * @param coverUrl absolute path to image
 * @param targetView set image here after download is complete
 * @param imageName we use it as a unique key to save image in cache
 */
-(void)downloadImage:(NSString *)coverUrl andIndicator:(UIActivityIndicatorView*)indicator addToImageView:(UIImageView*)targetView andImageName:(NSString*)imageName{
 __block  UIImage *image = [UIImage new];
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:coverUrl]];
        image  = [UIImage imageWithData:imageData];
           dispatch_sync(dispatch_get_main_queue(), ^{
               [indicator stopAnimating];
               if (image == nil) {
                   targetView.image = [UIImage imageNamed:@"placeholder"];
               }else{
                   
               targetView.image = image;
                   
                   if(image){
                       [[[ABStoreManager sharedManager] imageCache] setObject:image forKey:imageName];
                   }
               }
    
           });
      });
}

- (void)awakeFromNib {
  
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


-(void)configureCellItemsWithData:(NSString*)data
{
    
    if (data && ![data isEqualToString:@""]) {
        
        if(![self imageHandler:data])
        {
            [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,data]
                   andIndicator:nil addToImageView:self.cellInterestView andImageName:data];
        }
    }
}



@end
