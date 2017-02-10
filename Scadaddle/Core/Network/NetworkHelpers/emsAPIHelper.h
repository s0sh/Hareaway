//
//  emsAPIHelper.h
//  Fishy
//
//  Created by Roman Bigun on 1/6/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "serverconstants.h"
#import "JSON.h"
#import "emsServerErrorHandler.h"
#import "Reachability.h"
#import <UIKit/UIKit.h>
//import "Flurry.h"
@class DBWorker;
@class Profiles;
#define Server [emsAPIHelper sharedInstance]
@interface emsAPIHelper : NSObject/*<FlurryDelegate>*/

@property (strong, nonatomic) Reachability *reach;
@property (assign, nonatomic) BOOL isInternetConnected;

+(emsAPIHelper*)sharedInstance;
/*! Login To Server **
 *  Should return `User data of registered user` object as a NSDictionary from server
 *  @param userId
 *  @param token ->facebookToken that has been recieved after facebook login
 *
 */
-(void)loginToServerWithFacebookToken:(NSString*)token
                            andUserID:(NSString*)userId;
/*! Registers User
 *  DB
 *  Should return `User data of registered user` object as a NSDictionary from server after registration (success)
 *  @note that this function is temporary not used since DB was removed from logic
 */
-(NSDictionary *)registerUserWithParams:(NSDictionary*)userData;
/*!
 *  User Register
 * @see UserDataManager class
 */
-(void)registerUser;
/*!
 *  Creates new interest
 * @see CreateInterestViewController class
 */
-(void)addInterestWithData:(NSDictionary *)data;
/*!
 *  Creates/Updates an Activity
 * @see ABStoreManager class
 * @see SHViewController
 */
-(void)saveActivity;
/*! profile
 *  Returns an `UserProfile` object as a NSDictionary
 *  @param userId 
 *  @note that inside this method there are 2 more params incapsulated (don't be concerned about them)
 *  @warning there is no Null check
 *  @TODO implement Null check
 */
-(NSDictionary *)profile:(NSString*)userId;
/*!
 *  Get activities from server as a list
 * @param userId ID of the user
 */
-(NSArray *)activities:(NSString*)userId;
/*!
 *  Get events from server as a list
 * @param userId ID of the user
 */
-(NSArray *)events:(NSString *)userId;
/*!
 *  Get notifications for user from server
 * @param userId ID of the user
 */
-(NSArray *)notifications:(NSString *)userId;
/*!
 *  Get dreanshot data from server
 * @param userId ID of the user
 */
-(NSDictionary *)dreamshot:(NSString *)userId;
/*!
 *  Get list of interests from server
 */
-(NSArray *)interests;
/*
 *  Get notebook data from server for user with
 * @param 'userId'
 */
-(NSArray *)notebook:(NSString *)userId;
/*
 *  Get Radar data
 * @param 'lat' Current user location: Latitude
 * @param 'lng' Current user location: Longitude
 * @param 'start' start from e.g '0'
 * @param 'limit' as a limit u use quantity of elements to recieve
 * @additional param 'gender'
 * @returns Array of Activities/Singles/Interests/Rewards...
 */
-(NSArray *)mainPage:(NSString *)lat
             andLong:(NSString*)lng
            andStart:(NSString *)start
            andLimit:(NSString *)limit;
/*
 *  Get Radar data
 * @param 'lat' Current user location: Latitude
 * @param 'lng' Current user location: Longitude
 * @param 'start' start from e.g '0'
 * @param 'limit' as a limit u use quantity of elements to recieve
 * @additional param 'gender'
 * @returns Array of Activities
 */
-(NSArray *)activities:(NSString *)lat
               andLong:(NSString*)lng
              andStart:(NSString *)start
              andLimit:(NSString *)limit ;
/*
 *  Get Radar data
 * @param 'lat' Current user location: Latitude
 * @param 'lng' Current user location: Longitude
 * @param 'start' start from e.g '0'
 * @param 'limit' as a limit u use quantity of elements to recieve
 * @additional param 'gender'
 * @returns Array of Interests
 */
-(NSArray *)interests:(NSString *)lat
              andLong:(NSString*)lng
            andGender:(NSString*)gender
             andStart:(NSString *)start
             andLimit:(NSString *)limit;
