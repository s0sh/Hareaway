//
//  Activities.h
//  Scadaddle
//
//  Created by Roman Bigun on 3/31/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ObjectHandler.h"

@interface Activities : NSObject
@property(assign)int objId;
@property(assign)int userId;
@property(assign)int locationId;
@property(assign)int interestId;
@property(assign)int places;
@property(assign)int promoted;
@property(assign)int status;
@property(assign)int created;
@property(nonatomic,strong)NSString *title;
@property(nonatomic,strong)NSString *objDescription;
@property(nonatomic,strong)NSString *facebook;
@property(nonatomic,strong)NSString *twitter;
@property(nonatomic,strong)NSString *youtube;
@property(nonatomic,strong)NSString *reward;
@property(nonatomic,strong)UIImage *image;
@property(nonatomic,strong)NSString *imagePath;

@property(nonatomic,strong)NSArray *activityFiles;
@property(nonatomic,strong)NSArray *activityInterests;
@property(nonatomic,strong)NSArray *activityTimes;
@property(nonatomic,strong)NSArray *activityFriends;

-(id)makeObjectForActivitiesFromDictionary:(NSDictionary*)data;

@end
