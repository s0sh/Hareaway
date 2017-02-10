

//
//  ABStoreManager.m
//  ActivityStoreManager
//
//  Created by Roman Bigun on 5/9/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "ABStoreManager.h"
#import "UserDataManager.h"
#import "NSData+Base64.h"

@implementation ABStoreManager
{

    NSMutableDictionary *dataDictionary;
    NSMutableArray *activitiesArray;
    NSMutableArray *schedulerDates;
    NSMutableArray *pickedImagesArray;
    NSMutableArray *pickedFriendsArray;
    NSMutableArray *pickedFacebookArray;
    NSMutableArray *youtubeObjects;
    NSMutableDictionary *schedulerObject;
    NSMutableArray *pickedInterestsArray;
    NSMutableArray *pickedActivityInterestsArray;
    NSMutableArray *pickedImageFromAssets;
    NSMutableArray *socialImagesArray;
    NSMutableArray *markedForDelectionArray;
    NSString *editingAId;
    NSString *latitude;
    NSString *longitude;
    NSString *shareLink;
    UIImage *currentABInterestImage;
    BOOL editingMode;
    NSMutableDictionary *editProfileDictiomary;
    BOOL editProfileMode;
    BOOL chatMode;
    UIImage *imageForChat;
    NSMutableArray * chatDataDictionary;
    NSMutableArray * editProfeleSelectedInterests;
    NSMutableArray * editProfileStachArray;
    NSMutableArray * markedForDeletionImages;
    NSMutableArray * youtubeObjectsToRemove;
    BOOL doneEditing;
    BOOL needReloadMainScreen;
    NSString *newAddedInrerestID;
}
@synthesize imageCache,editingActivityObject;

/* Dont remove!!
 
-(NSString *)stringForIntegerKey:(NSString *)key
{

    __strong NSString **pointer = (NSString**)&vDaysArray;
    pointer += key;
    return *pointer;

}
 */


/*!**********************************    SHORTIES  [Setters/Getters/Workers] *****************************/
 
