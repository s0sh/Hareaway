//
//  DBHelper.h
//  Scadaddle
//
//  Created by Roman Bigun on 30/3/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBWorker.h"

@interface DBHelper : NSObject
{

    

}
@property (strong, nonatomic) DBWorker *singlesObject;
@property (strong, nonatomic) DBWorker *socialsObject;
@property (strong, nonatomic) DBWorker *mainObject;
@property (strong, nonatomic) DBWorker *userProfileObject;
@property (strong, nonatomic) DBWorker *otherProfileObject;
@property (strong, nonatomic) DBWorker *activitiesObject;
@property (strong, nonatomic) DBWorker *friendsObject;
@property (strong, nonatomic) DBWorker *interestsObject;
@property (strong, nonatomic) DBWorker *notebookObject;
@property (strong, nonatomic) DBWorker *notificationsObject;
@property (strong, nonatomic) DBWorker *rewardsObject;
@property (strong, nonatomic) DBWorker *schedulersObject;

-(id)init;
-(void)addObject:(id)object;
-(NSDictionary*)getItemFromDB:(int)itemId;
-(NSDictionary*)getUserProfile;
-(void)deleteProfile;
-(void)deleteItemWithId:(int)objId forEntity:(id)entity;
-(NSDictionary*)getItemFromDB:(int)itemId andObject:(id)object;
-(int)findIdByTitle:(NSString*)title forObject:(id)object;
-(NSArray *)getSocials:(NSPredicate *)predicate;
-(NSDictionary*)getSocialForId:(int)objId;
@end
