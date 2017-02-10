//
//  CoreService.h
//  Fishy
//
//  Created by Roman Bigun on 1/6/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//
//   This class temporary NOT USED

#import <Foundation/Foundation.h>
#import "dbconstants.h"
#import "emsAPIHelper.h"
#import "DBHelper.h"
#import "../Crypto/MD5.h"
#import "../Categories/UIAlertView+showMessage.h"
#import "Reachability.h"
#import "Profile.h"
#import "Socials.h"
#import "SocialsManager.h"

#define DEBUG 1
#define Core [ObjectHandler sharedInstance]
#define USER_CREDENTIALS(login,password) [NSDictionary dictionaryWithObjectsAndKeys:login,@"login",[password MD5],@"password", nil]
#define Alert(message) [UIAlertView showAlertWithMessage:message]

#define kPostIDDictKey  @"postID"
#define kPostTextDictKey @"text"
#define kPostDateDictKey  @"time"
#define kPostLikesCountDictKey  @"likesCount"
#define kPostCommentsCountDictKey  @"commentsCount"
#define kPostLikesIsLikableDictKey  @"likable"
#define kPostAuthorDictKey  @"author"
#define kPostAuthorAvaURLDictKey  @"avatarRemoteURL"
#define kPostAuthorNameDictKey  @"name"
#define kPostAuthorScreenNameDictKey @"screenName"
#define kPostAuthorIDDictKey @"userID"
#define kPostAuthorProfileURLDictKey  @"profileURL"
#define kPostCommentsDictKey  @"comments"
#define kPostCommentDateDictKey @"commentDate"
#define kPostCommentTextDictKey @"commentText"
#define kPostCommentIDDictKey @"commentID"
#define kPostCommentLikesCountDictKey @"commentLikes"
#define kPostCommentAuthorDictKey @"commentAuthor"
#define kPostCommentAuthorAvaURLDictKey @"commentAuthorAva"
#define kPostCommentAuthorNameDictKey @"commentAuthorName"
#define kPostCommentAuthorIDDictKey @"commentAuthorID"
#define kPostMediaSetDictKey @"media"
#define kPostMediaURLDictKey @"mediaURL"
#define kPostMediaTypeDictKey @"mediaType"
#define kPostMediaPreviewDictKey @"previewURLString"
#define kPostLinkOnWebKey @"linkURLString"
#define kPostTagsListKey @"tags"
#define kPostPlacesListKey @"places"
#define kPostIsCommentableDictKey @"postIsCommentable"
#define kGroupTypeKey @"groupeType"
#define kGroupIDKey @"groupeID"
#define kGroupNameKey @"groupeName"
#define kGroupImageURLKey @"groupeImageURL"
#define kGroupURLKey @"groupeURL"
#define kGroupIsManagedByMeKey @"isManagedByMe"
#define kPostType @"type"
#define kPostIsSearched @"isSearchedPost"
#define kFriendID @"friendID"
#define kFriendLink @"friendLink"
#define kFriendName @"friendName"
#define kFriendPicture @"friendPicture"
#define kPostGroupID @"postGroupID"
#define kPostGroupName @"postGroupName"
#define kPostGroupType @"postGroupType"
#define kPostUpdateKey @"updateKey"
#define kPostRetweetsCountDictKey @"retweetsCount"
#define kPlaceIdDictKey @"placeId"
#define kPlaceNetworkTypeDictKey @"networkType"
#define kPlaceLatitudeDictKey @"latitude"
#define kPlaceLongitudeDictKey @"longitude"
#define kPlaceAddressDictKey @"address"
#define kPlaceCheckinsCountDictKey @"checkinsCount"
#define kPlaceVerifiedDictKey @"verified"
#define kPlaceCountryCodeDictKey @"countryCode"
#define kPlaceNameDictKey @"name"
#define kPostUpdateDateDictKey @"updateTime"

@interface ObjectHandler : NSObject

+(ObjectHandler*)sharedInstance;
@property (strong, nonatomic) Reachability *reach;
@property (assign, nonatomic) BOOL isInternetConnected;
-(BOOL)login;
-(BOOL)loginWithCredentials:(NSDictionary*)creds;
-(BOOL)registerUserWithParams:(id)params;
-(void)downloadImageWithUrl:(NSURL*)url;
- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock;
-(NSArray*)getSocials;
-(void)addObject:(id)object;
-(void)addObjectToDB:(id)object;
-(NSDictionary*)userProfile;
-(NSDictionary*)getSocialForId:(int)objId;
-(NSDictionary *)profile:(NSString*)userId;
-(NSArray *)activities:(NSString *)userId;
-(NSArray *)events:(NSString *)userId;
-(NSArray *)notifications:(NSString *)userId;
-(NSDictionary *)dreamshot:(NSString *)userId;
-(NSArray *)interests:(NSString *)userId;
-(NSArray *)notebook:(NSString *)userId;
@end
