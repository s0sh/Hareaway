//
//  emsActivityEvent.h
//  Scadaddle
//
//  Created by developer on 25/05/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, ActivityEventType) {
    myOwnActivity= 0,
    followActivity,
    acceptedActivity

};
@interface emsActivityEvent : NSObject
@property (nonatomic, assign) ActivityEventType activityEventType;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic) int distance;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *interestImage;
@end


