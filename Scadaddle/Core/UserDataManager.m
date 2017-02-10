//
//  UserDataManager.m
//  Scadaddle
//
//  Created by Roman Bigun on 5/19/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

/*!
 * @see .h file for methods description
 */

#import "UserDataManager.h"

@implementation UserDataManager

{
    NSMutableDictionary *registrationInfo;

}
-(id)init
{
    
    self = [super init];
    if(self){
        
        if(![[self getSavedUser] isKindOfClass:[NSString class]]){
            if([self getSavedUser].count>0)
            {
              registrationInfo = [[NSMutableDictionary alloc] initWithDictionary:[self localUserInfo]];
            }
            else{
              registrationInfo = [[NSMutableDictionary alloc] init];
            }
            
        }else{
              registrationInfo = [[NSMutableDictionary alloc] init];
        }
        
        NSLog(@"User\n%@,token %@",registrationInfo,[self serverToken]);
        
    }
    return self;
}
+(UserDataManager *)sharedManager
{
    
    static UserDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        
    });
    
    return manager;
}
-(void)saveFacebookToken:(NSString*)fbToken
{

    [[NSUserDefaults standardUserDefaults] setObject:fbToken forKey:kUDKFacebookToken];
    [[NSUserDefaults standardUserDefaults] synchronize];

}
-(void)saveFacebookUserId:(NSString*)fbUserId
{
    
    [[NSUserDefaults standardUserDefaults] setObject:fbUserId forKey:kUDKFacebookUID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
-(NSString*)getCurrentFacebookToken
{
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:kUDKFacebookToken];
    
}
-(void)saveRestApiToken:(NSString*)restToken
{
    
    [[NSUserDefaults standardUserDefaults] setObject:restToken forKey:kUDKServerToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
-(NSString*)serverToken
{

    NSLog(@"Server token %@",[[NSUserDefaults standardUserDefaults] objectForKey:kUDKServerToken]);
    return [[NSUserDefaults standardUserDefaults] objectForKey:kUDKServerToken];

}
-(void)saveAdditionalUserInfo:(NSDictionary*)info
{

    registrationInfo = info;
    [registrationInfo setObject:[self serverToken] forKey:kServerApiToken];
    
}
-(void)saveUserToDefaults:(NSDictionary*)info
{

    [[NSUserDefaults standardUserDefaults] setObject:info forKey:kUDKLocalUserInfo];
    [[NSUserDefaults standardUserDefaults] synchronize];

}
-(NSArray *)myInterests
{
    return registrationInfo[kUDKUserInterestsServerField];
}
-(NSDictionary*)localUserInfo
{

    return [[NSUserDefaults standardUserDefaults] objectForKey:kUDKLocalUserInfo];

}
-(void)saveDeviceToken:(NSString *)deviceToken
{
    [registrationInfo setValue:deviceToken forKey:@"deviceToken"];
    [registrationInfo setValue:@"ios" forKey:@"os"];
}
-(NSDictionary*)registrationInfo
{

    return registrationInfo;

}
-(void)removeUsersData
{

    [registrationInfo removeAllObjects];
    

}
-(void)addActivityInterests:(NSArray*)interests
{
   if(interests.count>0)
   {
     [registrationInfo setObject:interests forKey:kUDKUserInfoActivityInterests];
   }
   else
   {
    [registrationInfo setObject:registrationInfo[kUDKUserInfoInterests] forKey:kUDKUserInfoActivityInterests];
   }

}
-(void)addUserInterests:(NSArray*)interests
{
    if(interests.count>0)
    [registrationInfo setObject:interests forKey:kUDKUserInfoInterests];
   
}
-(NSArray*)activityLocation
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kUDKIActivityLocation];
}

-(void)setLocation:(NSArray*)locations
{

    [[NSUserDefaults standardUserDefaults] setObject:locations forKey:kUDKIActivityLocation];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
-(void)saveUser:(NSDictionary*)userInfo
{

    [[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:kUDKServerUserInfo];
    [[NSUserDefaults standardUserDefaults] synchronize];

}
-(NSDictionary*)getSavedUser
{
    NSLog(@"User\n%@",[[NSUserDefaults standardUserDefaults] objectForKey:kUDKServerUserInfo]);
    NSDictionary *tmp = [NSDictionary new];
    tmp = [[NSUserDefaults standardUserDefaults] objectForKey:kUDKServerUserInfo];
    return (NSDictionary*)tmp;

}
@end
