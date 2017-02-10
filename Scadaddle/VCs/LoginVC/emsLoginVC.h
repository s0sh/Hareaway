//
//  emsLoginVC.h
//  Scadaddle
//
//  Created by developer on 30/03/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <FacebookSDK/FBAccessTokenData.h>
#import <Accounts/ACAccountStore.h>
@interface emsLoginVC : UIViewController<FBLoginViewDelegate>

@property(nonatomic,weak)IBOutlet UIView *shirma;
@end
