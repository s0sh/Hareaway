//
//  Interest.h
//  Scadaddle
//
//  Created by developer on 02/04/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, InterestType) {
    yourOwnInterests = 0,
    fasebookInterests,
    publicInterests,
    preloadedInterests
};

@interface Interest : NSObject//--currently referred as Interest

@property NSString *interestTitle;
@property BOOL selected;
@property UIImage *interestImage;
@property (nonatomic, assign) InterestType interestType;
@property NSString *interestID;
@property NSMutableArray *usersByInterests;  //Mutable only on test - fix in prod
@property NSString *likeCount;
@property NSString *interestImageURL;

@property NSDictionary *fullInterestDictionary;

@end
