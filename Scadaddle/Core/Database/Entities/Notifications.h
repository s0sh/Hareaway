//
//  Notifications.h
//  Scadaddle
//
//  Created by Roman Bigun on 4/3/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notifications : NSObject

@property int type;
@property int date;
@property (nonatomic,strong) NSString *userName;
@property (nonatomic,strong) NSString *avatarPath;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *interestPicName;
@end
