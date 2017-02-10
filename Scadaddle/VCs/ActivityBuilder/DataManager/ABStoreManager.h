//
//  ABStoreManager.h
//  ActivityStoreManager
//
//  Created by Roman Bigun on 5/9/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define vDaysArray @"customDays"
#define vTitle @"title"
#define vDescription @"description"
#define vRewardInformation @"rewardInformation"
#define vPicturesArray @"imagesArray"
#define vNumberOfPlaces @"placesCount"
#define vSchedulerType @"schedulerType"
#define vScheduledDate @"date"
#define vScheduledTime @"time"
#define vInterest @"interest"
#define vFriends @"friends"
#define vInterests @"interests"
#define vLocation @"location"
#define vScheduler @"scheduler"
#define vPicturesIndexes @"imagesIndexes"
#define vShareLink @"ShareLink"
#import "AssetsLibrary/AssetsLibrary.h"
#import "emsAPIHelper.h"
/* Commented for future use
typedef NS_ENUM(NSUInteger, DictionaryKey)
{

    kDKDaysArray=0,
    kDKTitle,
    kDKDescription,
    kDKRewardInformation,
    kDKPicturesArray,
    kDKNumberOfPlaces,
    kDKSchedulerType,
    kDKScheduledDate,
    kDKScheduledTime,
    kDKInterest,
    kDKAddedFriends,
    kDKInterests,
    kDKLocation,
    kDKScheduler,
    kDKImagesIndexes

};
 */


typedef NS_ENUM(NSUInteger, SchedulerType)
{
    kSTOnce = 100,
    kSTEveryDay,
    kSTMonthly,
    kSTWeekEnds,
    kSTCustom
    
};
typedef NS_ENUM(NSUInteger, PagesIdentities)
{
   kPIMainScreen,
   kPIActivityesScreen,
   kPIProfileScreen,
   kPIActivityScreen
};

@interface ABStoreManager : NSObject
{
    ALAssetsLibrary *library ;
    BOOL isActivitySelected;
    NSString *phoneNumber;
}
@property(nonatomic,retain) NSCache *imageCache;;
@property(nonatomic,retain)NSMutableDictionary *editingActivityObject;

/*!
 * Singltone
 */
+(ABStoreManager *)sharedManager;
/*!
 * @discussion  Add data to current object
 */
-(void)addData:(id)data forKey:(NSString*)intKey;
-(void)testStrKey:(NSString*)intTey;
-(NSArray*)storedActivities;
/*!
 * @discussion   Get activity data which is being created
 */
-(NSDictionary *)ongoingActivity;
/*!
 * @discussion   Save new created activity in the server
 */
-(void)saveThisActivity;
/*!
 * @discussion  Remove all data related to current activity [Which is being created]
 *
 */
-(void)flushData;
-(id)dataForKey:(NSString*)intKey;
/*!
 * @discussion   Translates UIInteger type into string so the type could be readable
 */
-(NSString *)translateTypeIntoString:(SchedulerType)type;
/*!
 * @discussion   Adds data to current scheduler data for an appropriate key
 */
-(void)addDateToScheduler:(id)data forKey:(NSString*)intKey;
/*!
 * @discussion  Saving scheduler and input its data to activity which is being
 * created\edited
 */
-(void)saveScheduledData;
/*!
 * @discussion   Add activity images to single array
 */
-(void)addImagesToArray:(id)data;
/*!
 * @discussion  Adding interest to single array
 * @note that interests added one by one in For statement
 */
-(void)addInterestToArray:(id)data;
/*!
 * @discussion Adding interest to single array [EditProfile mode]
 */
-(void)addInterestToArrayEditProfile:(NSArray*)data;
/*!
 * @discussion  Remove interest with data
 * @param data interests data to remove
 */
-(void)removeInterest:(id)data;
/*!
 * Adding some additional data before sending it to server
 */
-(void)prepareToSendRequest;
/*!
 * @discussion  When user done with adding images they are added to the current
 * activity
 */
-(void)addImagesToActivity;
/*!
 * @discussion  Add selected interests to activity
 */
-(void)addInterestsToActivity;
/*!
 * @discussion  Add selected interests to activity [Edit Mode]
 * @param income interests comes from server and uses during
 * editing Activity
 */
-(void)addInterestToActivity:(NSArray*)income;
/*!
 * @discussion  Saves images stored in the Bundle
 */
-(void)savePickedPastFromAssets:(NSString*)path;
/*!
 * @discussion  Get images from Bundle
 */
-(NSArray*)getImagePathFromAssets;
/*!
 * @discussion  Set Latitude/Longitude for activity
 */
