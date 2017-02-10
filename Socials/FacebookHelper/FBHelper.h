//
//  FBHelper.h
//  Scadaddle
//
//  Created by Roman Bigun on 4/7/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import <FacebookSDK/FBAccessTokenData.h>
#import <Accounts/ACAccountStore.h>

#import "ObjectHandler.h"
@protocol FBHelperDelegate;

@interface FBHelper : NSObject<FBLoginViewDelegate>
@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (strong, nonatomic) NSArray *userInterests;
@property (strong, nonatomic) NSArray *userActivities;
@property (strong, nonatomic) NSArray *userPhotos;
@property (strong, nonatomic) FBLoginView *loginView;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSDictionary *user;
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) FBSession *session;
@property(nonatomic,weak) id<FBHelperDelegate> delegate;

+(FBHelper*)sharedInstance;
-(void)fbLoginToServer;
-(BOOL)FBLogin:(UIViewController*)viewController;
-(void)interests;
-(NSString *)FBuserToken;
-(NSArray*)getUserPhotos:(NSString*) userID;
-(NSString*)loggedInUserFBId;
-(void)fasebookLogout;
-(NSString*)getAvatarURLWithID:(NSString*) userID;
//////CLASS METHODS
+(NSArray*)currentUserFriends;
+(NSArray*)getUserAlbums;
+(NSArray*)getUserPhotosInAlbumsWithId:(NSString*)Id;
+(NSArray*)currentUserInterests;
+(NSArray*)getUserInterestWithId:(NSString*)Id;
+(NSArray*)getUserActivities;
+(NSArray*)getNotifications;
+(NSString*)getAlnumCoverImage:(NSString*)albumId;
+(NSArray*)getUserPages;
+(NSArray*)currentUserInterests;
@end

@protocol FBHelperDelegate <NSObject>
-(id)getDelegate;
@end
