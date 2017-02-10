//
//  emsInterestsCell.h
//  Scadaddle
//
//  Created by developer on 01/04/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CellInterestType)
{
    kITOwnInterest = 0,
    kITFacebook,
    kITShared,
    kITPreloaded
   
};
@interface emsInterestsCell : UITableViewCell
{

    UIActivityIndicatorView * interestsIndicator;
    BOOL isChecked;
    BOOL isFacebook;
    
   
}
@property int interestID;
@property(nonatomic,retain)NSString *facebookID;
@property(nonatomic,retain)NSIndexPath *cellIndexPath;
@property (weak,nonatomic)IBOutlet UILabel* interestName;
@property (strong,nonatomic)IBOutlet UIButton *selectBtn;
@property (weak,nonatomic)IBOutlet UIImageView *avatarImage;
@property (strong,nonatomic)IBOutlet UIButton *showMoreBtn;
@property (weak,nonatomic)IBOutlet UIImageView *selectedImage;
/*!
 @discussion Configure cell according to incoming data
 @param 'data' interest information
 **/
-(void)configureCellItemsWithData:(NSDictionary*)data;
/*!
 @discussion Selects Current btn
 **/
-(void)setBtnSelected;
/*!
 @discussion Check whether it has already checked or not
 @return bool value according to its state
 **/
-(BOOL)isInterestChecked;
@end
