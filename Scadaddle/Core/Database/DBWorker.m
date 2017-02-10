//
//  DBWorker.m
//  Fishy
//
//  Created by Roman Bigun on 30/03/15.
//  Copyright (c) 2014 Roman Bigun. All rights reserved.
//

#import "DBWorker.h"
#import "dbconstants.h"

@implementation DBWorker
{


}
@synthesize delegate;

-(id)init
{
    //NOTE: Use this init method if you want to use your class as a delegate (one entity only)
    self = [super init];
    return self;
}
-(id)initWithEntity:(NSString*)entity
{
    /*NOTE: Use this init method when you want create multiple entity objects in one class*/
    self = [super init];
    self.entity = [[NSString alloc] initWithString:entity];
    [self FetchedResultControllerForEntity];
    
    return self;
    
    
}
-(void)addObject:(id)object
{
   
    if(object!=nil){
        NSManagedObjectContext *context = [Database managedObjectContext];
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:self.entity
                                                         inManagedObjectContext:context];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:self.entity
                                                               inManagedObjectContext:context];
        [request setEntity:entity];
        
        if([object isKindOfClass:[Socials class]])
        {
            Socials *obj = object;
            [newManagedObject setValue:obj.data forKey:kSocialsDBFieldData];
            [newManagedObject setValue:[NSNumber numberWithInt:(int)obj.type] forKey:kSocialsDBFieldType];
            
        }
        if([object isKindOfClass:[Notifications class]])
        {
            
            [newManagedObject setValue:object forKey:kNotificationDBField];
            
        }
        if([object isKindOfClass:[Activities class]])
        {
            
            Activities *obj = object;
            if([self getItemWithId:obj.objId].count==0)
            {
                [newManagedObject setValue:[NSNumber numberWithInt:obj.objId] forKey:kId];
                [newManagedObject setValue:[NSNumber numberWithInt:obj.userId] forKey:kUserID];
                [newManagedObject setValue:[NSNumber numberWithInt:obj.places] forKey:kPlaces];
                [newManagedObject setValue:[NSNumber numberWithInt:obj.status] forKey:kStatus];
                [newManagedObject setValue:[NSNumber numberWithInt:obj.created] forKey:kCreated];
                [newManagedObject setValue:[NSNumber numberWithInt:obj.promoted] forKey:kPromoted];
                [newManagedObject setValue:[NSNumber numberWithInt:obj.locationId] forKey:kLocationId];
                [newManagedObject setValue:[NSNumber numberWithInt:obj.interestId] forKey:kInterestId];
                [newManagedObject setValue:obj.title forKey:kTitle];
                [newManagedObject setValue:obj.reward forKey:kReward];
                [newManagedObject setValue:obj.twitter forKey:kTwitter];
                [newManagedObject setValue:obj.youtube forKey:kYoutube];
                [newManagedObject setValue:obj.facebook forKey:kFacebook];
                [newManagedObject setValue:obj.objDescription forKey:kDescription];
                [newManagedObject setValue:obj.image forKey:kImage];
                [newManagedObject setValue:obj.activityInterests forKey:kActivityInterests];
                [newManagedObject setValue:obj.activityFriends forKey:kActivityFriends];
                [newManagedObject setValue:obj.activityFiles forKey:kActivityFiles];
                [newManagedObject setValue:obj.activityTimes forKey:kActivityTimes];
            }
            else
            {
                NSLog(@"OBJ exists");
            }
            
        }
        if([object isKindOfClass:[Profiles class]])
        {
            
                Profiles *obj = object;
            
                [newManagedObject setValue:[NSNumber numberWithInt:obj.objId] forKey:kId];
                [newManagedObject setValue:[NSNumber numberWithInt:obj.modeId] forKey:kModeId];
                [newManagedObject setValue:[NSNumber numberWithInt:obj.status] forKey:kStatus];
                [newManagedObject setValue:[NSNumber numberWithInt:obj.created] forKey:kCreated];
                [newManagedObject setValue:[NSNumber numberWithInt:obj.access] forKey:kAccess];
                [newManagedObject setValue:[NSNumber numberWithInt:obj.login] forKey:kLogin];
                [newManagedObject setValue:[NSNumber numberWithInt:obj.lanStatus] forKey:kLanStatus];
                [newManagedObject setValue:[NSNumber numberWithInt:obj.locationId] forKey:kLocationId];
                [newManagedObject setValue:obj.fbId forKey:kFacebookId];
                [newManagedObject setValue:obj.accessToken forKey:kFacebookAccessToken];
                [newManagedObject setValue:obj.name forKey:kName];
                [newManagedObject setValue:obj.email forKey:kEmail];
                [newManagedObject setValue:obj.role forKey:kRole];
                [newManagedObject setValue:obj.about forKey:kAbout];
                [newManagedObject setValue:obj.fbId forKey:kFacebookId];
                [newManagedObject setValue:obj.timezone forKey:kTimezone];
                [newManagedObject setValue:obj.userFiles forKey:kUserFiles];
                [newManagedObject setValue:obj.userBusiness forKey:kBusiness];
                [newManagedObject setValue:obj.userInterests forKey:kUserInterests];
                [newManagedObject setValue:obj.userReferences forKey:kReferences];
                [newManagedObject setValue:obj.userSettings forKey:kSettings];
                [newManagedObject setValue:obj.userActivities forKey:kActifities];
                
           
            
            
        }
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        else
        {
        
            NSLog(@"Saved %@",[object description]);
        
        }
    }
    else
    {
    
        //Message to a user about nil object
    
    }
    
}
- (void)deleteProfile
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Profile"];
    [fetchRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    NSError *error;
    NSArray *fetchedObjects = [[Database managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *object in fetchedObjects)
    {
        [[Database managedObjectContext] deleteObject:object];
    }
    error = nil;
    [[Database managedObjectContext] save:&error];
}
- (void)deleteObjectWithId:(int)objId
{

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:self.entity];
    [fetchRequest setIncludesPropertyValues:NO];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"id == %i", objId]; // dateInt is a unix time stamp for the current time
    [fetchRequest setPredicate:pred];
     NSError *error;
    NSArray *fetchedObjects = [[Database managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *object in fetchedObjects)
    {
        [[Database managedObjectContext] deleteObject:object];
    }
    
    error = nil;
    [[Database managedObjectContext] save:&error];

}
-(NSArray*)getItemsUsingPredicate:(NSPredicate*)predicate andEntity:(NSString*)entity
{
    
    __autoreleasing NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entitySetUp = [NSEntityDescription entityForName:entity
                                              inManagedObjectContext:
                                   [Database managedObjectContext]];
    if(predicate!=nil)
        [request setPredicate:predicate];
    
    [request setEntity:entitySetUp];
    [request setReturnsObjectsAsFaults:NO];
    __autoreleasing NSArray *arr = [NSArray arrayWithArray:
                                    [[Database managedObjectContext]
                                     executeFetchRequest:request
                                     error:NULL]];
    //*! Serialyzer **//
    NSMutableArray *res = [[NSMutableArray alloc] init];
    if(arr.count>0)
    {
        NSDictionary *attributes = [entitySetUp attributesByName];
        
        for(int i=0;i<arr.count;i++)
        {
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            for (NSString* attr in attributes) {
                NSObject* value = [[arr objectAtIndex:i] valueForKey:attr];
                
                if (value != nil) {
                    [dict setObject:value forKey:attr];
                }
            }
            [res addObject:dict[@"data"]];
            
        }
    }
    
    return res;

    
}

