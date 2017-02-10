//
//  PromotionViewController.h
//  Scadaddle
//
//  Created by Roman Bigun on 5/29/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "emsCheckButton.h"
#import <Accounts/Accounts.h>
#import "STTwitter.h"


@interface PromotionViewController : UIViewController<UITextFieldDelegate,UIGestureRecognizerDelegate>
{

    UIActivityIndicatorView *interestsIndicator;
    BOOL isTwitterChecked;
    BOOL isFacebookChecked;
    BOOL isInstaChecked;
    
}

@property(nonatomic,retain)IBOutlet UITextField *sharedLink;
@property(nonatomic,retain)IBOutlet UIButton *facebook;
@property(nonatomic,weak)IBOutlet UIView *pagePickerBG;
@property(nonatomic,weak)IBOutlet UIView *hideFBPage;
@property(nonatomic,weak)IBOutlet UIView *socialsDinamicView;
@property(nonatomic,retain)IBOutlet UIButton *twitterBtn;
@property(nonatomic,retain)IBOutlet UIButton *instaBtn;
@property(nonatomic,retain)IBOutlet UIImageView *fb_checked_bg;
@property(nonatomic,retain)IBOutlet UIImageView *tw_checked_bg;
@property(nonatomic,retain)IBOutlet UIImageView *in_checked_bg;
@property(nonatomic,retain)IBOutlet UIPickerView *pagesView;
- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verfier;
@end
