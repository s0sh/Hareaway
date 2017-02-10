//
//  ActivityTableViewCell.m
//  Scadaddle
//
//  Created by Roman Bigun on 6/22/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "MemberTableViewCell.h"
#import "ABStoreManager.h"


@implementation MemberTableViewCell


@synthesize infoOrBecomeAMemberBtn;
- (void)awakeFromNib {
    self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.height/2;
    self.avatarImage.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
/*!
 * @discussion  Check if the image by path has already stored in
 * the cache
 * @param path absolute path
 */
-(BOOL)imageHandler:(NSString*)path
{
    
    UIImage *image = [[[ABStoreManager sharedManager] imageCache] objectForKey:path];
    if(image)
    {
        self.avatarImage.image = image;
        self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.height/2;
        self.avatarImage.layer.masksToBounds = YES;
        return YES;
    }
    return NO;
}
/*!
 * @delegate methods
 */
-(IBAction)goToProfile
{
    id<CellControllerDelegate> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(cellController:didPressButton:userId:)]) {
        [strongDelegate cellController:self didPressButton:@"profile" userId:[NSString stringWithFormat:@"%d",self.aId]];
    }
    

}
/*!
 * @see header for description
 */
-(IBAction)declineUser
{
    id<CellControllerDelegate> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(cellController:didPressButton:userId:)]) {
        [strongDelegate cellController:self didPressButton:@"decline" userId:[NSString stringWithFormat:@"%d",self.aId]];
    }
    
    
}
/*!
 * @see header for description
 */
-(IBAction)acceptUser
{
    
    
    [self.infoOrBecomeAMemberBtn setImage:[UIImage imageNamed:@"info_icon_activitydetail"] forState:UIControlStateNormal];
    [self.infoOrBecomeAMemberBtn addTarget:self action:@selector(goToProfile) forControlEvents:UIControlEventTouchUpInside];
    
    [self.acceptBtn setImage:[UIImage imageNamed:@"close_icon_activitydetail"] forState:UIControlStateNormal];
    [self.acceptBtn addTarget:self action:@selector(declineUser) forControlEvents:UIControlEventTouchUpInside];
    self.declineBtn.alpha = 0;
    
    id<CellControllerDelegate> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(cellController:didPressButton:userId:)]) {
        [strongDelegate cellController:self didPressButton:@"accept" userId:[NSString stringWithFormat:@"%d",self.aId]];
    }
    
    
}
/*!
 * @see header for description
 */
-(IBAction)becomeMember
{
    id<CellControllerDelegate> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(cellController:didPressButton:userId:)]) {
        [strongDelegate cellController:self didPressButton:@"becomemember" userId:[NSString stringWithFormat:@"%d",self.aId]];
    }
    
}
/*!
 * @see header for description
 */
-(void)configureCellIfUserIsOwner:(NSDictionary*)data
{

    if(![self imageHandler:data[@"userImg"]])
    {
        UIActivityIndicatorView *interestsIndicator = [[UIActivityIndicatorView alloc] init];
        interestsIndicator.center = self.avatarImage.center;
        interestsIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [interestsIndicator startAnimating];
        [self.avatarImage addSubview:interestsIndicator];
        
        [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,data[@"userImg"]]
               andIndicator:interestsIndicator addToImageView:self.avatarImage andImageName:data[@"userImg"]];
    }
    
    
    self.nameLbl.text = data[@"name"];
    self.aId = [[NSString stringWithFormat:@"%@", data[@"uId"]] intValue];
    
    [self.infoOrBecomeAMemberBtn setImage:[UIImage imageNamed:@"info_icon_activitydetail"] forState:UIControlStateNormal];
    [self.infoOrBecomeAMemberBtn addTarget:self action:@selector(goToProfile) forControlEvents:UIControlEventTouchUpInside];
    self.acceptBtn.alpha=1;
    [self.acceptBtn setImage:[UIImage imageNamed:@"close_icon_activitydetail"] forState:UIControlStateNormal];
    [self.acceptBtn removeTarget:self action:@selector(goToProfile) forControlEvents:UIControlEventTouchUpInside];
    [self.acceptBtn addTarget:self action:@selector(declineUser) forControlEvents:UIControlEventTouchUpInside];
    self.declineBtn.alpha=0;

}
/*!
 * @see header for description
 */
-(void)configureCellItemsWithData:(NSDictionary*)data
{
    
        if(![self imageHandler:data[@"userImg"]])
        {
            UIActivityIndicatorView *interestsIndicator = [[UIActivityIndicatorView alloc] init];
            interestsIndicator.center = self.avatarImage.center;
            interestsIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
            [interestsIndicator startAnimating];
            [self.avatarImage addSubview:interestsIndicator];
            
            [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,data[@"userImg"]]
                   andIndicator:interestsIndicator addToImageView:self.avatarImage andImageName:data[@"userImg"]];
        }
                
   
    self.nameLbl.text = data[@"name"];
    self.aId = [[NSString stringWithFormat:@"%@", data[@"uId"]] intValue];
   
    
        if([[NSString stringWithFormat:@"%@", data[@"uId"]] isEqualToString:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"myid"]]])
        {
        
            [self.infoOrBecomeAMemberBtn setImage:[UIImage imageNamed:@"close_icon_activitydetail"] forState:UIControlStateNormal];
            [self.infoOrBecomeAMemberBtn removeTarget:self action:@selector(goToProfile) forControlEvents:UIControlEventTouchUpInside];
            [self.infoOrBecomeAMemberBtn addTarget:self action:@selector(forgetActivity) forControlEvents:UIControlEventTouchUpInside];

            self.acceptBtn.alpha=0;
            self.declineBtn.alpha=0;
        
        }
        else
        {
            [self.infoOrBecomeAMemberBtn setImage:[UIImage imageNamed:@"info_icon_activitydetail"] forState:UIControlStateNormal];
            [self.infoOrBecomeAMemberBtn addTarget:self action:@selector(goToProfile) forControlEvents:UIControlEventTouchUpInside];
            self.acceptBtn.alpha=0;
            self.declineBtn.alpha=0;
        }
    
   
    
}
/*!
 * @see header for description
 */
-(IBAction)forgetActivity
{
    
    id<CellControllerDelegate> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(cellController:didPressButton:userId:)]) {
        [strongDelegate cellController:self didPressButton:@"forget" userId:[NSString stringWithFormat:@"%d",self.aId]];
    }
    

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
                    [[[ABStoreManager sharedManager] imageCache] setObject:image forKey:imageName];//Store to cache
                }
                
            }
          

        });
    });
    
    
}
@end
