//
//  CoreService.m
//  Scadaddle
//
//  Created by Roman Bigun on 30/03/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "ObjectHandler.h"



@implementation ObjectHandler
{

    DBHelper *dbHelper;
   
    __block NSArray *currentObject;
}
- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                           queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}
+ (ObjectHandler *)sharedInstance
{
    
    static ObjectHandler * _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[ObjectHandler alloc] init];
        
    });
    
    return _sharedInstance;
}

-(id)init
{
    
    self = [super init];
    if(!self)
    {
        
        return nil;
        
        
    }
    else
    {
       
        
        currentObject = [[NSArray alloc] init];
        dbHelper = [[DBHelper alloc] init];
        
        #define DB dbHelper
        
        
    }
    return self;
    
}
-(NSArray*)getSocials
{

    NSPredicate * predicate = nil;//liave it as nil object for 'Socials'
    return [DB getSocials:predicate];

}
-(void)setupReachability
{

#pragma mark Reachability
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    _reach = [Reachability reachabilityForInternetConnection];
    [_reach startNotifier];
    
    if ([_reach currentReachabilityStatus] != NotReachable)
    {
        _isInternetConnected = YES;
        
    }
    else
    {
        _isInternetConnected = NO;
        
    }


}
//Reachability delegate method
-(void)reachabilityChanged:(NSNotification *)notification
{
    Reachability *currentReachability = [notification object];
    
    if ([currentReachability currentReachabilityStatus] != NotReachable)
    {
        _isInternetConnected = YES;
        Alert(@"Internet Connection Back!");
    }
    else
    {
        _isInternetConnected = NO;
        [UIAlertView showAlertWithMessage_Block:@"Lost Internet Connection!"];
    }
}
-(void)addObjectToDB:(id)object
{
    
    [DB addObject:object];
    
}
-(BOOL)loginWithCredentials:(NSDictionary*)creds
{

//    if(_isInternetConnected){
//        
//        NSDictionary *loginRes = [NSDictionary dictionaryWithDictionary:
//                                  [Server loginToServerWithData:creds]];
//    
//        
//            __autoreleasing Profiles *user = [[Profiles alloc] init];
//            user = [user makeObjectForProfileFromDictionary:loginRes];
//            [self addObject:user];
//        
//            return YES;
//        
//#if DEBUG
//        Alert([loginRes objectForKey:@"message"]);
//#endif
//        return NO;
//    }
//    else{
//        
//        Alert(@"No internet connection");
//        return NO;
//    }
    
    return NO;

}
-(BOOL)login/*Auto login*/
{
//    if(_isInternetConnected){
//        
//        NSDictionary *loginRes = [NSDictionary dictionaryWithDictionary:
//                                  [Server loginToServer:[[DB getUserProfile] objectForKey:@"login"]]];
//        
//        if(![[loginRes objectForKey:@"status"] isEqualToString:@"ok"])
//            return NO;
//        
//        if([[loginRes objectForKey:@"data"] isKindOfClass:[NSDictionary class]])
//        {
//            [self deleteProfile];
//            __autoreleasing Profiles *user = [[Profiles alloc] init];
//            user = [user makeObjectForProfileFromDictionary:[loginRes objectForKey:@"data"]];
//            [self addObject:user];
//            return YES;
//        }
//#if DEBUG
//        Alert([loginRes objectForKey:@"message"]);
//#endif
//        return NO;
//    }
//    else{
//        
//        Alert(@"No internet connection");
//        return NO;
//    }
    
    return NO;
    
}
-(BOOL)registerUserWithParams:(id)params
{
    if(_isInternetConnected){
        if([Server registerUserWithParams:params]){
            return YES;
        }
#if DEBUG
        Alert(@"Something went wrong!");
#endif
    }
    else{Alert(@"No internet connection");}
    
    
    return NO;
    
}
//Adding objects by a USER
-(void)registerUserWithObject:(id)object
{
    [DB deleteProfile];
    
    NSDictionary *resUser = [Server registerUserWithParams:object];
    if([resUser count] >6)
    {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:resUser];
        Profiles *user = [[Profiles alloc] init];
        [DB addObject:[user makeObjectForProfileFromDictionary:params]];
    }
    else
    {
        
        Alert(@"Register:Failed!");
        
    }
    
}
-(void)deleteProfile
{
    [DB deleteProfile];
}
-(NSDictionary*)userProfile
{

    return [DB getUserProfile];//TODO:From server too
}
-(NSDictionary*)getSocialForId:(int)objId
{

    return [DB getSocialForId:objId];

}
-(NSDictionary *)profile:(NSString*)userId
{

   return [Server profile:userId];

}
-(NSArray *)activities:(NSString *)userId
{

    return [Server activities:userId];

}
-(NSArray *)events:(NSString *)userId
{
    return [Server events:userId];
}
-(NSArray *)notifications:(NSString *)userId
{

    return [Server notifications:userId];
}
-(NSDictionary *)dreamshot:(NSString *)userId
{

    return [Server dreamshot:userId];

}
-(NSArray *)interests:(NSString *)userId
{

    return [Server interests];
    
}
-(NSArray *)notebook:(NSString *)userId
{

    return [Server notebook:userId];
}
/*
-(BOOL)checkIfItemExistsWithId:(int)itemId andEntity:(id)entity
{

    NSArray *dbData = [NSArray array];
    
    if([[entity description] isEqualToString:@"Activities"])         dbData =  [DB getActivities];
 
 
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %i", itemId];
    NSArray *filteredArray = [dbData filteredArrayUsingPredicate:predicate];
    
    if(filteredArray.count>0)
    {
    
        return YES;
    
    }
    return NO;

}
 
-(NSDictionary*)getExistingItemWithId:(int)itemId andEntity:(id)entity
{

    NSArray *dbData = [NSArray array];
   
    if([[entity description] isEqualToString:@"Activities"])         dbData =  [DB getActivities];
 
   
    NSLog(@"DB element after adding new one\n%@",dbData);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %i", itemId];
    NSArray *filteredArray = [[NSArray alloc] initWithArray:[dbData filteredArrayUsingPredicate:predicate]];
    if(filteredArray.count==0)
    {
    
        return nil;
    
    }
    NSDictionary *res = [filteredArray objectAtIndex:0];
    
    return res;
    
}

-(NSDictionary*)getPond:(int)catchId
{

    NSDictionary *res = [DB getItemFromDB:catchId andObject:[Pond class]];
    if(res.count==0)
    {
        res = [Server getPond:catchId];
        Pond *t = [[Pond alloc] init];
        
            t = [t makeObjectForPondFromDictionary:res];
            [self addObjectToDB:t];
        
    }
    
    return res;


}
-(NSDictionary*)getProfileFromServer:(int)userId amIOwner:(BOOL)owner
{
  
    
    NSDictionary *res = [Server profile:[NSString stringWithFormat:@"%i",userId]
                          forPrsonWichIsOwnerOfHisProfile:owner];
    NSLog(@"%@",res);
    return res;

}

-(int)getLastIdForEntity:(id)entity
{

        NSArray *dbData = [NSArray array];
        
        if([[entity description] isEqualToString:@"Catch"])         dbData =  [DB getCatches ];
        if([[entity description] isEqualToString:@"Ponds"])         dbData =  [DB getPonds   ];
        if([[entity description] isEqualToString:@"Event"])         dbData =  [DB getEvents  ];
        if([[entity description] isEqualToString:@"FishSpice"])     dbData =  [DB getFishes  ];
        if([[entity description] isEqualToString:@"FishingTackle"]) dbData =  [DB getTackles ];
        if([[entity description] isEqualToString:@"Fisher"])        dbData =  [DB getFishers ];
        if([[entity description] isEqualToString:@"FishingRod"])    dbData =  [DB getRods    ];
        if([[entity description] isEqualToString:@"FeedObject"])    dbData =  [DB getMyFeed  ];
        if([[entity description] isEqualToString:@"MainFeedObject"])dbData =  [DB getMainFeed];
    
        int _id = [[[dbData firstObject] objectForKey:@"id"] intValue];
        return _id==0?1:_id;

}
-(NSArray*)getObjectsFromDBForEntity:(id)entity
{
    
    NSArray *dbData = [NSArray array];
    
    if([[entity description] isEqualToString:@"Catch"])         dbData =  [DB getCatches ];
    if([[entity description] isEqualToString:@"Pond"])          dbData =  [DB getPonds   ];
    if([[entity description] isEqualToString:@"Event"])         dbData =  [DB getEvents  ];
    if([[entity description] isEqualToString:@"FishSpice"])     dbData =  [DB getFishes  ];
    if([[entity description] isEqualToString:@"FishingTackle"]) dbData =  [DB getTackles ];
    if([[entity description] isEqualToString:@"Fisher"])        dbData =  [DB getFishers ];
    if([[entity description] isEqualToString:@"FishingRod"])    dbData =  [DB getRods    ];
    if([[entity description] isEqualToString:@"FeedObject"])    dbData =  [DB getMyFeed  ];
    if([[entity description] isEqualToString:@"MainFeedObject"])dbData =  [DB getMainFeed];
    
    return dbData;
    
}
-(int)getItemIdForTitle:(NSString*)title andEntity:(id)entity
{
    return [Core getItemIdForTitle:title andEntity:entity];

}
*/

@end
