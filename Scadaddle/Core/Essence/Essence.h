//
//  Essence.h
//  Scadaddle
//
//  Created by developer on 22/04/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class User;

typedef NS_ENUM(NSUInteger, EssenceType) {
    activityEssence= 0,
    singleEssence,
    interestEssence,
    rewardEssence,
};

@interface Essence : NSObject

@property (nonatomic, assign) EssenceType essenceType;
@property NSString *essenceTitle;
@property UIImage *essenceImage;
@property NSString *essenceID;
@property NSString *inrerestsDescription;
@property User *essenceUser;
@property NSMutableArray *inrerests;
@property UIImage *statusView;
@property BOOL selected;
@property BOOL notAnimateScroll;
@property BOOL showUsers;
@end
