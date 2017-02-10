//
//  SocialsStoreCoordinator.h
//  Scadaddle
//
//  Created by Roman Bigun on 4/10/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectHandler.h"
#import "SocialsManager.h"
/*!
 @depricated class
 **/
@interface SocialsStoreCoordinator : NSObject
+(void)storeDataForSocialType:(int)type andData:(NSDictionary*)data;
+(BOOL)checkSocialExistanceForType:(int)type;
+(NSDictionary*)socialDataForType:(int)type;
@end
