//
//  DBWorker.h
//  Fishy
//
//  Created by Roman Bigun on 30/03/15.
//  Copyright (c) 2014 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "DBInitializator.h"
#import "Activities.h"
#import "Profile.h"
#import "Notifications.h"

@protocol DBWorkerDelegate;

@interface DBWorker : NSObject

@property(nonatomic,retain)NSString *entity;
@property (weak) id<DBWorkerDelegate> delegate;


-(id)init;
-(id)initWithEntity:(NSString*)entity;
- (void)deleteProfile;
-(void)FetchedResultControllerForEntity;
-(NSArray*)getAllObjects;
-(void)addObject:(id)object;
-(NSDictionary*)getUserProfile;
-(NSDictionary*)getOtherProfileWithId:(int)objId;
-(NSDictionary*)getItemWithId:(int)cId;
- (void)deleteObjectWithId:(int)objId;
-(int)getItemIdForTitle:(NSString*)title;
-(NSArray*)getItemsUsingPredicate:(NSPredicate*)predicate;
-(NSDictionary*)getItemUsingPredicate:(NSPredicate*)predicate;
-(NSArray*)getItemsUsingPredicate:(NSPredicate*)predicate andEntity:(NSString*)entity;
-(NSArray*)getItemUsingPredicate:(NSPredicate*)predicate andEntity:(NSString*)entity;
@end

@protocol DBWorkerDelegate <NSObject>
@required
- (NSString*)entityName:(DBWorker*)worker;
- (NSString*)sortDescriptorKeyForInit:(DBWorker*)worker;
- (NSString*)sortDescriptorKeyForFetchObjects:(DBWorker*)worker;
@optional
-(NSPredicate*)setupPredicate:(DBWorker*)worker;
-(int)itemsCount:(DBWorker*)worker;
@end