-(void)setCoordinates:(NSString*)lat andLongitude:(NSString*)lng;
/*!
 * @discussion  Remember activity interest
 */
-(void)saveInterest;
/*!
 * Remember selected activity interest
 */
-(BOOL)activitySelected;
/*!
 * Set select state to activity
 */
-(void)selectActivity:(BOOL)selected;
/*!
 * @discussion  Get facebook avatar
 */
-(UIImage*)facebookPicture;
/*!
 * @discussion  If user want to get image from any social, he would use this
 * function to store its path
 */
-(void)addSocialImagePath:(NSString *)path;
/*!
 * @discussion  Get Images Paths stored from social networks
 */
-(NSArray *)socialImagesPaths;
/*!
 * @discussion  Getter for chosen interests
 */
-(NSArray*)pickedInterests;
/*!
 - Get main interest Images
 */
-(UIImage*)getABInterestImage;
/*!
 * @discussion  Load interest image into an appropriate UIImageView
 */
-(void)setActivityInterestImage:(UIImage*)image;
/*!
 * @discussion to remove single interest from Activity object
 * @param data interest to remove
 */
-(void)removeActivityInterest:(id)data;
/*!
 * @discussion to add interest to temporary array
 * @param data interest to add
 * @uses when user select/deselect interest on the emsInterestVC
 */
-(void)addActivityInterestToArray:(id)data;
/*!
 * @discussion to add interest to temporary array
 * @param data interest to add
 * @uses when user select/deselect interest on the emsInterestVC
 * @note that it is used only in EditProfile mode
 */
-(void)addActivityInterestToArrayEditProfile:(NSArray *)data;
/*!
 * @discussion  to insert interests data to Activity which 
 * is currently being created
 */
-(void)saveActivityInterest;
/*!
 * @discussion  Send new data to server for Edited Activity
 */
-(void)updateEditingActivityData:(NSDictionary*)data;
/*!
 *@discussion   Data for activity which is currently being edited
 */
-(NSDictionary*)editingActivityData;
/*!
 * @discussion   Setter for activity ID which is currently being edited
 */
-(void)settleEditingActivityID:(NSString*)aId;
/*!
 * @discussion  Getter for activity ID which is currently being edited
 */
-(NSString *)editingActivityID;
/*!
 * @discussion  Setter for worker mode
 */
-(void)setModeEditing:(BOOL)mode;
/*!
 * @discussion  Getter for worker mode
 */
-(BOOL)editingMode;
/*!
 * @discussion  Adding chosen friend to current activity
 */
-(void)addFriendToActivity:(NSString*)fId;
/*!
 * @discussion  Remove friend from current activity
 */
-(void)removeFriendFromActivity:(NSString*)fId;
/*!
 * @discussion  Mark media for deletion
 */
-(void)markForDeletion:(NSString*)fId;
/*!
 * @discussion  Get data for user profile from server for editing
 * @see EditProfile class
 */
-(NSDictionary *)getEditProfileDictiomary;
/*!
 * @discussion  Unmark media from deletion
 */
-(void)unmarkForDeletion:(NSString*)fId;
-(void)editProfileDictiomary:(NSDictionary *)dictionary;
/*!
 * @discussion  Store in tmp Phone number after verification
 */
-(void)storePhoneNumber:(NSString*)number;
/*!
 * @discussion  Getter for phone number stored for future using
 */
-(NSString*)phoneNumber;
/*!
 * @discussion  to return library object
 * @note it returns created and allocated object but without any useful data
 */
-(ALAssetsLibrary *)getGallary;
/*!
 * @discussion  Remove image which wont be used.
 * @see PictureManager controller
 */
-(void)removeLastImage;
/*!
 * @discussion  if mode is edit profile mode returns YES
 */
-(BOOL)editProfileMode;
/*!
 * @discussion  Set 'edit mode' for profile
 */
-(void)setEditProfileMode:(BOOL)mode;
/*!
 * @discussion  Set 'edit mode' for chat
 */
-(void)setChatMode:(BOOL)mode;
/*!
 * @discussion  if mode is chat mode returns YES
 */
-(BOOL)chatMode;
/*!
 * @discussion  to get current latitude stored recently
 * @return latitude
 */
-(NSString *)latitude;
/*!
 * @discussion  to get current longitude stored recently
 * @return longitude
 */
-(NSString *)longitude;
/*!*******************************************************
                    ---- chat ----                      */
-(void)setImageForChat:(UIImage *)image;
/*!
 * Getter Chat image
 */
-(UIImage *)imageForChat;
/**
 * Store in tmp ChatVC data
 */
-(void)setChatDataDictionary:(NSMutableArray *)dictionary;
/**
 * Getter / Setter for Chat Data Dictionary
 *
 */
