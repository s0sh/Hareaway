//
//  FriendsTableViewCell.m
//  Scadaddle
//
//  Created by Roman Bigun on 6/15/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "FriendsTableViewCell.h"
#import "ABStoreManager.h"

@implementation FriendsTableViewCell
{

    UIActivityIndicatorView *bgIndicator;
    BOOL isSelected;
    NSString *userId;
}
- (void)awakeFromNib {
    
    isSelected = NO;//Has not selected yet
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
/*!
 @discussion Check button pressed
 */
-(IBAction)selectButton
{
    id<CellControllerDelegate> strongDelegate = self.delegate;
    
    if(!isSelected)
    {
        
        
        if ([strongDelegate respondsToSelector:@selector(cellController:didPressButton:userId:)]) {
            [strongDelegate cellController:self didPressButton:@"check" userId:userId];
        }
        [self.selectBtn setImage:[UIImage imageNamed:@"check_btn"] forState:UIControlStateNormal];
        isSelected = YES;
        [[ABStoreManager sharedManager] addFriendToActivity:userId];
        
    }
    else
    {
        [self.selectBtn setImage:[UIImage imageNamed:@"add_friend_icon"] forState:UIControlStateNormal];
        if ([strongDelegate respondsToSelector:@selector(cellController:didPressButton:userId:)]) {
            [strongDelegate cellController:self didPressButton:@"uncheck" userId:userId];
        }

        isSelected = NO;
        [[ABStoreManager sharedManager] removeFriendFromActivity:userId];
    }
    
}
-(void)bgIndicators{
    
    bgIndicator = [[UIActivityIndicatorView alloc] init];
    bgIndicator.center = self.avatar.center;
    bgIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [bgIndicator startAnimating];
    [self.avatar addSubview:bgIndicator];
    
}
/*!
 @discussion Configure cell with data
 @param 'data' incoming data for the cell
 */
-(void)configureCellItemsUsingData:(NSDictionary*)data
{

    if(![self imageHandler:data[@"img"] andImageView:self.avatar])
    {
        [self bgIndicators];
        [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,data[@"img"]] andIndicator:bgIndicator addToImageView:self.avatar andName:data[@"img"]];
    }
    self.name.text = data[@"name"];
    userId = [NSString stringWithFormat:@"%@",data[@"id"]];
    

}
-(void)cornerIm:(UIImageView*)imageView{
    imageView .layer.cornerRadius = imageView.frame.size.height/2;
    imageView.layer.masksToBounds = YES;
}
/*!
 * @discussion  check whether image with path @param path cached or not.
 * If cached. add image to target else returns NO to start download
 * @param imageView image view to add retrieved from cache image
 * @param path path to image
 */
-(BOOL)imageHandler:(NSString*)path andImageView:(UIImageView*)imageView
{
    
    UIImage *image = [[[ABStoreManager sharedManager] imageCache] objectForKey:path];
    if(image)
    {
        imageView.image = image;
        [self cornerIm:imageView];
        return YES;
    }
    return NO;
}
/*!
 * @discussion to download image by path and set image to appropriate image view
 * @param coverUrl absolute path to image
 * @param targetView set image here after download is complete
 * @param imageName we use it as a unique key to save image in cache
 */
-(void)downloadImage:(NSString *)coverUrl andIndicator:(UIActivityIndicatorView*)indicator addToImageView:(UIImageView*)targetView andName:(NSString*)imageName{
    __block UIImage *image = [UIImage new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:coverUrl]];
        image  = [UIImage imageWithData:imageData];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [indicator stopAnimating];
            targetView.image = image;
            [self cornerIm:targetView];
            if(image)
              [[[ABStoreManager sharedManager] imageCache] setObject:image forKey:imageName];
            //[indicator stopAnimating];
        });
    });
    
    
}
@end