-(NSDictionary*)getItemUsingPredicate:(NSPredicate*)predicate
{
    
    __autoreleasing NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entity
                                              inManagedObjectContext:
                                   [Database managedObjectContext]];
    [request setPredicate:predicate];
    [request setEntity:entity];
    [request setReturnsObjectsAsFaults:NO];
    __autoreleasing NSArray *arr = [NSArray arrayWithArray:
                                    [[Database managedObjectContext]
                                     executeFetchRequest:request
                                     error:NULL]];
    //*! Serialyzer **//
    if(arr.count>0)
    {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        NSDictionary *attributes = [entity attributesByName];
        
        for (NSString* attr in attributes) {
            NSObject* value = [[arr lastObject] valueForKey:attr];
            
            if (value != nil) {
                [dict setObject:value forKey:attr];
            }
        }
        
        return dict.count>0?dict:nil;
    }
    return nil;
    
}


-(NSArray*)getItemsUsingPredicate:(NSPredicate*)predicate
{

    __autoreleasing NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entity
                                              inManagedObjectContext:
                                   [Database managedObjectContext]];
    [request setPredicate:predicate];
    [request setEntity:entity];
    [request setReturnsObjectsAsFaults:NO];
    __autoreleasing NSArray *arr = [NSArray arrayWithArray:
                                    [[Database managedObjectContext]
                                     executeFetchRequest:request
                                     error:NULL]];
    if(arr.count>0)
    {
        return arr;
    }
    return nil;

}
-(NSDictionary*)getItemWithId:(int)cId
{
    
    __autoreleasing NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entity
                                              inManagedObjectContext:
                                   [Database managedObjectContext]];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"id == %i", cId];
    [request setPredicate:pred];
    
    [request setEntity:entity];
    [request setReturnsObjectsAsFaults:NO];
    __autoreleasing NSArray *arr = [NSArray arrayWithArray:
                                    [[Database managedObjectContext]
                                     executeFetchRequest:request
                                     error:NULL]];
    //*! Serialyzer **//
    if(arr.count>0)
    {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        NSDictionary *attributes = [entity attributesByName];
        
        for (NSString* attr in attributes) {
            NSObject* value = [[arr lastObject] valueForKey:attr];
            
            if (value != nil) {
                [dict setObject:value forKey:attr];
            }
        }
        
        return dict.count>0?dict:nil;
    }
    return nil;
    
    
}
-(int)getItemIdForTitle:(NSString*)title
{
    
    __autoreleasing NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entity
                                              inManagedObjectContext:
                                   [Database managedObjectContext]];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"title == %@", title];
    [request setPredicate:pred];
    
    [request setEntity:entity];
    [request setReturnsObjectsAsFaults:NO];
    __autoreleasing NSArray *arr = [NSArray arrayWithArray:
                                    [[Database managedObjectContext]
                                     executeFetchRequest:request
                                     error:NULL]];
    //*! Serialyzer **//
    int res = -1;
    if(arr.count>0)
    {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        NSDictionary *attributes = [entity attributesByName];
        
        for (NSString* attr in attributes) {
            NSObject* value = [[arr lastObject] valueForKey:attr];
            
            if (value != nil) {
                [dict setObject:value forKey:attr];
            }
        }
        
        return (int)[dict objectForKey:@"id"];
    }
    return res;
    
    
}
-(NSDictionary*)getUserProfile
{
    
    __autoreleasing NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entity
                                              inManagedObjectContext:
                                   [Database managedObjectContext]];
    [request setEntity:entity];
    [request setReturnsObjectsAsFaults:NO];
    __autoreleasing NSArray *arr = [NSArray arrayWithArray:
                                    [[Database managedObjectContext]
                                     executeFetchRequest:request
                                     error:NULL]];
    //*! Serialyzer **//
    if(arr.count>0)
    {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        NSDictionary *attributes = [entity attributesByName];
        
        for (NSString* attr in attributes) {
            NSObject* value = [[arr lastObject] valueForKey:attr];
            
            if (value != nil) {
                [dict setObject:value forKey:attr];
            }
    }
    
       return dict.count>0?dict:nil;
   }
    return nil;
    

}
-(NSDictionary*)getOtherProfileWithId:(int)objId
{
    
    __autoreleasing NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entity
                                              inManagedObjectContext:
                                   [Database managedObjectContext]];
    [request setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"id == %i", objId]; // dateInt is a unix time stamp for the current time
    [request setPredicate:pred];
    
    [request setReturnsObjectsAsFaults:NO];
    __autoreleasing NSArray *arr = [NSArray arrayWithArray:
                                    [[Database managedObjectContext]
                                     executeFetchRequest:request
                                     error:NULL]];
    //*! Serialyzer **//
    if(arr.count>0)
    {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        NSDictionary *attributes = [entity attributesByName];
        
        for (NSString* attr in attributes) {
            NSObject* value = [[arr lastObject] valueForKey:attr];
            
            if (value != nil) {
                [dict setObject:value forKey:attr];
            }
        }
        
        return dict.count>0?dict:nil;
    }
    return nil;
    
    
}