/*
 *  Get Radar data
 * @param 'lat' Current user location: Latitude
 * @param 'lng' Current user location: Longitude
 * @param 'start' start from e.g '0'
 * @param 'limit' as a limit u use quantity of elements to recieve
 * @additional param 'gender'
 * @returns Array of Rewards...
 */
-(NSArray *)rewards:(NSString *)lat
            andLong:(NSString*)lng
           andStart:(NSString *)start
           andLimit:(NSString *)limit;
/*
 *  Get cross interests for user with ID ->
 * @param 'userId'
 */
-(NSArray *)crossInterests:(NSString *)uId;

/*!*****************NOTEBOOK ACTIONS***************************
 *  Deletes user with ID ->
 * @param userId id of user
 * @see NotebookViewController
 */
-(void)deleteUser:(NSString*)userId
         callback:(void (^)())callback;
/*!
 *  Follow user with ID
 * @param userId id of user
 * @see NotebookViewController
 */
-(void)followUser:(NSString*)userId
         callback:(void (^)())callback;
/*!
 -  Get all notebook Entities
 @param data includes
     -target e.g @"/notebook/all"
     -limitFrom '0'
     -limitTo   '100'
  @see NotebookViewController
 */
-(NSDictionary *)notebookMainPage:(NSDictionary*)data;
/*!
 *  Actually request for friendship
 * @param uId to whom you'd like to send it
 * @see NotebookViewController
 */
-(void)icebreakerRequest:(NSString*)uId;
/*!
 *  Add user to friend
 *@discussion You can only add user as a friend after you recieves
 *icebreakerRequest
 *
 * @param uId ID of the user who sent icebreakerRequest to you
 * @param status 0/1. Use this function to add/remove the user
 * from friend list.
 * @see NotebookViewController
 */
-(void)addFriend:(NSString*)uId
          status:(int)status;
/*!*****************ACTIVITIES ACTIONS***************************/
/*!
 * Hide Activity [Non author]
 */
-(void)hideActivity:(NSString*)activityId
           callback:(void (^)())callback;
/*!
 *  Remove Activity [Author]
 */
-(void)removeActivity:(NSString*)activityId
             callback:(void (^)())callback;
/*!
 -  Follow Activity [Non author]
 */
-(void)followActivity:(NSString*)activityId
             callback:(void (^)())callback;
/*!
 * Set primary user interest
 */
-(void)setPrimaryInterest:(NSString*)interestId;
/*!
 *  Get User Friends (Scadaddle friends non FB friends)
 */
-(NSArray *)friends;
/*!
 *  Save user settings
 * @see SettingsViewController
 */
-(void)saveSettings;
/*!
 *  Get user settings
 * @see SettingsViewController
 */
-(NSDictionary *)getSettings;
/*!
 *  Updating user locations when it is changed (runtime process)
 */
-(void)updateLocations:(NSString *)lat lng:(NSString *)lng;
/*!
 *  Getting path for primary interest
 *  @used in PrimaryInterestImage class
 */
-(NSString *)primaryInterest;
// - Profile Methods
-(NSDictionary *)profileInfoandUserID:(NSString *)userID;
/*!
 *  Get data for Activity with ID ->
 * @param aId activity ID
 * @param lat Latitude
 * @param longitude
 * @see NotebookViewController
 */
-(NSDictionary *)activityDataForID:(NSString *)aId
                               lat:(NSString*)lat
                           andLong:(NSString*)lng;
-(void)removeUser;
/*!
 *  Actually request for friendship
 * @param userId to whom you'd like to send it
 * @see emsProfileVC
 */
-(void)friendshipRequest:(NSString*)uId
                callback:(void (^)())callback;
/*!
 *  Get activities Entities by type
 * @param type could be : myOwnActivity/followActivity/acceptedActivity
 * @param orderBy name/distance/date
 * @param direction asc/desc
 * @see emsActivityVC
 */
-(NSDictionary *)getActivitiesByType:(NSString*)type
                             orderBy:(NSString*)order
                        andDirection:(NSString*)direction;
/*!
 * Get my own profile
 */
-(NSDictionary *)profile;
/*!
 * Get cross interests for activity with ID
 * @param aId activity ID
 */
-(NSArray *)crossInterestsActivities:(NSString *)aId;
/*!
 * Friendship request to user with ID
 * @param uId user ID
 */
