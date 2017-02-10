//
//  Profile.h
//  Scadaddle
//
//  Created by Roman Bigun on 3/31/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Profiles : NSObject

@property(assign)int objId;
@property(assign)int created;
@property(assign)int modeId;
@property(assign)int locationId;
@property(assign)int access;
@property(assign)int login;
@property(assign)BOOL status;
@property(assign)BOOL lanStatus;
@property(nonatomic,strong)NSString *fbId;
@property(nonatomic,strong)NSString *email;
@property(nonatomic,strong)NSString *role;
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *about;
@property(nonatomic,strong)NSString *timezone;
@property(nonatomic,strong)NSString *imagePath;
@property(nonatomic,strong)NSString *userBusiness;
@property(nonatomic,strong)NSString *accessToken;
@property(nonatomic,strong)UIImage *image;
@property(nonatomic,strong)NSString *userBirthday;
@property(nonatomic,strong)NSArray *userReferences;
@property(nonatomic,strong)NSArray *userInterests;
@property(nonatomic,strong)NSArray *userFiles;
@property(nonatomic,strong)NSArray *userActivities;
@property(nonatomic,strong)NSDictionary *userSettings;

-(id)makeObjectForProfileFromDictionary:(NSDictionary*)data;

@end
