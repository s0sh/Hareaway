//
//  User.h
//  Scadaddle
//
//  Created by developer on 16/04/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface User : NSObject

@property NSString *name;
@property NSString *avatarPath;
@property NSString *country;
@property NSString *email;
@property NSString *nikname;
@property NSString *lastname;
@property NSString *about;
@property NSString *userId;
@property NSString *activities;
@property NSString *imageURL;
@property int subscriptionType;
@property(strong, nonatomic) UIImage* image;
@property(strong, nonatomic) UIImageView* dounloadImage;
@end
