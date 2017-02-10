//
//  MainScreenCell.h
//  Scadaddle
//
//  Created by developer on 17/04/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  Essence ;

@interface MainScreenCell : UITableViewCell{
    
    UIActivityIndicatorView * interestsIndicator;
    BOOL isChecked;


}
@property (weak,nonatomic)IBOutlet UIButton *showMoreBtn;
@property (nonatomic)IBOutlet UIScrollView *sc;
@property (weak,nonatomic)IBOutlet UIView *usersView;

@property (weak,nonatomic)IBOutlet UIButton *openScroll;
@property (weak,nonatomic)IBOutlet UIImageView *notificationImage;



@property (weak,nonatomic)IBOutlet UILabel *nameTitle;
@property (weak,nonatomic)IBOutlet UILabel *descriptionLbl;
@property (weak,nonatomic)IBOutlet UIImageView *currentUserStatus;
@property (weak,nonatomic)IBOutlet UILabel *distanceLbl;
@property (weak,nonatomic)IBOutlet UIButton *likeBtn;
@property (weak,nonatomic)IBOutlet UIButton *deleteBtn;

@property (weak,nonatomic)IBOutlet UIButton *iceBtn;
@property (weak,nonatomic)IBOutlet UIButton *infoBtn;
@property (weak,nonatomic)IBOutlet UIImageView *grayline;
@property (weak,nonatomic)IBOutlet UIImageView *whiteImage;
@property (weak,nonatomic)IBOutlet UIImageView *grayBackground;
@property (nonatomic,weak)IBOutlet UIImageView *noCrossInterests;
@property (nonatomic,weak)IBOutlet UIImageView *grayLine;
@property  BOOL isShow;
-(void)sfowScroll;
-(void)chengeFrame:(BOOL)cheng;
-(void)configureCellItemsWithData:(NSDictionary*)data;
@end
