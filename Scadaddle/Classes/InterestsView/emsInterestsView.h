//
//  emsInterestsView.h
//  Scadaddle
//
//  Created by developer on 06/04/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class User;
@interface emsInterestsView : UIView{
    
    void (^resultBlock)(BOOL bl);
    void (^cellBackBlock)(BOOL bl);
    void (^userBlock)(User *user);
    UIImageView *avatarImage;
    UILabel *nameLabel;
    UILabel *inrerestsLabelLabel;
    UITextField *mainTF;
    UIButton *checkBtn;
    NSInteger errorCount;
    User *currentUser;
    UIImageView *interestImage;
    
    NSString *interestURL;
    UIImageView *cellBtnImage;
}


/*!
 *  @discussion  Method sets view  this users
 *  @param :user as User should be passed
 *  @see :MainScreenVC
 */

- (id)initWithWord:(NSString *)initWord andUser:(User *)user andImage:(UIImage *)image andUrl:(NSString *)url result:(void (^)(BOOL bl))blo cellBlock:(void (^)(BOOL bl))cellBlock userBlock:(void (^)(User *user))userBlo;
/*!
 *  @discussion  Method sets view  this users
 *  @param :user as User should be passed
 *  @see :ProfileVC
 */
- (id)initWithWord:(NSString *)initWord result:(void (^)(BOOL bl))blo ;
@end
