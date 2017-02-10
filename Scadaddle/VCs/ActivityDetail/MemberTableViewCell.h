//
//  ActivityTableViewCell.h
//  Scadaddle
//
//  Created by Roman Bigun on 6/22/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CellControllerDelegate;

typedef NS_ENUM(NSInteger, activityType)
{
    
    follower,
    accepted,
    member,//Owner accepted membership user request
    block,
    hidden,
    noStatus,
    requestFromUserToBecomeMember,//Membership request
    requestToUserToBecomeMember//Be my member
    
};


@interface MemberTableViewCell : UITableViewCell
@property(nonatomic,retain)IBOutlet UIImageView *avatarImage;
@property(nonatomic,retain)IBOutlet UILabel *nameLbl;
@property(nonatomic,retain)IBOutlet UIButton *declineBtn;
@property(nonatomic,retain)IBOutlet UIButton *acceptBtn;
@property(nonatomic,retain)IBOutlet UIButton *infoOrBecomeAMemberBtn;

@property (nonatomic, weak) id<CellControllerDelegate> delegate;

@property int aId;
/*!
 * @discussion  Configure cell if user is not owner for current activity
 * @param data cell data
 */
-(void)configureCellItemsWithData:(NSDictionary*)data;
/*!
 @discussion  Configure cell if user is owner for current activity
 * @param data cell data
 */
-(void)configureCellIfUserIsOwner:(NSDictionary*)data;
/*!
 @discussion  Become activity member
 */
-(IBAction)becomeMember;
/*!
 @discussion  go to user profile
 */
-(IBAction)goToProfile;
/*!
 @discussion  if user wanted to be a member of your activity you can use this method to decline his request
 */
-(IBAction)declineUser;
/*!
 @discussion  if user wanted to be a member of your activity you can use this method to accept his request
 */
-(IBAction)acceptUser;
/*!
 @discussion  removes activity[not yours]. You wont see it ever more
 */
-(IBAction)forgetActivity;
@end

@protocol CellControllerDelegate <NSObject>

- (void)cellController:(UITableViewCell*)cellController
        didPressButton:(NSString*)value userId:(NSString*)userId;

@end