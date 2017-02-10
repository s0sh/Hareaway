//
//  SocialsManager.h
//  Scadaddle
//
//  Created by Roman Bigun on 3/30/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//
/*!
 @depricated Class
**/
#import <Foundation/Foundation.h>
#import "FBHelper.h"
#import "InstagHelper.h"
#import "GPlusHelper.h"
#import "TWHelper.h"
#import "Profile.h"
#import "YoutubeHelper.h"
#define kSocialTypeFacebook  0
#define kSocialTypeInstagram 1
#define kSocialTypeGoogle    2
#define kSocialTypeTwitter   3

@interface SocialsManager : NSObject
@property (retain) NSArray *socials;
-(void)initSocials;
-(Socials *)socialWithType:(int)type;
//Facebook GRAPH Client's functions
-(BOOL)facebookLoginInsertToView:(UIViewController*)target;
/*!
 * @return: facebook access token stored in the bundle after success login
 */
-(NSString *)fbAccessToken;
/*!
 * @return: facebook user avatar
 * @param 'pId' fb user id
 */
-(NSArray  *)fbUserImagesWithId:(NSString*)pId;
/*!
 * @return: facebook user interests
 * @param 'iId' fb user id
 */
-(NSArray  *)fbUserInterestWithID:(NSString*)iId;
/*!
 * @return: facebook albums
 */
-(NSArray  *)fbUserAlbums;
/*!
 * @return: facebook activities
 */
-(NSArray  *)fbUserActivities;
/*!
 * @return: facebook user interests
 */
-(NSArray  *)fbUserInterests;
/*!
 * @return: facebook notifications
 */
-(NSArray  *)fbUserNotifications;
/*!
 * @return: facebook friends
 */
-(NSArray  *)fbUserFriends;
/*!
 * @return: facebook user ID
 */
-(NSString *)fbLoggedInUserID;
/*!
 * @return: facebook user avatar
 * @param 'fbUserID' id of user you want to get avatar for
 */
-(NSString *)avatarUrlWithID:(NSString *)fbUserID;
/*!
 * @discussion Login to Instagram
 */
-(void)instagramLogin;
/*!
 * @discussion get user timeline
 */
-(NSArray *)instagramPosts;
/*!
 * @discussion Google Plus Login
 */
-(void)googlePlusLogin;
-(void)gPlusLogin;
-(void)googlePlusButton:(UIViewController *)vk;
//Twitter
-(void)twitterButton:(UIViewController *)vk;
//Youtube
-(void)youtubeVideoLinksForTerm:(NSString*)term;
//COMMON
-(NSDictionary*)getSocialWithType:(int)type;
@end