-(void)addDateToScheduler:(id)data forKey:(NSString *)intKey {[schedulerObject setObject:data forKey:intKey];}
-(void)setEditProfileMode:(BOOL)mode                  { editProfileMode = mode; }
-(void)settleEditingActivityID:(NSString*)aId         { editingAId = [[NSString alloc] initWithString:aId];}
-(void)setModeEditing:(BOOL)mode { editingMode = mode; }
-(void)addFriendToActivity:(NSString*)fId             { [pickedFriendsArray addObject:fId]; }
-(void)removeFriendFromActivity:(NSString*)fId        { [pickedFriendsArray removeObject:fId];}
-(void)addYoutubeToActivity:(NSDictionary*)fId        { [youtubeObjects addObject:fId];}
-(void)addYoutubeToRemove:(NSDictionary*)toRemove     { [youtubeObjectsToRemove addObject:toRemove]; }
-(void)restoreYoutubeFromRemove:(NSDictionary*)toRemove{ [youtubeObjectsToRemove removeObject:toRemove]; }
-(void)removeActivityInterest:(id)data                { [pickedActivityInterestsArray removeObject:data]; }
-(void)removeSocialImage:(id)object                   { [socialImagesArray removeObject:object]; }
-(void)removeImageFromAsset:(id)object                { [pickedImageFromAssets removeObject:object];}
-(void)savePickedPastFromAssets:(NSString*)path       { [pickedImageFromAssets addObject:path];}
-(void)addFacebookInterestToArray:(id)data            { [pickedFacebookArray addObject:data];}
-(void)removeFacebookInterest:(id)data                { [pickedFacebookArray removeObject:data]; }
-(void)selectActivity:(BOOL)selected                  { isActivitySelected = selected; }
-(void)removeLastImage                                { [pickedImagesArray removeLastObject]; }
-(void)addImagesToArray:(id)data                      { [pickedImagesArray addObject:data]; }
-(void)addSocialImagePath:(NSString *)path            { [socialImagesArray addObject:path]; }
-(void)removeSocialByPath:(NSString*)path             { [socialImagesArray removeObject:path];}
-(void)addImagesToTmpArray:(id)data                   { [pickedImagesArray addObject:data];}
-(void)setChatDataDictionary:(NSMutableArray *)dictionary{ chatDataDictionary = dictionary;}
-(void)setImageForChat:(UIImage *)image               {  imageForChat = image; }
-(void)setChatMode:(BOOL)mode                         {  chatMode = mode; }
-(void)setNewAddedInrerestID:(NSString *)mode         {  newAddedInrerestID = mode;}
-(void)setneedReloadMainScreen:(BOOL)mode             {  needReloadMainScreen = mode;}
-(void)setDoneEditing:(BOOL)mode                      {  doneEditing = mode;}
-(void)setEditProfeleSelectedInterests:(NSMutableArray *)array{ editProfeleSelectedInterests = array; }
-(void)editProfileStachArrayAddObj:(id)obg{[editProfileStachArray addObject:obg];}
-(void)setEditProfileStachArray:(NSMutableArray *)array{editProfileStachArray = array;}
-(NSArray *)socialImagesPaths                         { return socialImagesArray;}
-(NSArray*)getImagePathFromAssets                     { return pickedImageFromAssets; }
-(NSArray*)youtubeObjectsToRemoveO                    { return youtubeObjectsToRemove; }
-(NSArray*)pickedInterests                            { return pickedInterestsArray; }
-(NSArray*)storedActivities                           { return activitiesArray;    }
-(NSArray*)deleteImagesWithIndexes                    { return markedForDeletionImages; }
-(NSString *)editingActivityID                        { return editingAId;  }
-(NSString*)phoneNumber                               { return phoneNumber; }
-(NSString *)latitude                                 { return latitude;   }
-(NSString *)longitude                                { return longitude;  }
-(BOOL)editingMode                                    { return editingMode; }
-(BOOL)editProfileMode                                { return editProfileMode; }
-(BOOL)activitySelected                               { return isActivitySelected; }
-(BOOL)needReloadMainScreen                           { return needReloadMainScreen;}
-(BOOL)doneEditing                                    { return doneEditing;}
-(BOOL)chatMode                                       { return chatMode;}
-(UIImage*)interestImage                              { return currentABInterestImage;  }
-(NSDictionary *)ongoingActivity                      { return [dataDictionary copy]; }
-(NSDictionary*)editingActivityData                   { return editingActivityObject; }
-(NSDictionary *)getEditProfileDictiomary             { return editProfileDictiomary; }
-(ALAssetsLibrary *)getGallary                        { return  library; }
-(id)dataForKey:(NSString *)intKey                    { return [dataDictionary objectForKey:intKey]; }
-(void)updateEditingActivityData:(NSDictionary*)data{
    editingActivityObject = [[NSMutableDictionary alloc] initWithDictionary:data];
}
-(NSString *)newAddedInrerestID{return newAddedInrerestID;}
-(NSMutableArray *)youtubeObjects{return youtubeObjects;}
-(NSMutableArray *)editProfileStachArray{return editProfileStachArray;}
-(NSArray *)editProfeleSelectedInterests{ return editProfeleSelectedInterests; }
-(NSArray *)chatDataDictionary{ return chatDataDictionary; }
-(UIImage *)imageForChat{ return imageForChat; }

