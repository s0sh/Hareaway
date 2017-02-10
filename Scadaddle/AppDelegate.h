//
//  AppDelegate.h
//  Scadaddle
//
//  Created by Roman Bigun on 3/25/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <CoreData/CoreData.h>
#import "Instagram.h"

@class GPPSignInButton;

typedef NS_ENUM(NSUInteger,NotificationTypes)
{
    
    kNotificationTypeChat,
    kNotificationTypeNewActivity,
    kNotificationTypeFriendshipRequest,
    kNotificationTypeFriendshipRequestDeclined,
    kNotificationTypeUserBlockedYou
    
    
};

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) GPPSignInButton* signInButton;
@property (strong, nonatomic) Instagram *instagram;
@property NotificationTypes *notificationType;
@property (strong, nonatomic) UINavigationController *navController;
@end

