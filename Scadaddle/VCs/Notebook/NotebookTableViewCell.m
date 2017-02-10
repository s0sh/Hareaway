//
//  NotebookTableViewCell.m
//  Notebook
//
//  Created by Roman Bigun on 5/18/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "NotebookTableViewCell.h"
#import "ABStoreManager.h"
#import "emsAPIHelper.h"

@implementation NotebookTableViewCell
{
    int currentUserType;
}



/*!
 * @discussion  loads background activity indicator
 */
-(void)bgIndicators{
    
    bgIndicator = [[UIActivityIndicatorView alloc] init];
    bgIndicator.center = self.bgView.center;
    bgIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [bgIndicator startAnimating];
    [self.bgView addSubview:bgIndicator];

}
/*!
 * @discussion  loads activity indicator to interests imageView during downloading image
 */
-(void)inaterestIndicators
{

    interestsIndicator = [[UIActivityIndicatorView alloc] init];
    interestsIndicator.center = self.interestView.center;
    [interestsIndicator startAnimating];
    [self.interestView addSubview:interestsIndicator];

}
- (void)awakeFromNib {
    self.interestView.layer.cornerRadius = self.interestView.frame.size.height/2;
    self.interestView.layer.masksToBounds = YES;
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
/*!
 * @discussion  Configure buttons according to status/type of the user
 * @param 'type' @see FilterType ENUM
 * Hide/Display
 * Add targets according to type
 */
-(void)setupButtonsAccordingToDataType:(int)type
{
    if(type==kFTAll || type==kFTFollowings || type==kFTFollowingStatus || type==kFTIcebreaker || type == kFTFriendshipRequestStatus){
        self.btnRemoveUser.alpha=1;
        [self.btnRemoveUser addTarget:self action:@selector(removeUser) forControlEvents:UIControlEventTouchUpInside];
        [self.btnUserInfo addTarget:self action:@selector(gotoUserProfile) forControlEvents:UIControlEventTouchUpInside];
        self.btnUserInfo.alpha=1;
        self.btnBlockUser.alpha=1;
        [self.btnBlockUser setImage:[UIImage imageNamed:@"follow_icon_activitydetail"] forState:UIControlStateNormal];
        if(type==kFTFollowingStatus)
        {
            [self.btnBlockUser setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
            [self.btnBlockUser addTarget:self action:@selector(iceBreaker) forControlEvents:UIControlEventTouchUpInside];
        }
        else if(!type==kFTIcebreaker)
        {
            
            [self.btnBlockUser addTarget:self action:@selector(addUser) forControlEvents:UIControlEventTouchUpInside];
        
        }
        if(type == kFTFriendshipRequestStatus)
        {
            self.btnBlockUser.alpha=1;
            self.btnUserInfo.alpha=1;
            self.btnRemoveUser.alpha=0;
            [self.btnBlockUser setImage:[UIImage imageNamed:@"info_icon_main"] forState:UIControlStateNormal];
            [self.btnBlockUser addTarget:self action:@selector(gotoUserProfile) forControlEvents:UIControlEventTouchUpInside];
            [self.btnUserInfo setImage:[UIImage imageNamed:@"close_icon_main"] forState:UIControlStateNormal];
            [self.btnUserInfo removeTarget:self action:@selector(gotoUserProfile) forControlEvents:UIControlEventTouchUpInside];
            [self.btnUserInfo addTarget:self action:@selector(removeUser) forControlEvents:UIControlEventTouchUpInside];
            
        }
        if(type==kFTIcebreaker)
        {
            [self.btnBlockUser addTarget:self action:@selector(addFriend) forControlEvents:UIControlEventTouchUpInside];
        }
        self.btnChatWithUser.alpha=0;
        self.userInterestsLbl.alpha=1;
        
        
    }
    if(type==kFTFriends || type == kFTFriendStatus){
        self.btnRemoveUser.alpha=1;
        self.btnUserInfo.alpha=1;
        self.btnBlockUser.alpha=1;
        [self.btnRemoveUser addTarget:self action:@selector(chat) forControlEvents:UIControlEventTouchUpInside];
        [self.btnRemoveUser setImage:[UIImage imageNamed:@"speach_bubble"] forState:UIControlStateNormal];
        [self.btnUserInfo addTarget:self action:@selector(gotoUserProfile) forControlEvents:UIControlEventTouchUpInside];
        [self.btnBlockUser addTarget:self action:@selector(blockUser) forControlEvents:UIControlEventTouchUpInside];
        [self.btnBlockUser setImage:[UIImage imageNamed:@"block"] forState:UIControlStateNormal];
        [self.btnChatWithUser addTarget:self action:@selector(removeFriend) forControlEvents:UIControlEventTouchUpInside];
        [self.btnChatWithUser setImage:[UIImage imageNamed:@"close_icon_main"] forState:UIControlStateNormal];
        self.btnChatWithUser.alpha=1;
        self.userInterestsLbl.alpha=1;
        self.userTypeView.image = [UIImage imageNamed:@"friends_icon_ice"];
    }
    if(type==kFTBlockedUsers || type == kFTBlockedByMe){
        self.btnRemoveUser.alpha=0;
        self.btnUserInfo.alpha=1;
        self.btnBlockUser.alpha=1;
        self.btnChatWithUser.alpha=0;
        self.userInterestsLbl.alpha=0;
        [self.btnBlockUser setImage:[UIImage imageNamed:@"info_icon_main"] forState:UIControlStateNormal];
        [self.btnBlockUser addTarget:self action:@selector(gotoUserProfile) forControlEvents:UIControlEventTouchUpInside];
        [self.btnUserInfo setImage:[UIImage imageNamed:@"close_icon_main"] forState:UIControlStateNormal];
        [self.btnUserInfo removeTarget:self action:@selector(gotoUserProfile) forControlEvents:UIControlEventTouchUpInside];
        [self.btnUserInfo addTarget:self action:@selector(unblockUser) forControlEvents:UIControlEventTouchUpInside];
        self.userTypeView.image = [UIImage imageNamed:@"block_icon_ice"];
        
    }
    if(type==kFTIcebreaker){
        self.userTypeView.image = [UIImage imageNamed:@"ice_breacker_icon_ice"];
    }
    if(type==kFTFollowings || type==kFTFollowingStatus || type == kFTFriendshipRequestStatus){
        self.userTypeView.image = [UIImage imageNamed:@"like_icon_ice"];
    }
    currentUserType = type;
}
/*!
 * @discussion  UIAlertView delegate method
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex==0)
    {
        if(alertView.tag==100/*Remove user*/)
        {
            id<CellControllerDelegate> strongDelegate = self.delegate;
            
            if ([strongDelegate respondsToSelector:@selector(cellController:didPressButton:userId:)]) {
                [strongDelegate cellController:self didPressButton:@"remove" userId:[NSString stringWithFormat:@"%d",userID]];
            }
        }
        else if(alertView.tag==101/*Remove user from friend*/)
        {
         
            id<CellControllerDelegate> strongDelegate = self.delegate;
            
            if ([strongDelegate respondsToSelector:@selector(cellController:didPressButton:userId:)]) {
                [strongDelegate cellController:self didPressButton:@"removeFromFriend" userId:[NSString stringWithFormat:@"%d",userID]];
            }
            
        }
        
        
    }
    else
    {
        
        return;
        
    }
    
}