-(NSMutableArray *)chatDataDictionary;
/*!******************************************************/
/*!
 * @discussion  Add selected facebook interest [tmp data]
 */
-(void)addFacebookInterestToArray:(id)data;
/*!
 * @discussion  Remove selected facebook interest [tmp data]
 */
-(void)removeFacebookInterest:(id)data;
/*!
 * @discussion  Insert facebook interests into Activity data
 */
-(void)saveFacebookInterests;
/*!
 * @discussion  check if user selected at least one interest
 * And not important if user use Interests screen during 
 * Registration or Activity creation process
 * @warning At least one interest must be selected.
 */
-(BOOL)isInterestsSelected;
/*!
 * @discussion  set selected interests
 * @param array array of selected interests
 */
-(void)setEditProfeleSelectedInterests:(NSMutableArray *)array;
/*!
 * @discussion  get selected interests
 * @return the list of selected interests
 */
-(NSArray *)editProfeleSelectedInterests;
/*!
 * @discussion  Temporary array for edit Profile(GETTER)
 */
-(NSMutableArray *)editProfileStachArray;
/*!
 * @discussion Temporary array for edit Profile(SETTER)
 */
-(void)setEditProfileStachArray:(NSMutableArray *)array;
/*!
 * @discussion  Temporary array for edit Profile(ad one object)
 */
-(void)editProfileStachArrayAddObj:(id)obgl;
/*!
 * @discussion  If media is checked for deletion, remove it (Youtube files)
 */
-(void)removeSocialByPath:(NSString *)path;
/*!
 * @discussion  Insert selected Youtube videos into Activity data
 */
-(void)saveYoutubes;
/*!
 * @discussion  to remove stored video from activity which 
 *  is currently being created
 */
-(void)removeVideoFromActivity;
/*!
 * @discussion  add Youtube object to activity which is currently being created
 */
-(void)addYoutubeToActivity:(NSDictionary*)fId;
/*!
 * @discussion  use this function at the end of activity creation
 * So to be sure that if you open ActivityBuilder next time this 
 * flag is set to NO
 */
-(void)setDoneEditing:(BOOL)mode;
/*!
 * @discussion  to get bool value which will tell you whether ActivityBuilder 
 * in an Editing or Regular mode
 */
-(BOOL)doneEditing;
/*!
 * @discussion  Remove media stored locally by object type ->
 * @param 'object'
 */
-(void)removeImageFromAsset:(id)object;
/*!
 * @discussion  Remove image with object data ->
 * @param 'object'
 */
-(void)removeSocialImage:(id)object;
/*!
 * @discussion  Remove and forget
 */
-(void)removeImagePhisicallyAtIndex:(int)index;
/*!
 * @discussion  store this id into an array.
 * When we don't want to save cropped image we mark it as shouldBeDeleted
 * @see PictureManager class
 */
-(void)markForDeletionNewaddedImages:(NSString*)fId;
/*!
 * @discussion  restore image with this id which has been marked
 * for deletion in markForDeletionNewaddedImages method.
 * @see PictureManager class
 */
-(void)unmarkForDeletionNewaddedImages:(NSString*)fId;
/*!
 * @discussion  Remove images using its indexes in the images array
 */
-(NSArray*)deleteImagesWithIndexes;

/*!
 * @discussion  Getter for youtube media
 */
-(NSMutableArray *)youtubeObjects;
/*!
 * @discussion  Global interest image
 */
-(UIImage*)interestImage;
/*!
 * @discussion  Save Youtube media to remove at the end of Creation interest
 */
-(void)addYoutubeToRemove:(NSDictionary*)toRemove;
/*!
 * @discussion  Restore deleted (marked for deletion) Youtube medias
 * @param toRemove object to be removed
 */
-(void)restoreYoutubeFromRemove:(NSDictionary*)toRemove;

-(NSArray*)youtubeObjectsToRemoveO;
/*!
 * @discussion  When user did some actions to a 
 * user card/activity card etc. use this method to
 * tell main screen to reload
 */
-(void)setneedReloadMainScreen:(BOOL)model;
/*!
 * @discussion  get value stored in the setneedReloadMainScreen method
 */
-(BOOL)needReloadMainScreen;
/*!
 * @discussion  store interest ID which has been recently created
 * We use this ID when reload Interest Screen. We need to know 
 * which one was recently created so to check it
 */
-(void)setNewAddedInrerestID:(NSString *)mode;
/*!
 * @discussion  get interest ID stored in the setNewAddedInrerestID method
 */
-(NSString *)newAddedInrerestID;
 /*!
 * @discussion  Insert friends array into the currently created Activity
 */

-(void)saveFriends;
@end
