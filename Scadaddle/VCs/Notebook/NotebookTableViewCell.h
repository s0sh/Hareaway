//
//  NotebookTableViewCell.h
//  Notebook
//
//  Created by Roman Bigun on 5/18/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CellControllerDelegate;

typedef NS_ENUM(NSUInteger, FilterType)
{
    kFTFollowings = 0,
    kFTIcebreaker = 1,
    kFTFriends = 2,
    kFTBlockedUsers = 3,
    kFTAll = 55,
    kFTHiddenStatus = 4,//(Он скрыл тебя)
    kFTRefusedRequestStatus = 5,//(Он отказал на твой запрос дружбы)
    kFTFollowingStatus = 10,//(Ты профалловил его)
    kFTFriendshipRequestStatus = 11,//(Ты отправил запрос на дружбу )
    kFTFriendStatus = 22,//(Ты добавил его в друзья)
    kFTBlockedByMe = 33,//(Ты заблокировал его)
    kFTHiddenByMe = 44,//( Ты скрыл его )
    kFTRefuseRequestHim = 56//(Ты отказал на его запрос дружбы )
    
};

@interface NotebookTableViewCell : UITableViewCell
{

    UIActivityIndicatorView * interestsIndicator;
    UIActivityIndicatorView * bgIndicator;
    
    NSArray *actArray;
    NSIndexPath *myPath;
   int userID;

}
@property (nonatomic, weak) id<CellControllerDelegate> delegate;
@property(nonatomic,weak)IBOutlet UIImageView *interestView;
@property(nonatomic,weak)IBOutlet UIImageView *bgView;
@property(nonatomic,weak)IBOutlet UIImageView *userTypeView;//?
@property(nonatomic,weak)IBOutlet UIButton *btnRemoveUser;
@property(nonatomic,weak)IBOutlet UIButton *btnBlockUser;
@property(nonatomic,weak)IBOutlet UIButton *btnChatWithUser;
@property(nonatomic,weak)IBOutlet UIButton *btnUserInfo;
@property(nonatomic,weak)IBOutlet UILabel *userNameLbl;
@property(nonatomic,weak)IBOutlet UILabel *userNameBlocksLbl;
@property(nonatomic,weak)IBOutlet UILabel *userInterestsLbl;
- (IBAction)handleClickOptionButton:(id)sender;
-(void)configureCellItemsAccordingToType:(int)type usingData:(NSDictionary*)data;
-(NSString *)currentItemId;

@end


@protocol CellControllerDelegate <NSObject>

- (void)cellController:(UITableViewCell*)cellController
        didPressButton:(NSString*)value userId:(NSString*)userId;

@end