-(void)removeUser
{
    
    UIAlertView *aView = [[UIAlertView alloc] initWithTitle:@"Remove User"
                                                    message:@"Are you sure you want to remove this user?"
                                                   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Cancel",nil, nil];
    aView.tag = 100;
    [aView show];
        
  
}
-(void)friendRM
{
    UIAlertView *aView = [[UIAlertView alloc] initWithTitle:@"Remove From Friends"
                                                    message:@"Are you sure you want to delete this user from friends?"
                                                   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Cancel",nil, nil];
    aView.tag = 101;
    [aView show];
    
}
-(void)removeFriend
{
    [self friendRM];
    
}
#pragma -
#pragma mark Delegate methods
/*!
 * @discussion  to go and chat with choosen friend
 */
-(void)chat
{
    id<CellControllerDelegate> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(cellController:didPressButton:userId:)]) {
        [strongDelegate cellController:self didPressButton:@"chat" userId:[NSString stringWithFormat:@"%d",userID]];
    }
    
}
/*!
 * @discussion  to unblock user if user was blocked by you
 */
-(void)unblockUser
{
    id<CellControllerDelegate> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(cellController:didPressButton:userId:)]) {
        [strongDelegate cellController:self didPressButton:@"unblock" userId:[NSString stringWithFormat:@"%d",userID]];
    }
    
}
/*!
 * @discussion  to see user profile [goes to emsProfileVC controller]
 */
