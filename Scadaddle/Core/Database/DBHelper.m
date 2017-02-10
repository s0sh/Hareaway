//
//  DBHelper.m
//  Fishy
//
//  Created by Roman Bigun on 30/3/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "DBHelper.h"

@implementation DBHelper

-(id)init
{
    //NOTE: Use this init method if you want to use your class as a delegate (one entity only)
    self = [super init];
    [self installDBaseAndEntities];
    return self;
}
- (void)deleteProfile
{

    [self.userProfileObject deleteProfile];

}
- (void)deleteItemWithId:(int)objId forEntity:(id)object
{
//    self.mainObject = [[DBWorker alloc] initWithEntity:[object description]];
//    return [self.mainObject deleteObjectWithId:objId];
    
    if([[object description] isEqualToString:@"Profile"]){
        return [self.userProfileObject deleteObjectWithId:objId];
    }
    
}
-(NSArray *)getSocials:(NSPredicate *)predicate
{

    return [self.socialsObject getItemsUsingPredicate:predicate andEntity:@"Socials"];

}
-(void)addObject:(id)object
{
//    self.mainObject = [[DBWorker alloc] initWithEntity:[object description]];
//    return [self.mainObject addObject:object];
    
    if([object isKindOfClass:[Profiles class]]){
        [self.userProfileObject addObject:object];
    }
    
}
-(int)findIdByTitle:(NSString*)title forObject:(id)object
{
//    self.mainObject = [[DBWorker alloc] initWithEntity:[object description]];
//    return [self.mainObject getItemIdForTitle:@"title"];
    
    if([[object description] isEqualToString:@"OtherProfiles"]){
        return [self.otherProfileObject getItemIdForTitle:title];
    }
    if([[object description] isEqualToString:@"Friends"]){
        return [self.friendsObject  getItemIdForTitle:title];
    }
    if([[object description] isEqualToString:@"Activities"]){
        return [self.activitiesObject getItemIdForTitle:title];
    }
    if([[object description] isEqualToString:@"Socials"]){
        return [self.socialsObject getItemIdForTitle:title];
    }
    if([[object description] isEqualToString:@"Interests"]){
        return [self.interestsObject getItemIdForTitle:title];
    }
    if([[object description] isEqualToString:@"Notebook"]){
        return [self.notebookObject getItemIdForTitle:title];
    }
    if([[object description] isEqualToString:@"Notifications"]){
        return [self.notificationsObject getItemIdForTitle:title];
    }
    if([[object description] isEqualToString:@"Rewards"]){
        return [self.rewardsObject getItemIdForTitle:title];
    }
    if([[object description] isEqualToString:@"Scheduler"]){
        return [self.schedulersObject getItemIdForTitle:title];
    }
    if([[object description] isEqualToString:@"Singles"]){
        return [self.singlesObject getItemIdForTitle:title];
    }
   
    return 1;
    
}
-(NSDictionary*)getUserProfile{
    return [self.userProfileObject getUserProfile];

}
-(NSDictionary*)getSocialForId:(int)objId{
    
     NSPredicate *pred = [NSPredicate predicateWithFormat:@"id == %i", objId];
    return [self.socialsObject getItemUsingPredicate:pred];
    
}
-(NSDictionary*)getItemFromDB:(int)itemId andObject:(id)object{

//    self.mainObject = [[DBWorker alloc] initWithEntity:[object description]];
//    return [self.mainObject getItemWithId:itemId];
    
    if([[object description] isEqualToString:@"OtherProfiles"]){
        return [self.otherProfileObject getItemWithId:itemId];
    }
    if([[object description] isEqualToString:@"Friends"]){
        return [self.friendsObject getItemWithId:itemId];
    }
    if([[object description] isEqualToString:@"Activities"]){
        return [self.activitiesObject getItemWithId:itemId];
    }
    if([[object description] isEqualToString:@"Socials"]){
        return [self.socialsObject getItemWithId:itemId];
    }
    if([[object description] isEqualToString:@"Interests"]){
        return [self.interestsObject getItemWithId:itemId];
    }
    if([[object description] isEqualToString:@"Notebook"]){
        return [self.notebookObject getItemWithId:itemId];
    }
    if([[object description] isEqualToString:@"Notifications"]){
        return [self.notificationsObject getItemWithId:itemId];
    }
    if([[object description] isEqualToString:@"Rewards"]){
        return [self.rewardsObject getItemWithId:itemId];
    }
    if([[object description] isEqualToString:@"Scheduler"]){
        return [self.schedulersObject getItemWithId:itemId];
    }
    if([[object description] isEqualToString:@"Singles"]){
        return [self.singlesObject getItemWithId:itemId];
    }
    return nil;
    
}
-(void)installDBaseAndEntities
{
    
    self.userProfileObject = [[DBWorker alloc] initWithEntity:@"Profile"];
   
}

/*
 //Delegate methods
 
-(NSArray*)dbObjectsForCurrentEntity
{
    
    return [NSArray arrayWithArray:[self.catchObject getAllObjects]];
    
}

#pragma mark DBWorkerDelegate methods [requered]
-(NSString *)entityName:(DBWorker*)worker{
    return @"Catch";
}
-(NSString*)sortDescriptorKeyForFetchObjects:(DBWorker*)worker{
    return @"id";
}
-(NSString*)sortDescriptorKeyForInit:(DBWorker*)worker{
    return @"id";
    
}
#pragma mark DBWorkerDelegate methods [optional]

-(NSPredicate*)setupPredicate:(DBWorker*)worker{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"catchId == 0"];
    
    return predicate;
    
}
-(int)itemsCount:(DBWorker*)worker{
    return 50;
    
}
*/
@end
