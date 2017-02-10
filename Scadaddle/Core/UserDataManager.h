//
//  UserDataManager.h
//  Scadaddle
//
//  Created by Roman Bigun on 5/19/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>

//Server stuff
#define kUDKServerToken @"server_token"
#define kUDKFacebookToken @"facebook_token"
#define kUDKFacebookUID @"facebook_user_id"
#define kUDKServerUserInfo @"user_info"
#define kUDKLocalUserInfo @"local_user_info"
#define kUDKUserInfoInterests @"userInterests"
#define kUDKUserInfoActivityInterests @"activityInterests"
#define kUDKUserInterestsServerField @"user_interests"
#define kServerApiToken @"restToken"
#define kUDKIterestIsPublic @"public"
#define kUDKIActivityLocation @"location"
//User info stuff
#define kUDKUserInfoName @"name"
#define kUDKUserInfoAge @"birthday"
#define kUDKUserInfoAbout @"aboutMe"
#define kUDKUserInfoAvatarFile @"file"

@interface UserDataManager : NSObject

+(UserDataManager*)sharedManager;
/*!
 * @discussion to store facebook token into the bundle
 * @param fbToken token that has been returned after login
 */
-(void)saveFacebookToken:(NSString*)fbToken;
/*!
 * @discussion to store facebook user id
 * @param fbUserId facebook user id
 */
-(void)saveFacebookUserId:(NSString*)fbUserId;
/*!
 * @discussion to store rest API token
 * @param restToken[generates by the server] token to store
 */
-(void)saveRestApiToken:(NSString*)restToken;
/*!
 * @discussion to store user profile
 * @param userInfo data collected during login/registration process
 */
-(void)saveUser:(NSDictionary*)userInfo;
/*!
 * @discussion to store some data
 * @param info actually includes only restToken
 */
-(void)saveAdditionalUserInfo:(NSDictionary*)info;
/*!
 * @discussion to get FB token
 * @return facebook token stored lately
 */
-(NSString*)getCurrentFacebookToken;
/*!
 * @discussion to get serverToken
 * @return serverToken stored into the app bundle
 */
-(NSString*)serverToken;
/*!
 * @discussion to retrive stored user profile data
 * @return stored user profile
 */
-(NSDictionary*)getSavedUser;
/*!
 * @discussion to retrive registration information of the logged in user
 * @return user profile info
 */
-(NSDictionary*)registrationInfo;
/*!
 * @discussion to add interests into the user profile
 * @param interests the list of interests that should be added
 */
-(void)addUserInterests:(NSArray*)interests;
/*!
 * @discussion to store user data to UserDefaults
 * @param info user data
 */
-(void)saveUserToDefaults:(NSDictionary*)info;
/*!
 * @discussion to get user data
 * @return user data
 */
-(NSDictionary*)localUserInfo;
/*!
 * @discussion to get user interests
 * @return stored user interests
 */
-(NSArray *)myInterests;
/*!
 * @discussion to get activity location
 * @return array consists of two objects 0 - latitude, 1 - longitude
 */
-(NSArray*)activityLocation;
/*!
 * @discussion to store user location
 * @param locations array consists of two objects 0 - latitude, 1 - longitude
 */
-(void)setLocation:(NSArray*)locations;
/*!
 * @discussion to add interests into the object
 * @param interests array of interests
 */
-(void)addActivityInterests:(NSArray*)interests;
/*!
 * @discussion to store token of the user device
 * which will be stored on the db so to use it 
 * later on for push notifications
 * @param deviceToken token of the device
 * @see AppDelegate
 */
-(void)saveDeviceToken:(NSString *)deviceToken;
/*!
 * @discussion to remove user totally from Scadaddle db and device
 */
-(void)removeUsersData;
@end
