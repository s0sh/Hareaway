//
//  Notification.h
//  Scadaddle
//
//  Created by developer on 16/04/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class User;

typedef NS_ENUM(NSUInteger,  NotificationType) {
    messageNotification = 0,
    dreamShotNotification,
    systemNotification,
    followerNotification
};

@interface Notification : NSObject

@property (nonatomic, assign) NotificationType notificationType;
@property NSString *notificationText;
@property NSString *notificationClass;
@property UIImage *notificationtImage;
@property NSString *notificationID;
@property NSString *notificationDate;
@property User *notificationUser;
@property NSString *notificationMessageText;
@property NSMutableArray *inrerests;      //Mutable only on test - fix in prod

@end
