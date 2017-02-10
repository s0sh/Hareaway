//
//  DBInitializator.h
//  Scadaddle
//
//  Created by Roman Bigun on 30/03/15.
//  Copyright (c) 2014 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#define Database [DBInitializator sharedInstance]
@interface DBInitializator : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (DBInitializator *)sharedInstance;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