-(void)friendshipRequest:(NSString*)uId;
/*!
 * Get public interest
 * @param start e.g '0'
 * @param limit e.g '100'
 */
-(NSArray *)publicInterests:(NSString *)start
                   andLimit:(NSString *)limit;
/*!
 * Block friend with ID
 * @param 'userId'
 * @param 'block' 0/1 - block/unblock friend
 */
-(void)blockFriend:(NSString*)userId
              type:(BOOL)block
          callback:(void (^)())callback;
/*!
 - Search for interest by its name
 @param 'queryString' name of interest
 */
-(NSArray *)interestsSearchWithText:(NSString*)queryString;
/*!
 * Remove Activity With ID ->
 * @param 'aId' activity id to remove
 */
-(BOOL)removeActivity:(NSString*)aId;
/*!
 * Update activity after editing
 */
-(void)postUpdateActivities;
/*!
 * Get notifications list
 */
-(NSArray *)notifications;
/*!
 * Verify phone number [Sinch library is used]
 */
-(BOOL)phoneVerifyed:(NSString*)phoneNumber;
/*!
 * Updates profile data after editing
 * @param 'userData' changes in the profile which should be changed
 * on the database
 */
-(void )postProfileInfoandUserID:(NSDictionary *)userData
                        callback:(void (^)(NSDictionary *))callback;
/*!
 - Get chat history/data for user id ->
 * @param 'userId'
 */
-(void )getChat:(NSString *)userId
       callback:(void (^)(NSDictionary *))callback;
/*!
 * Registers device token for current user [Needs for Push
 * Notifications]
 * @param 'deviceToken'
 * @see AppDelegate class
 */
-(void)updateDeviceTokenForPushNotifications:(NSString*)deviceToken;
/*!
 - Unfollow activity with ID ->
 * @param 'aId'
 */
-(void)unfollowActivity:(NSString*)activityId
               callback:(void (^)())callback;
/*!
 - If somehow token, generated by the server is no more valid
 * refreshToken is used for regenerate one for existing user
 */
-(BOOL)refreshToken;
/*!
 - Request to become a member of activity with ID
 * @param 'aId' activity ID
 * @param 'uId' pass your own ID
 */
-(void)becomeAMember:(NSString*)aId
              andUID:(NSString*)uId
                type:(BOOL)block;
/*!
 - Allow user to be a member of activity with ID->
 * @param 'aId' activity ID
 * @param 'uId' pass userId to be a member
 * @param 'block' e.g 0/1
 * @note that u can use this method to allow/deny user
 */
-(void)acceptMember:(NSString*)aId
          andUserId:(NSString*)uId
               type:(BOOL)block
           callback:(void (^)())callback;
/*!
 - Removes notification which has been already seen by the user
 @param 'nId' ID to remove
 */
-(void)removeNotification:(NSString*)nId
                 callback:(void (^)())callback;


/*!
 - Checks is user online.If offline send Push Notification
 * @param 'uId' pass userId to be a member
 * @param 'block' e.g 0/1
 */
-(void)checkSendPush:(NSString *)userId
            callback:(void (^)(NSString *))callback;


/*!
 * Send image to server/DB
 * @param 'dictionary' image ditail dictionary
 * @param 'block' e.g 0/1
 */
-(void)sendImageToChat:(NSDictionary *)dictionary
              callback:(void (^)(NSString *))callback;

/*!
 - Send Push Notification from chat
 * @param 'uId' pass userId to be a member
 * @param 'block' e.g 0/1
 */
-(void)postPush:(NSString *)userId
     andMessage:(NSString *)message
     callback:(void (^)(NSString *))callback;
/*!
 - Get facebook pages from Facebook (if there is at least one of cource)
 */
-(NSArray*)facebookPages;
-(NSArray*)youtubeVideo:(int)maxResult;
-(void)searchActivities:(NSString*)type
                orderBy:(NSString*)order
                andDirection:(NSString*)direction
                andSearchString:(NSString *)searchString
                callback:(void (^)(NSDictionary *))callback;
/*!
 * Send to server/DB information about user status online/ofline
 */
-(void)postUserOnline:(BOOL)isOnline;
/*!
 * Unfollow user with ID->
 * @param 'userId' user to unfollow
 */
-(void)unfollowUser:(NSString*)userId callback:(void (^)())callback;

@end
