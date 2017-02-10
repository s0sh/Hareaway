//
//  SettingsManager.m
//  Scadaddle
//
//  Created by Roman Bigun on 6/17/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "SettingsManager.h"
#import "emsAPIHelper.h"
@implementation SettingsManager
{
    NSMutableDictionary *settingsDict;
}

-(id)init
{
    
    self = [super init];
    if(self){
        settingsDict = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:[Server getSettings]];
        if(tmp)
           settingsDict = tmp;
    }
    return self;
}
+(SettingsManager *)sharedManager
{
    
    static SettingsManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        
    });
    
    return manager;
}
/*!
 * @discussion  insert needed object to Settings object
 * @param 'object' could be any
 */
-(void)addObject:(id)object forKey:(NSString*)key
{

    [settingsDict setObject:object forKey:key];

}
/*!
 * @discussion  to get stored settings data from the server and store data
 * to current settings object for further work with its data
 */
-(NSDictionary*)updateSettings
{
    settingsDict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:[Server getSettings]];
    if(tmp)
        settingsDict = tmp;
    return settingsDict;
}
/*!
 * @discussion  returns settings object which is currently being created
 */
-(NSDictionary *)ongoingSettings
{
    return settingsDict;
}
@end
