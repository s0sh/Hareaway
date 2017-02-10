//
//  GPlusHelper.h
//  Scadaddle
//
//  Created by Roman Bigun on 4/8/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>
#import <QuartzCore/QuartzCore.h>

@protocol gpLoginViewControllerDelegate;

@class GPPSignInButton;

static NSString * const kClientID =
@"2941382890-95uclk7q9quk58rm1vq13pav4omb049f.apps.googleusercontent.com";
static NSString * const kGooglePlusClientSecret = @"thbjD7KziSSDgB4jQ-KjUFEH";
@interface GPlusHelper : NSObject<GPPSignInDelegate,GPPShareDelegate>
{

    NSString *OAuthToken;
    NSNumber *expireDate;
    NSString *idToken;
    NSString *refreshToken;
    NSString *tokenType;
    NSString *serviceProvider;
    NSString *userID;
    NSString *userEmail;
    NSString *userImage;
    NSString *userName;
    NSMutableArray *activityArray;

}
@property(strong, nonatomic)GPPSignInButton *signInButton;
@property(strong, nonatomic)GPPSignIn *signIn;
@property(nonatomic,weak) id<gpLoginViewControllerDelegate> delegate;

/*!
 * @discussion global initialisation
 */
-(id)init;
/*!
 * @discussion login to network
 */
-(id)login;
/*!
 * @discussion login
 */
-(void)googlePlusLogin;
/*!
 * @discussion logout
 */
-(void)googlePlusLogout;
/*!
 * @discussion check whether the user signed in or not
 */
-(BOOL)checkUserSighedIn;
/*!
 * @return OAUth token gotten after login
 */
-(NSString*)GPlusOAuthToken;
/*!
 * @discussion get user information from the network
 */
-(void)refreshUserInfo;
/*!
 * @discussion share item with G+
 * @param 'image' image to share
 * @param 'activityTitle' title text for shared image
 */
-(void)shareActivityImage:(UIImage*)image andText:(NSString*)activityTitle;
-(void)GooglePlusButton:(UIViewController*)viewController;
@end

@protocol gpLoginViewControllerDelegate <NSObject>
-(void)loginSuccessWithToken:(NSString*)token timeExpire:(NSString*)expires userID:(NSString*)userID userName:(NSString *)userName imageURL:(NSString *)imageURL;
-(void)loginCancel;
@end