/*!******************************************/
-(id)init{
    
    self = [super init];
    if(self){
    
       
        dataDictionary = [[NSMutableDictionary alloc] init];
        editProfileDictiomary = [[NSMutableDictionary alloc] init];
        activitiesArray = [[NSMutableArray alloc] init];
        schedulerDates = [[NSMutableArray alloc] init];
        schedulerObject = [[NSMutableDictionary alloc] init];
        pickedImagesArray = [[NSMutableArray alloc] init];
        pickedInterestsArray = [[NSMutableArray alloc] init];
        pickedActivityInterestsArray = [[NSMutableArray alloc] init];
        pickedImageFromAssets = [[NSMutableArray alloc] init];
        socialImagesArray = [[NSMutableArray alloc] init];
        pickedFriendsArray = [[NSMutableArray alloc] init];
        markedForDelectionArray = [[NSMutableArray alloc] init];
        pickedFacebookArray = [[NSMutableArray alloc] init];
        youtubeObjects = [[NSMutableArray alloc] init];
        latitude = [NSString new];
        longitude = [NSString new];
        imageCache = [[NSCache alloc] init];
        library = [[ALAssetsLibrary alloc] init] ;
        chatDataDictionary = [[NSMutableArray alloc] init];
        editProfeleSelectedInterests = [[NSMutableArray alloc] init];
        editProfileStachArray = [[NSMutableArray alloc] init];
        markedForDeletionImages = [[NSMutableArray alloc] init];
        youtubeObjectsToRemove  = [[NSMutableArray alloc] init];
        editingActivityObject = [[NSMutableDictionary alloc] init];
        newAddedInrerestID = nil;
        
    }
    return self;
}

+(ABStoreManager *)sharedManager{
    
    static ABStoreManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        
    });

    return manager;
}
-(void)setActivityInterestImage:(UIImage*)image
{
   if(!currentABInterestImage){
       currentABInterestImage = [[UIImage alloc] init];
   }
    currentABInterestImage = image;

}


-(void)editProfileDictiomary:(NSDictionary *)dictionary{
    
    [editProfileDictiomary removeAllObjects];
    [editProfileDictiomary addEntriesFromDictionary:dictionary];
    
}

-(UIImage*)getABInterestImage {
    return currentABInterestImage;

}
-(void)setCoordinates:(NSString*)lat andLongitude:(NSString*)lng
{

    latitude = lat;
    longitude = lng;

}
-(NSString *)translateTypeIntoString:(SchedulerType)type
{

    if(type == kSTCustom)
        return [NSString stringWithFormat:@"Custom"];
    if(type == kSTOnce)
        return [NSString stringWithFormat:@"Once"];
    if(type == kSTMonthly)
        return [NSString stringWithFormat:@"Monthly"];
    if(type == kSTWeekEnds)
        return [NSString stringWithFormat:@"Weekends"];
    if(type == kSTEveryDay)
        return [NSString stringWithFormat:@"Everyday"];
   
    return @"";
    
}
-(void)prepareToSendRequest
{
    [self addImagesToActivity];
    if(latitude.length>0 && longitude.length>0)
    {
        if(editingMode)
        {
        
            [editingActivityObject setObject:latitude forKey:@"lat"];
            [editingActivityObject setObject:longitude forKey:@"lng"];
            [editingActivityObject setObject:[[UserDataManager sharedManager] serverToken] forKey:kServerApiToken];
            
                
        }
        else
        {
            [dataDictionary setObject:latitude forKey:@"lat"];
            [dataDictionary setObject:longitude forKey:@"lng"];
            [dataDictionary setObject:[[UserDataManager sharedManager] serverToken] forKey:kServerApiToken];
        }
        
    }
    
   
    
    
}

