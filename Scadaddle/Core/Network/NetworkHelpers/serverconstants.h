//
//  serverconstants.h
//  Fishy
//
//  Created by Roman Bigun on 1/8/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#ifndef Fishy_serverconstants_h
#define Fishy_serverconstants_h

//Paths and prefixes
#define kPfxNetworkDelay 10

// Development Server


#define kServerMainPath @"http://scad.gotests.com/api"
#define SERVER_PATH @"" //Path for images and stuff
/*
#pragma mark Live Server
#define kServerMainPath @"http://scadlive.gotests.com/api"
#define SERVER_PATH @"" //Path for images and stuff

#pragma mark Nastya tests links
#define kServerMainPath @"http://scadtest.gotests.com/api"
#define SERVER_PATH @"" //Path for images and stuff
*/

#define JAVA_SERVER @"http://scadjabber.gotests.com:9090/"


#define kRequestPhoneVerification @"/verifications"
#define kRequestBecomeAMember @"/members/activities"
#define kRequestRemoveNotification @"/removenotifications"
#define kRequestMemberAccept @"/members/activities"
#define kRequestRefreshTokenAndUserExistance @"/checkfbid"
#define kRequestUpdateDeviceToken @"/notifications/params"
#define kRequestBlockUser @"/blocks/users"
#define kRequestPostProfile @"/users"
#define kRequestUserRegister   @"/registers"
#define kRequestAddToMyFriend  @"/adds/friends"
#define kRequestUpdateUser     @"/users"
#define kRequestUserFriends    @"/friends"
#define kRequestUserProfile    @"/userbyids"
#define kRequestUserNotifications @"/notifications"
#define kRequestAllActivities     @"activities/own"
#define kRequestFollowingActivities     @"activities/following"
#define kRequestAcceptedActivities     @"activities/accepted"
#define kRequestNotebookMainPage   @"/notebook/all"
#define kRequestNotebookFollowings @"/notebook/followings"
#define kRequestNotebookIce        @"/notebook/icebreaker"
#define kRequestNotebookFriendship @"/friendships/requests"
#define kRequestNotebookFriends    @"/notebook/friends"
#define kRequestNotebookBlocks @"/notebook/blocks"

#define kRequestUserActivities @"/mainpage"
#define kRequestCrossInterests @"/crossinterests"
#define kRequestSetPrimaryInterest @"/interests/setprimaries"
#define kRequestAddUserActivity @"/addactivities"
#define kRequestUpdateExistedActivity @"/updateactivities"
#define kRequestAddUserSettings @"/settings"
#define kRequestUpdateLocation  @"/userlocations"
#define kRequestRemoveUser      @"/removeusers"
#define kRequestRemoveActivity  @"/removeactivities"
#define kRequestGetSettings     @"getsettings"
#define kRequestGetPrimaryInterest @"/interests/primary"
#define kRequestUserInterests  @"/interests"
#define kRequestUserNotebook   @"/notebook"
#define kRequestUserEvents     @"/events"
#define kRequestUserDreamshot  @"/dreamshot"
#define kRequestUserNotifications @"/notifications"
#define kRequestUserFacebookAccounts @"/fb/accounts"
#define kRequestUserYoutubeVideo @"/user/youtubevideos"
#define kRequestActivities @"/mainpage/activities"
#define kRequestActivitiesProfile @"/activities/profile"
#define kRequestInterests @"/mainpage/interests"
#define kRequestRewards @"/mainpage/revards"
#define kRequestDeleteUser @"/hides/users"
#define kRequestDeleteActivity @"/mainpage/revards"
#define kRequestFollowUser @"/mainpage/revards"
#define kRequestFollowActivity @"/mainpage/revards"
#define kRequestProfile @"/user/profile"
#define kRequestPublicInterests @"/publicinterests"
#define kRequestPostProfile @"/users"
#define kRequestHideActivity @"/hides/activities"
#define kRequestFollowActivities @"/follows/activities"
#define kRequestFollowUsers @"/follows/users"
#define kRequestHideUsers @"/hides/users"
#define kRequestChat @"/chat/users"
#define kRequestPushChat @"/chats/notifications"
#define kRequestChatImage  @"/chats/imgs"
#define kRequestChatNotification  @"/chats/notifications"
#define kRequestPostUserOnline @"/users/onlines"

typedef NS_ENUM(NSInteger, SCADPagesIDsForMessages) {
    SCADSmallMessage,
    SCADLargeMessage,
    SCADTipsInterestMessage,
    SCADTipsRegistrationMessage,
    SCADMessageTypeUndefined
    
};

#endif