-(void)gotoUserProfile
{
    id<CellControllerDelegate> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(cellController:didPressButton:userId:)]) {
        [strongDelegate cellController:self didPressButton:@"info" userId:[NSString stringWithFormat:@"%d",userID]];
    }
    
}
/*!
 * @discussion  to add user to a friend list after user sent ice breaker request to you
 */
-(void)addUser
{
    id<CellControllerDelegate> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(cellController:didPressButton:userId:)]) {
        [strongDelegate cellController:self didPressButton:@"addFriend" userId:[NSString stringWithFormat:@"%d",userID]];
    }
    
}
/*!
 * @discussion  to add user to a friend list after user sent ice breaker request to you
 */
-(void)addFriend
{
    id<CellControllerDelegate> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(cellController:didPressButton:userId:)]) {
        [strongDelegate cellController:self didPressButton:@"addFriend" userId:[NSString stringWithFormat:@"%d",userID]];
    }
    
}
/*!
 * @discussion  to send user iceBreaker request( ask user to add you to his frieds list )
 */
-(void)iceBreaker
{
    id<CellControllerDelegate> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(cellController:didPressButton:userId:)]) {
        [strongDelegate cellController:self didPressButton:@"iceBreaker" userId:[NSString stringWithFormat:@"%d",userID]];
    }
    
}
/*!
 * @discussion  to block friend[now you cannot have chat]
 */
-(void)blockUser
{
    id<CellControllerDelegate> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(cellController:didPressButton:userId:)]) {
        [strongDelegate cellController:self didPressButton:@"block" userId:[NSString stringWithFormat:@"%d",userID]];
    }
    
}
/*!
 * @discussion  check whether image with path @param path cached or not.
 * If cached. add image to target else returns NO to start download
 * @param imageView image view to add retrived from cache image
 * @param path path to image
 */
-(BOOL)imageHandler:(NSString*)path andImageView:(UIImageView*)imageView
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
 * @discussion to get id of current entity
 * @return id of current entity
 */
-(NSString *)currentItemId
{
    __strong NSString *aId = [[NSString alloc] initWithFormat:@"%i",userID];
    return aId;

}
/*!
* @discussion  Configure buttons according to status/type of the user
* @param 'type' needed for buttons
* @param 'data' income user data
* @see FilterType ENUM
 */
-(void)configureCellItemsAccordingToType:(int)type usingData:(NSDictionary*)data{
 
   
   
    [self setupButtonsAccordingToDataType:type];
    if(![self imageHandler:data[@"userImg"] andImageView:self.bgView])
    {
        
      [self bgIndicators];//loading main indicator
      [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,data[@"userImg"]] andIndicator:bgIndicator addToImageView:self.bgView andName:data[@"userImg"]];
    }
    if(![self imageHandler:data[@"userPrimaryInterestImg"] andImageView:self.interestView])
    {
       [self inaterestIndicators];//loading interest indicator
       [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,data[@"userPrimaryInterestImg"]] andIndicator:interestsIndicator addToImageView:self.interestView andName:data[@"userPrimaryInterestImg"]];
    }
   
    if(type==kFTBlockedUsers){
        self.userNameBlocksLbl.text =[data[@"name"] uppercaseString];
        self.userNameBlocksLbl.alpha=1;
        self.userNameLbl.alpha=0;
    }else{
        self.userNameLbl.text = [data[@"name"] uppercaseString];
        self.userNameBlocksLbl.alpha=0;
        self.userNameLbl.alpha=1;
    
    }
       self.userInterestsLbl.text = data[@"interestsStr"];
       userID = [[[NSString alloc ]initWithFormat:@"%@",data[@"uId"]] intValue];
       myPath = [[NSIndexPath alloc] init];
       myPath = data[@"indexPath"];
       
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
                 if (image == nil) {
                     
                     targetView.image = [UIImage imageNamed:@"placeholder"];
                     
                 }else{
                     targetView.image = image;
                     if(image)
                      [[[ABStoreManager sharedManager] imageCache] setObject:image forKey:imageName];
                 }
                //[indicator stopAnimating];
            });
 });
   

}
@end