-(void)markForDeletionNewaddedImages:(NSString*)fId
{
    if(markedForDeletionImages==nil)
        markedForDeletionImages = [NSMutableArray new];
    
    [markedForDeletionImages addObject:fId];
    
}
-(void)unmarkForDeletionNewaddedImages:(NSString*)fId
{

        [markedForDeletionImages removeObject:fId];
    
}
-(void)markForDeletion:(NSString*)fId
{
    
    [markedForDelectionArray addObject:fId];
    [editingActivityObject setObject:markedForDelectionArray forKey:@"toRemoveActivityImgIds"];
    [dataDictionary setObject:markedForDelectionArray forKey:@"toRemoveActivityImgIds"];
    
    
}
-(void)unmarkForDeletion:(NSString*)fId
{
    
    [markedForDelectionArray removeObject:fId];
    [editingActivityObject setObject:markedForDelectionArray forKey:@"toRemoveActivityImgIds"];
    [dataDictionary setObject:markedForDelectionArray forKey:@"toRemoveActivityImgIds"];
}
-(void)removeVideoFromActivity
{
    if(youtubeObjectsToRemove.count>0)
    {
        for(int i=0;i<youtubeObjects.count;i++)
        {
            if([youtubeObjects[i][@"img"] isEqualToString:youtubeObjectsToRemove[i][@"img"]])
            {
               [youtubeObjects removeObjectAtIndex:i];
                NSLog(@"Video deleted");
            }
            
        }
    }
    
}
-(void)saveYoutubes
{

    if(editingMode)
    {
        
        [editingActivityObject setObject:youtubeObjects.count?youtubeObjects:[NSArray array] forKey:@"videos"];
        
    }
    else
    {
        
        [dataDictionary setObject:youtubeObjects.count?youtubeObjects:[NSArray array] forKey:@"videos"];
        
    }

}
-(void)saveInterest
{
    
    if(editingMode)
    {
    
        [editingActivityObject setObject:pickedInterestsArray.count?pickedInterestsArray:[NSArray array] forKey:vInterests];
        
    }
    else
    {
        
        [dataDictionary setObject:pickedInterestsArray.count?pickedInterestsArray:[NSArray array] forKey:vInterests];
    
    }
}
-(void)saveFacebookInterests
{

    
        [dataDictionary setObject:pickedFacebookArray forKey:@"spectatorFbInterests"];
        [dataDictionary setObject:pickedFacebookArray forKey:@"activityFbInterests"];
   

}
-(void)addInterestToActivity:(NSArray*)income
{

    [editingActivityObject setObject:income forKey:@"interests"];
    

}
-(void)saveActivityInterest
{
    if(editingMode)
    {
        
        [editingActivityObject setObject:pickedActivityInterestsArray.count?pickedActivityInterestsArray:[NSArray array] forKey:@"interestActivity"];
    }
    else
    {
        [dataDictionary setObject:pickedActivityInterestsArray.count?pickedActivityInterestsArray:[NSArray array] forKey:@"interestActivity"];
        
    }
}
-(void)addData:(id)data forKey:(NSString *)intKey
{
    if(editingMode)
    {
        [editingActivityObject setObject:data forKey:intKey];
    }
    else
    {
        [dataDictionary setObject:data forKey:intKey];
    }

}
-(void)addActivityInterestToArrayEditProfile:(NSArray *)data{
    
   [pickedActivityInterestsArray removeAllObjects];
   [pickedActivityInterestsArray addObjectsFromArray:data];
}
-(void)addActivityInterestToArray:(id)data
{
    if([data isKindOfClass:[NSArray class]])
    {
        [pickedActivityInterestsArray removeAllObjects];
        NSArray *a = [NSArray arrayWithArray:(NSArray*)data];
        for(int i=0;i<a.count;i++)
        {
            [pickedActivityInterestsArray addObject:a[i]];
        }
        [pickedActivityInterestsArray arrayByAddingObjectsFromArray:a];
        [dataDictionary setObject:pickedActivityInterestsArray forKey:@"interestActivity"];
    }
    else
    {
    
        [pickedActivityInterestsArray addObject:data];
    
    }
    
}
-(BOOL)isInterestsSelected
{

    if(pickedActivityInterestsArray.count>0 || pickedInterestsArray.count>0)
    {
    
        return YES;
    
    }
    
    return NO;
}