-(NSArray*)getAllObjects
{
    
    __autoreleasing NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entity
                                              inManagedObjectContext:[Database managedObjectContext]];
    [request setEntity:entity];
    
    __autoreleasing NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                                        initWithKey:self.delegate==nil?
                                                        @"id":[self.delegate sortDescriptorKeyForFetchObjects:self]
                                                        ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    [request setReturnsObjectsAsFaults:NO];
    
    __autoreleasing NSArray *arr = [NSArray arrayWithArray:
                                    [[Database managedObjectContext]
                                     executeFetchRequest:request
                                     error:NULL]];
    
    //*!  Serialyzer **//
    NSMutableArray *res = [[NSMutableArray alloc] init];
    if(arr.count>0)
    {
        NSDictionary *attributes = [entity attributesByName];
       
        for(int i=0;i<arr.count;i++)
        {
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            for (NSString* attr in attributes) {
                NSObject* value = [[arr objectAtIndex:i] valueForKey:attr];
                
                if (value != nil) {
                    [dict setObject:value forKey:attr];
                }
            }
            [res addObject:dict];
            
        }
    }
    
    return res;
    
}
-(void)FetchedResultControllerForEntity
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.delegate==nil?
                                   self.entity:[self.delegate entityName:self]
                                   inManagedObjectContext:[Database managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    if([self.delegate respondsToSelector:@selector(itemsCount:)] && self.delegate){
       [fetchRequest setFetchBatchSize:[self.delegate itemsCount:self]];
    }
    else{
        [fetchRequest setFetchBatchSize:15];//by default
    }
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:self.delegate==nil?@"id":
                                        [self.delegate respondsToSelector:@selector(sortDescriptorKeyForInit:)]?
                                        [self.delegate sortDescriptorKeyForInit:self]:@"id" ascending:NO];
    
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    if([self.delegate respondsToSelector:@selector(setupPredicate:)]){
            NSPredicate *predicate = [self.delegate setupPredicate:self];
            [fetchRequest setPredicate:predicate];
        
    }
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]
                                                             initWithFetchRequest:fetchRequest
                                                             managedObjectContext:[Database managedObjectContext]
                                                             sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    
    NSLog(@"Set up object for:%@ - Done\n",self.entity);
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    

}
@end
