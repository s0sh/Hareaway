//
//  SettingsManager.h
//  Scadaddle
//
//  Created by Roman Bigun on 6/17/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSettingsIsNotificationEnabled @"notificAction"
#define kSettingsShowOnly @"showType"
#define kSettingsAgeRange @"ageRange"
#define kSettingsRadius @"radius"

@interface SettingsManager : NSObject
+(SettingsManager *)sharedManager;
/*!
 * @discussion  insert needed object to Settings object
 * @param 'object' could be any
 */
-(void)addObject:(id)object forKey:(NSString*)key;
/*!
 * @discussion  returns settings object which is currently being created
 */
-(NSDictionary *)ongoingSettings;
/*!
 * @discussion  to get stored settings data from the server and store data 
 * to current settings object for further work with its data
 */
-(NSDictionary*)updateSettings;
@end