-(void)addInterestToArrayEditProfile:(NSArray*)data{

    [pickedInterestsArray removeAllObjects];
    [pickedInterestsArray addObjectsFromArray:data];

}
-(void)addInterestToArray:(id)data
{
    if(pickedInterestsArray==nil)
        pickedInterestsArray = [[NSMutableArray alloc] init];
    if([data isKindOfClass:[NSArray class]])
    {
        [pickedInterestsArray addObjectsFromArray:(NSArray*)data];
    }
    else
    {
        [pickedInterestsArray addObject:data];
    }
    
}
-(void)removeInterest:(id)data
{
    if(![data isKindOfClass:[NSDictionary class]])
    {
        NSMutableArray *tmp = [NSMutableArray new];
        
        for(id obj in pickedInterestsArray)
        {
           if(obj==data)
              [tmp addObject:obj];
         }
        [pickedInterestsArray removeObjectsInArray:tmp];
    }
    else
    {
        NSOrderedSet *mySet = [[NSOrderedSet alloc] initWithArray:pickedInterestsArray];
        [pickedInterestsArray removeAllObjects];
        pickedInterestsArray = [[NSMutableArray alloc] initWithArray:[mySet array]];
        [pickedInterestsArray removeObject:data];
    }
    
    
}
-(void)removeImagePhisicallyAtIndex:(int)index
{
    index!=0?index--:index;
    if(pickedImagesArray.count>0)
      [pickedImagesArray removeObjectAtIndex:index];
    
}
-(UIImage*)facebookPicture
{

    if(pickedImagesArray.count>0)
    {
    NSData *data = [[NSData alloc] initWithData:[NSData
                                                 dataFromBase64String:[pickedImagesArray objectAtIndex:0]]];
    
    return [UIImage imageWithData:data];
    }
    
    return nil;

}
-(void)saveScheduledData
{
    
   
     [schedulerDates addObject:[schedulerObject copy]];
    
    if(editingMode == YES)
    {
        NSMutableArray *tmpSchedl = [NSMutableArray new];
        [tmpSchedl addObjectsFromArray:[[ABStoreManager sharedManager] editingActivityData][@"scheduler"]];
        [tmpSchedl addObject:[schedulerObject copy]];
        [editingActivityObject setObject:tmpSchedl forKey:@"scheduler"];
        
    }
    
    [schedulerObject removeAllObjects];
}
-(void)addImagesToActivity
{
    if(editingMode)
    {
    
        [editingActivityObject setObject:pickedImagesArray forKey:vPicturesArray];
    
    }
    else
    {
      [dataDictionary setObject:pickedImagesArray forKey:vPicturesArray];
    }

}
-(void)saveFriends
{

    if(editingMode)
    {
        
        [editingActivityObject setObject:pickedFriendsArray forKey:@"activityFriends"];
        
        
    }
    else
    {
        [dataDictionary setObject:pickedFriendsArray forKey:@"activityFriends"];
        
    }

}
-(void)saveThisActivity
{
   
        
    [dataDictionary setObject:schedulerDates forKey:vScheduler];
    if(pickedFriendsArray.count>0)
    {
       if(editingMode)
       {
       
           [editingActivityObject setObject:pickedFriendsArray forKey:@"activityFriends"];
           
       
       }
        else
        {
           [dataDictionary setObject:pickedFriendsArray forKey:@"activityFriends"];
           
        }
        
    }
    if(editingMode && markedForDelectionArray.count>0)
    {
    
        
        [editingActivityObject setObject:markedForDelectionArray forKey:@"toRemoveActivityImgIds"];
        [dataDictionary setObject:markedForDelectionArray forKey:@"toRemoveActivityImgIds"];
    
    }
    
}
-(void)flushData
{
    [dataDictionary removeAllObjects];
    [schedulerDates removeAllObjects];
    [schedulerObject removeAllObjects];
    [socialImagesArray removeAllObjects];
    [pickedImagesArray removeAllObjects];
    [pickedInterestsArray removeAllObjects];
    [pickedActivityInterestsArray removeAllObjects];
    [editingActivityObject removeAllObjects];
    [pickedFriendsArray removeAllObjects];
    [pickedImageFromAssets removeAllObjects];
    [self setActivityInterestImage:nil];
    [youtubeObjects removeAllObjects];
    pickedInterestsArray = nil;
    [markedForDeletionImages removeAllObjects];
    [youtubeObjectsToRemove removeAllObjects];
   
   
}
-(void)storePhoneNumber:(NSString*)number
{
    
    phoneNumber = [[NSString alloc] init];
    phoneNumber = number;
    
}
@end
