//
//  SocialsStoreCoordinator.m
//  Scadaddle
//
//  Created by Roman Bigun on 4/10/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "SocialsStoreCoordinator.h"

@implementation SocialsStoreCoordinator

+(void)storeDataForSocialType:(int)type andData:(NSDictionary*)data
{
    Socials *sn = [[Socials alloc] init];
    [Core addObjectToDB:[sn makeObjectForFocialFromDictionary:data andType:type]];
    
}
+(BOOL)checkSocialExistanceForType:(int)type
{

    SocialsManager *sm = [[SocialsManager alloc] init];
    Socials * sns = [sm socialWithType:type];
    if(sns!=nil)
        return YES;
    
    return NO;

}
+(NSDictionary*)socialDataForType:(int)type
{
    SocialsManager *sm = [[SocialsManager alloc] init];
    return [sm getSocialWithType:type];
}
@end
