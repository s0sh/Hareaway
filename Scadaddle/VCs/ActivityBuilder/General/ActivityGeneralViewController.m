  //
//  ActivityGeneralViewController.m
//  ActivityCreator
//
//  Created by Roman Bigun on 5/6/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "ActivityGeneralViewController.h"
#import "ActivityView.h"
#import "Activity.h"
#import "HTTPClient.h"
#import "ABStoreManager.h"
#import "emsMainScreenVC.h"
#import "emsAPIHelper.h"
#import "MoodesViewController.h"
#import "UserDataManager.h"
#import "ABSchedulerViewController.h"
#import "MediaPickerViewController.h"
#import "FBHelper.h"
#import "ScadaddlePopup.h"
#import <Social/Social.h>
#import "emsGlobalLocationServer.h"
#import <AudioToolbox/AudioToolbox.h>
#import "emsScadProgress.h"

#define REWARD_SYMBOLS 100
#define DESCRIPTION_SYMBOLS 100
#define StringFromInteger(integer) [NSString stringWithFormat:@"%lu",integer]
@interface ActivityGeneralViewController ()
{

    BaseScroller * activityScroller;
    ALAssetsLibrary *library;
    NSMutableArray * allActivities;
    NSDictionary * currentActivityData;
    int currentActivityIndex;
    int descrSymbolsCounter;
    int titleSymbolsCounter;
    int rewardSymbolsCounter;
    int selectedInterestsId;
    ScadaddlePopup *popup;
    ActivityView *curObject;
    NSMutableDictionary *editingActivityData;
    NSMutableArray *editingActivityImagesIDs;
    int indexPrimary;
    NSMutableArray *videoIndexes;
    emsScadProgress * subView;
    
}
@property(getter=isEditMode,setter=setEditMode:)BOOL editMode;
@end

@implementation ActivityGeneralViewController


/*!
 * @discussion  Custom Progress bar with blur background and Scadaddle
 Animation
 */
-(void)progress:(void (^)())callback;{
    
    if (subView == nil) {
        subView = [[emsScadProgress alloc] initWithFrame:self.view.frame screenView:self.view andSize:CGSizeMake(320, 580)];
        [self.view addSubview:subView];
        subView.alpha = 0;
        
        [UIView animateWithDuration:0.5 animations:^{
            subView.alpha = 1;
        } completion:^(BOOL finished) {
            callback();
        }];
        
    }
}
/*!
 * @discussion Stop progress
 */
-(void)stopSubview{
    
    [UIView animateWithDuration:0.5 animations:^{
        subView.alpha = 0;
    } completion:^(BOOL finished) {
        [subView removeFromSuperview];
        subView = nil;
    }];
}

-(void)hidePictureManager:(BOOL)hide
{
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.activityImageManBlackBackground.alpha = hide?0:0.75f;
                         self.activityImageManClearBackground.alpha = hide?0:1;
                         
                     }];
    
    
    
}
-(IBAction)hideImage
{

    [self hidePictureManager:YES];
    

}
/*!
 * @discussion to remove image by path from the device
 * @param path absolute path to an image
 */
-(void)deleteFileAtPath:(NSString *)path
{
    //Doesn't work

    NSFileManager *fileManager = [NSFileManager new];
    NSError *error;
    BOOL fileExists = [fileManager fileExistsAtPath:path];
    NSLog(@"Path to file: %@", path);
    NSLog(@"File exists: %d", fileExists);
    NSLog(@"Is deletable file at path: %d", [fileManager isDeletableFileAtPath:path]);
    if (fileExists)
    {
        BOOL success = [fileManager removeItemAtPath:path error:&error];
        if (!success) NSLog(@"Error: %@", [error localizedDescription]);
    }

}
/*!
 * @discussion Mark Image for delete at the end of creating activity
 */
-(IBAction)deleteActivityImage
{
    
    [self hidePictureManager:YES];
    int cIndex = [curObject index];
    int allIndexes=0;
   
    if([[curObject curId] isEqualToString:@"-1"])
    {
        for(int i=0;i<allActivities.count;i++){
            if(![allActivities[i] containsString:@"asset"] && ![allActivities[i] containsString:@"photo_bg_small"]
               && ![allActivities[i] containsString:@"i.ytimg.com"])
            {
                allIndexes++;
             }
        }
        
        [[ABStoreManager sharedManager] markForDeletionNewaddedImages:[NSString stringWithFormat:@"%d",cIndex-allIndexes]];
        for(int i=0;i<[[ABStoreManager sharedManager] youtubeObjects].count;i++){
            if([[[ABStoreManager sharedManager] youtubeObjects][i][@"img"] isEqualToString:[curObject gName]]){
                [[ABStoreManager sharedManager] addYoutubeToRemove:[[ABStoreManager sharedManager] youtubeObjects][i]];
            }
        }
        [curObject markDeleted];
    }else{
        [curObject markDeleted];
    }
    
   
}
/*!
 * @discussion Make Choosen image as a main Activity image
 * @note it will be first image in images array
 */
-(IBAction)makeMainActivityImage
{
    [self makeMain];
}
-(void)makeMain
{
    [curObject makeMain];
    [self hidePictureManager:YES];
}

-(void)setIndents:(UITextField*)textfield
{
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [textfield setLeftViewMode:UITextFieldViewModeAlways];
    [textfield setLeftView:spacerView];
}
-(void)dismissKeyboard
{
    [self.numberOfPlacesTextField resignFirstResponder];
    
}
/*!
 * @discussion Init and setup UI elements according to Data
 * @note that it could have two modes ModeCreate/ModeEdit
 */
-(void)setupUIElements
{

    selectedInterestsId = -1;
    currentActivityIndex = 0;
    
    self.descriptionSymbolsLbl.text = StringFromInteger(descrSymbolsCounter);
    [self setIndents:self.descriptionTextField];
    [self setIndents:self.rewardInfoTextField];
    [self setIndents:self.titleTextField];
    [self setIndents:self.numberOfPlacesTextField];
    self.rewardSymbolsLbl.text = StringFromInteger(rewardSymbolsCounter);
    [HTTPClient sharedInstance];
    activityScroller = [[BaseScroller alloc] initWithFrame:CGRectMake(5.f, 75.f, 250, 55.f)];
    activityScroller.delegate = self;
    [self.mainScroll insertSubview:activityScroller atIndex:0];
    self.titleTextField.delegate = self;
    self.descriptionTextField.delegate = self;
    self.rewardInfoTextField.delegate = self;
    self.numberOfPlacesTextField.delegate = self;
    [self.mainScroll setContentSize:CGSizeMake(self.mainScroll.frame.size.width, self.mainScroll.frame.size.height)];
    
    #pragma mark Заполнить информационные поля в случае Создания активности (если создание еще не закончено) но не для редактирования
    //Activity Creating
    
    if([[ABStoreManager sharedManager] ongoingActivity].count>0 && !self.editMode)
    {
        
        self.descriptionTextField.text = [[ABStoreManager sharedManager] ongoingActivity][vDescription];
        self.titleTextField.text = [[ABStoreManager sharedManager] ongoingActivity][vTitle];
        self.rewardInfoTextField.text = [[ABStoreManager sharedManager] ongoingActivity][vRewardInformation];
        self.numberOfPlacesTextField.text =  [[ABStoreManager sharedManager] ongoingActivity][vNumberOfPlaces];
        self.rewardSymbolsLbl.text = StringFromInteger(REWARD_SYMBOLS-self.rewardInfoTextField.text.length);
        self.descriptionSymbolsLbl.text = StringFromInteger(REWARD_SYMBOLS-self.descriptionTextField.text.length);
        if([[ABStoreManager sharedManager] ongoingActivity][@"primaryInterestsImg"]!=nil)
        {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MLDownloadImageNotification"
                                                            object:self
                                                          userInfo:@{@"activityUrl":[[ABStoreManager sharedManager] ongoingActivity][@"primaryInterestsImg"]}];
        }
    }
    #pragma mark Берем информацию об активности с сервера и заполняем соответствующие поля и данные
    //Editing Activity
    //Fill View/Controls with data witch has been got from the server
    
    else if(_editMode)
    {
        if([[[ABStoreManager sharedManager] editingActivityData] count]==0)
        {
            [[ABStoreManager sharedManager] updateEditingActivityData:[Server activityDataForID:[[ABStoreManager sharedManager]  editingActivityID]
                                                                                            lat:[[emsGlobalLocationServer sharedInstance] latitude]
                                                                                      andLong:[[emsGlobalLocationServer sharedInstance] longitude]]
                                                                                      [@"activities"]];
            self.descriptionTextField.text = [[ABStoreManager sharedManager] editingActivityData][vDescription];
            self.titleTextField.text = [[ABStoreManager sharedManager] editingActivityData][@"activityTitle"];
            self.rewardInfoTextField.text = [[ABStoreManager sharedManager] editingActivityData][vRewardInformation];
            self.numberOfPlacesTextField.text =  [NSString stringWithFormat:@"%@",[[ABStoreManager sharedManager] editingActivityData][vNumberOfPlaces]];
            self.rewardSymbolsLbl.text = StringFromInteger(REWARD_SYMBOLS-self.rewardInfoTextField.text.length);
            self.descriptionSymbolsLbl.text = StringFromInteger(REWARD_SYMBOLS-self.descriptionTextField.text.length);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MLDownloadImageNotification"
                                                                object:self
                                                              userInfo:@{@"activityUrl":[[ABStoreManager sharedManager] editingActivityData][@"primaryInterestsImg"]}];
        }
        else {
        self.descriptionTextField.text = [[ABStoreManager sharedManager] editingActivityData][vDescription];
        self.titleTextField.text = [[ABStoreManager sharedManager] editingActivityData][@"title"];
        self.rewardInfoTextField.text = [[ABStoreManager sharedManager] editingActivityData][vRewardInformation];
        self.numberOfPlacesTextField.text =  [NSString stringWithFormat:@"%@",[[ABStoreManager sharedManager] editingActivityData][vNumberOfPlaces]];
        self.rewardSymbolsLbl.text = StringFromInteger(REWARD_SYMBOLS-self.rewardInfoTextField.text.length);
        self.descriptionSymbolsLbl.text = StringFromInteger(REWARD_SYMBOLS-self.descriptionTextField.text.length);
            
            
        }
        
    }
        editingActivityImagesIDs = [[NSMutableArray alloc] init];
   
  
}

/*!
 * @discussion Load Activity Images into array
 */
-(void)initActivities
{
    
       allActivities = [NSMutableArray new];
       videoIndexes = [NSMutableArray new];
    
        if(_editMode)
        {
            
            for(int i=0;i<[[[ABStoreManager sharedManager] editingActivityData][@"activitiesImages"] count];i++){
                [allActivities addObject:[NSString stringWithFormat:@"%@%@",SERVER_PATH,[[ABStoreManager sharedManager] editingActivityData][@"activitiesImages"][i][@"path884x454"]]];
                [editingActivityImagesIDs addObject:[[ABStoreManager sharedManager] editingActivityData][@"activitiesImages"][i][@"id"]];
                if([[[ABStoreManager sharedManager] editingActivityData][@"activitiesImages"][i][@"type"] isEqualToString:@"video"]){
                    [videoIndexes addObject:[NSString stringWithFormat:@"%i",i]];
                }
                if((int)[[ABStoreManager sharedManager] editingActivityData][@"activitiesImages"][i][@"is_primary"] == 1){
                    indexPrimary = i;
                }
                
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%lu",allActivities.count] forKey:@"startIndexForDeletion"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
        else
        {
        
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"0"] forKey:@"startIndexForDeletion"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        
        }

    
        if([[ABStoreManager sharedManager] getImagePathFromAssets].count>0){
            for(int j=0;j<[[ABStoreManager sharedManager] getImagePathFromAssets].count;j++){
                [allActivities addObject:[[[ABStoreManager sharedManager] getImagePathFromAssets] objectAtIndex:j]];
                
            }
            
        }
    
//    if([[ABStoreManager sharedManager] socialImagesPaths].count>0){
//        for(int j=0;j<[[ABStoreManager sharedManager] socialImagesPaths].count;j++){
//            [allActivities addObject:[[[ABStoreManager sharedManager] socialImagesPaths] objectAtIndex:j]];
//            if([[NSString stringWithFormat:@"%@",[allActivities lastObject]] containsString:@"i.ytimg.com"]){
//                [videoIndexes addObject:[NSString stringWithFormat:@"%lu",(unsigned long)allActivities.count-1]];
//            }
//            
//        }
//    
//    }
    
        for(int i=allActivities.count;i<4;i++){
            [allActivities addObject:@"photo_bg_small"];
        }
    
    [self stopSubview];
    
}

- (void)viewDidLoad {
    
    if([[ABStoreManager sharedManager] editingMode])
    {
    
        [self progress:^{
        
        }];
    
    }
    if(!library)
        library = [[ALAssetsLibrary alloc] init];
    ////[Flurry setDelegate:self];
    if([[ABStoreManager sharedManager] editingMode])
    {
    
       //[Flurry logEvent:@"ActivityBuilder[viewDidLoad] - EDIT"];
        
    }
    else
    {
    
        //[Flurry logEvent:@"ActivityBuilder[viewDidLoad] - NORMAL"];
    
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadActivities:) name:@"BLDeselectActivitiesNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activityImageManager:) name:@"ABActivityImageManager" object:nil];
    descrSymbolsCounter = DESCRIPTION_SYMBOLS;
    rewardSymbolsCounter = REWARD_SYMBOLS;
    titleSymbolsCounter = REWARD_SYMBOLS;
    [self hidePictureManager:YES];
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    
}
/*!
 * @discussion Restore deleted image and Make it Main [Only images not
 videos]
 */
-(void)restoreAndMain
{
    int cIndex = [curObject index];
    int allIndexes=0;
    if([[curObject curId] isEqualToString:@"-1"])
    {
        for(int i=0;i<allActivities.count;i++){
            if(![allActivities[i] containsString:@"asset"] && ![allActivities[i] containsString:@"photo_bg_small"] && ![allActivities[i] containsString:@"i.ytimg.com"]){
                allIndexes++;
            }
        }
    }
    [[ABStoreManager sharedManager] unmarkForDeletionNewaddedImages:[NSString stringWithFormat:@"%d",cIndex-allIndexes]];
    [curObject unmarkMe];
    if(![curObject isObjectVideo])
    {
       [curObject makeMain];
    }
    [self hidePictureManager:YES];
    
}
/*!
 * @discussion Restore deleted element Image or Video
 */
-(void)restore
{
    int cIndex = [curObject index];
    int allIndexes=0;
    if([[curObject curId] isEqualToString:@"-1"])
    {
        for(int i=0;i<allActivities.count;i++){
            if(![allActivities[i] containsString:@"asset"] && ![allActivities[i] containsString:@"photo_bg_small"] && ![allActivities[i] containsString:@"i.ytimg.com"]){
                allIndexes++;
            }
        }
    }
    [[ABStoreManager sharedManager] unmarkForDeletionNewaddedImages:[NSString stringWithFormat:@"%d",cIndex-allIndexes]];
    
    [curObject unmarkMe];
    [self hidePictureManager:YES];

}
/*!
 * @discussion Popup with prompt to Delete/Restore/MakeMain for images
 */
- (void)activityImageManager:(NSNotification *)notification {
    
    NSDictionary *dict = [notification userInfo];
    
    [self hidePictureManager:NO];
    if([dict[@"restore"] isEqualToString:@"1"])
    {
        
        self.makeMainImageBtn.alpha=1;
        [self.makeMainImageBtn setBackgroundImage:[UIImage imageNamed:@"restore_photo"] forState:UIControlStateNormal];
        [self.makeMainImageBtn removeTarget:self action:@selector(makeMainActivityImage) forControlEvents:UIControlEventTouchUpInside];
        [self.makeMainImageBtn addTarget:self action:@selector(restore) forControlEvents:UIControlEventTouchUpInside];
        
        if(![dict[@"video"] isEqualToString:@"1"])
        {
         self.deleteImageBtn.alpha=1;
         [self.deleteImageBtn removeTarget:self action:@selector(restore) forControlEvents:UIControlEventTouchUpInside];
         [self.deleteImageBtn setBackgroundImage:[UIImage imageNamed:@"make_main"] forState:UIControlStateNormal];
         [self.deleteImageBtn addTarget:self action:@selector(restoreAndMain) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
        
            self.deleteImageBtn.alpha=0;
        
        }
        
        
        
    }
    else
    {
    
        self.deleteImageBtn.alpha=1;
        if([dict[@"hideMain"] isEqualToString:@"1"])
        {
           self.makeMainImageBtn.alpha=0;
        }
        else
        {
        
            self.makeMainImageBtn.alpha=1;
        
        }
        [self.makeMainImageBtn removeTarget:self action:@selector(restore) forControlEvents:UIControlEventTouchUpInside];
        [self.makeMainImageBtn setBackgroundImage:[UIImage imageNamed:@"make_main"] forState:UIControlStateNormal];
        [self.makeMainImageBtn addTarget:self action:@selector(makeMainActivityImage) forControlEvents:UIControlEventTouchUpInside];
        
        [self.deleteImageBtn removeTarget:self action:@selector(restoreAndMain) forControlEvents:UIControlEventTouchUpInside];
        [self.deleteImageBtn setBackgroundImage:[UIImage imageNamed:@"delete_photo"] forState:UIControlStateNormal];
        [self.deleteImageBtn addTarget:self action:@selector(deleteActivityImage) forControlEvents:UIControlEventTouchUpInside];
    
    }
    if([dict[@"hideButtons"] isEqualToString:@"1"])
    {
        self.deleteImageBtn.alpha=0;
        self.makeMainImageBtn.alpha=0;
    }
    
    curObject = dict[@"object"];
    
    if([dict[@"path"] containsString:@"http"])
    {
    
        if(![self imageHandler:dict[@"path"]])
        {
            __block UIImage *image = [UIImage new];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:dict[@"path"]]];
                image  = [UIImage imageWithData:imageData];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if(image)
                        self.activityImageDisplayView.image = image;
                        [[[ABStoreManager sharedManager] imageCache] setObject:image forKey:dict[@"path"]];
                });
            });
        }
        else
        {
           self.activityImageDisplayView.image = [[[ABStoreManager sharedManager] imageCache] objectForKey:dict[@"path"]];
        
        }
        
    }
    else
    {
        
        
        if(![self imageHandler:dict[@"path"]])
        {
            NSURL *yourAssetUrl = [NSURL URLWithString:dict[@"path"]];
            [library assetForURL:yourAssetUrl resultBlock:^(ALAsset *asset) {
                if (asset) {
                    ALAssetRepresentation *imgRepresentation = [asset defaultRepresentation];
                    CGImageRef imgRef = [imgRepresentation fullScreenImage];
                    UIImage *img = [UIImage imageWithCGImage:imgRef];
                   
                    if(img)
                    {
                         self.activityImageDisplayView.image = img;
                         [[[ABStoreManager sharedManager] imageCache] setObject:img forKey:dict[@"path"]];
                    }
                    
                }
            } failureBlock:^(NSError *error) {
                NSLog(@"Error loading file %@",[error description]);
            }];
    }
    else
    {
        if([[[ABStoreManager sharedManager] imageCache] objectForKey:dict[@"path"]]!=nil)
            self.activityImageDisplayView.image = [[[ABStoreManager sharedManager] imageCache] objectForKey:dict[@"path"]];
    
    }
    }
    
    
   //self.activityImageDisplayView.image =dict[@"image"];
    
    
}
/*!
 * @discussion  check whether image with path cached or not.
 * If cached. add image to target else returns NO to start download
 * @param path absolute path to image
 */
-(BOOL)imageHandler:(NSString*)path
{
    if([[[ABStoreManager sharedManager] imageCache] objectForKey:path]!=nil)
    {
        return YES;
    }
    return NO;
}

/*!
 * @discussion Reload TOP scroller vith Activity images
 */
- (void)reloadActivities:(NSNotification *)notification {

    NSDictionary *dict = [notification userInfo];
    NSString *index = dict[@"exceptIndex"];
    int intIndex = [index intValue];
    NSArray *findScroller = [activityScroller subviews];
    for(UIView *tmp in findScroller)
    {
        if([tmp isKindOfClass:[UIScrollView class]])
        {
            NSArray *activities = [tmp subviews];
            for(UIView *act in activities)
            {
                if([act isKindOfClass:[ActivityView class]])
                {
                    
                    if([(ActivityView *)act index]!=intIndex && ![(ActivityView *)act markedForDeletion])
                    {
                        [(ActivityView *)act deselectMe];
                    }
                    
                }
                
            }
        }
        
    
    }
    
}
-(void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:YES];
    
    [self setEditMode:[[ABStoreManager sharedManager] editingMode]];
    [self setupUIElements];
    [self initActivities];
    [self reloadScroller];
   
}
#pragma mark TF delegates
- (BOOL)keyboardInputShouldDelete:(UITextField *)textField {
    BOOL shouldDelete = YES;
    
    if ([UITextField instancesRespondToSelector:_cmd]) {
        BOOL (*keyboardInputShouldDelete)(id, SEL, UITextField *) = (BOOL (*)(id, SEL, UITextField *))[UITextField instanceMethodForSelector:_cmd];
        
        if (keyboardInputShouldDelete) {
            shouldDelete = keyboardInputShouldDelete(self, _cmd, textField);
        }
    }
    
    BOOL isIos8 = ([[[UIDevice currentDevice] systemVersion] intValue] == 8);
    BOOL isLessThanIos8_3 = ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.3f);
    
    if (![textField.text length] && isIos8 && isLessThanIos8_3) {
    
    }
    
    return shouldDelete;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
   
    
    NSInteger textLength = 0;
    textLength = [textField.text length] + [string length] - range.length;
    if([[textField text] length] == 0 && [string isEqualToString:@" "])
    {
        return NO;
    }
    
    if(textField == self.descriptionTextField)
    {
        if(textField.text.length<=DESCRIPTION_SYMBOLS || [string isEqualToString:@""]){
            
                        self.descriptionSymbolsLbl.text = StringFromInteger(DESCRIPTION_SYMBOLS-textLength);
        }
        else{
            return NO;
        }
        
    }
    if(textField == self.rewardInfoTextField)
    {
        
        if(textField.text.length<=100 || [string isEqualToString:@""]){
          
            
            self.rewardSymbolsLbl.text = StringFromInteger(REWARD_SYMBOLS-textLength);
        }
        else{
            return NO;
        }
    }
    if(textField == self.titleTextField)
    {
        if([[textField text] length] > 30)
        {
            return NO;
        }
        
    }
    if(textField == self.numberOfPlacesTextField)
    {
        if(([[textField text] length] == 0 && [string isEqualToString:@"0"]))
        {
            if([string isEqualToString:@"0"])
                textField.text=@"1";
            return NO;
        }
        if([[textField text] length]>1 && ![string isEqualToString:@""])
        {
            [UIView animateWithDuration:0.5f animations:^{
                
                self.max99Lable.alpha = 1;
                
                
            } completion:^(BOOL finished) {
               
                [UIView animateWithDuration:1.0f animations:^{
                    
                    self.max99Lable.alpha = 0;
                    
                
            }];
           }];
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);//For fun
            return NO;
            
        }
        
    }
    return YES;
}
/*!
 * @discussion Save main activity interest (temporary)
 */
-(void)chooseInterest:(int)interestId
{

    selectedInterestsId = interestId;

}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [self scrolBack];
    [textField resignFirstResponder ];
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
   [self scrolToTextField:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    
    [textField resignFirstResponder];
    
    return YES;
}
-(void)scrolToTextField:(UITextField *)tf{
    
    
    [UIView animateWithDuration:0.4f animations:^{
        
        self.mainScroll.contentOffset = CGPointMake(self.mainScroll.contentOffset.x ,tf.frame.origin.y - 250);
        
    } completion:^(BOOL finished) {
        
    }];
    
}
-(void)scrolBack{
    
    
    [UIView animateWithDuration:0.4f animations:^{
        
        self.mainScroll.contentOffset = CGPointMake(self.mainScroll.contentOffset.x ,self.mainScroll.contentOffset.x);
        
    } completion:^(BOOL finished) {
        
    }];
    
}


-(void)scrollBack:(UITextField *)sender{
    
    [UIView animateWithDuration:0.4f animations:^{
        
        self.mainScroll.contentOffset = CGPointMake(self.mainScroll.contentOffset.x ,0);
        
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - HorizontalScrollerDelegate methods
- (void)showDataForActivityAtIndex:(int)albumIndex
{
    
    if (albumIndex < allActivities.count){
        currentActivityData = nil;
    }else{
        currentActivityData = nil;
    }
}
- (void)horizontalScroller:(BaseScroller *)scroller clickedViewAtIndex:(int)index
{
    index = index<allActivities.count?index:allActivities.count-1;
    currentActivityIndex = index;
    [self showDataForActivityAtIndex:index];
    
}
- (NSInteger)numberOfViewsForHorizontalScroller:(BaseScroller *)scroller{
    return allActivities.count;
}
- (UIView *)horizontalScroller:(BaseScroller *)scroller viewAtIndex:(int)index{
    BOOL isVideo = NO;
    if(videoIndexes.count>0)
    {
        for(int i=0;i<videoIndexes.count;i++){
            if([[NSString stringWithFormat:@"%@",videoIndexes[i]] isEqualToString:[NSString stringWithFormat:@"%i",index]])
                isVideo=YES;
        }
    }
    if([[ABStoreManager sharedManager] editingMode]){
        return [[ActivityView alloc] initWithFrame:CGRectMake(0.f, 0.f,60 , 55) activityImage:allActivities[index]
                                          andIndex:index
                                             andId:editingActivityImagesIDs.count>index?editingActivityImagesIDs[index]:@"-1" mediaTypeVideo:isVideo];
        
    }
    return [[ActivityView alloc] initWithFrame:CGRectMake(0.f, 0.f,60 , 55) activityImage:allActivities[index] andIndex:index andId:allActivities[index] mediaTypeVideo:isVideo];
}
-(NSArray*)getActivities{
    return allActivities;
    
}
- (void)reloadScroller
{
    
    if (currentActivityIndex < 0)
        currentActivityIndex = 0;
    else if (currentActivityIndex >= allActivities.count)
        currentActivityIndex = allActivities.count - 1;
    [activityScroller reload];
   
}
-(BOOL) isEmptyString : (NSString *)string
{
    if([string length] == 0 || [string isKindOfClass:[NSNull class]] ||
       [string isEqualToString:@""]||[string  isEqualToString:NULL]  ||
       string == nil)
    {
        return YES;
    }
    return NO;
}
-(void)fillAllFieldsAlert
{
    
    [self messagePopupWithTitle:@"Fill all fields, please!\n [Reward information is optional]" hideOkButton:NO];
 
}
/*!
 * @discussion
 * OPTION 1
 * Check data stored and Save current data to ABStoreManager
 * so to use it at the end of Activity creation (send to server/DB)
 */
-(void)saveTmpData
{

    [self.numberOfPlacesTextField resignFirstResponder];
    [self.titleTextField resignFirstResponder];
    [self.rewardInfoTextField resignFirstResponder];
    [self.descriptionTextField resignFirstResponder];
    
        
    if([self isEmptyString:self.descriptionTextField.text] || [self isEmptyString:self.titleTextField.text]){
        
        [self fillAllFieldsAlert];
        return;
       
    }
    else
    {
        if([[[ABStoreManager sharedManager] ongoingActivity][@"primaryInterest"] length]== 0 && ![[ABStoreManager sharedManager] editingMode])
        {
            [self messagePopupWithTitle:@"Please, add Primary Interest!" hideOkButton:NO];
            
            return;
        }
        if([[ABStoreManager sharedManager] ongoingActivity][@"primaryActivityImgIndex"]==nil && [[ABStoreManager sharedManager] ongoingActivity][@"primaryActivityImgIid"]==nil && ![[ABStoreManager sharedManager] editingMode])
        {
            [self messagePopupWithTitle:@"Add at least one image, please!" hideOkButton:NO];
            
            return;
        }
        
        
        
        if([[ABStoreManager sharedManager] getImagePathFromAssets].count>0 || [[ABStoreManager sharedManager] socialImagesPaths].count>0 || [[[ABStoreManager sharedManager] editingActivityData][@"activitiesImages"] count]>0)
        {
            
            [[ABStoreManager sharedManager] addData:self.descriptionTextField.text
                                             forKey:vDescription];
            [[ABStoreManager sharedManager] addData:self.titleTextField.text
                                             forKey:vTitle];
            [[ABStoreManager sharedManager] addData:
             [self isEmptyString:self.rewardInfoTextField.text]?@"":[NSString stringWithFormat:@"%@",self.rewardInfoTextField.text]
                                             forKey:vRewardInformation];
            
            [[ABStoreManager sharedManager] addData:allActivities forKey:vPicturesArray];
            [[ABStoreManager sharedManager] addData:self.numberOfPlacesTextField.text forKey:vNumberOfPlaces];
            [[ABStoreManager sharedManager] saveYoutubes];
            if(!_editMode && ![[[ABStoreManager sharedManager] ongoingActivity] objectForKey:@"firsttime"])
            {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ActivityBuilder_4" bundle:nil];
                ABSchedulerViewController *notebook = [storyboard instantiateViewControllerWithIdentifier:@"ABSchedulerViewController"];
                [self presentViewController:notebook animated:YES completion:^{
                    
                    [[ABStoreManager sharedManager] addData:[NSNumber numberWithBool:YES]
                                                     forKey:@"firsttime"];
                    
                }];
            }
            else
            {
                   
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ActivityBuilder_4" bundle:nil];
                ABSchedulerViewController *notebook = [storyboard instantiateViewControllerWithIdentifier:@"ScheduledEvents"];
                [self presentViewController:notebook animated:YES completion:^{
                    [[ABStoreManager sharedManager] addData:[NSNumber numberWithBool:YES]
                                                     forKey:@"firsttime"];
                }];
            
            
            }
            
        }
        else
        {
            [self messagePopupWithTitle:@"Add Activity/Event picture!" hideOkButton:NO];
           
            return;
        }
        
    }
    NSLog(@"Editing Data %@",[[ABStoreManager sharedManager] editingActivityObject]);

}
/*!
 * @discussion
 * OPTION 2
 * Check data stored and Save current data to ABStoreManager
 * so to use it at the end of Activity creation (send to server/DB)
 */
-(IBAction)tmpDataSaved
{
   
    if(allActivities.count<10)
    {
    [[ABStoreManager sharedManager] addData:self.descriptionTextField.text
                                     forKey:vDescription];
    [[ABStoreManager sharedManager] addData:self.titleTextField.text
                                     forKey:vTitle];
    [[ABStoreManager sharedManager] addData:
     [self isEmptyString:self.rewardInfoTextField.text]?@"":[NSString stringWithFormat:@"%@",self.rewardInfoTextField.text]
                                     forKey:vRewardInformation];
    [[ABStoreManager sharedManager] addData:
     self.numberOfPlacesTextField.text
                                     forKey:vNumberOfPlaces];
    [[ABStoreManager sharedManager] addData:allActivities forKey:vPicturesArray];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ActivityBuilder_4" bundle:nil];
    MediaPickerViewController *notebook = [storyboard instantiateViewControllerWithIdentifier:@"MediaPicker"];
    [self presentViewController:notebook animated:YES completion:^{
        
    }];
    
     NSLog(@"Editing Data %@",[[ABStoreManager sharedManager] editingActivityObject]);
    }
    else
    {
    
        [self messagePopupWithTitle:@"You cannot add more than 10 images!" hideOkButton:NO];
        return;
    }

}
-(IBAction)saveData:(UIButton*)sender
{
    
    [self saveTmpData];
    
}
-(IBAction)back{
    [[ABStoreManager sharedManager] flushData];//Remove all temporary data
    [[ABStoreManager sharedManager] setModeEditing:NO];
    [self presentViewController:[[emsMainScreenVC alloc] init] animated:YES completion:^{
        
    }];
}
/*!
 * @discussion to opens custom Popup with title
 * @param title desired message to display on popup
 * @param show YES/NO YES to display OK button
 */
-(void)messagePopupWithTitle:(NSString*)title hideOkButton:(BOOL)show
{
    
    popup = [[ScadaddlePopup alloc] initWithFrame:self.view.frame withTitle:title withProgress:NO andButtonsYesNo:NO forTarget:self andMessageType:-1];
    [popup hideDisplayButton:show];
    [self.view addSubview:popup];
    
}
/*!
 * @discussion to dismiss popup [slowly disappears]
 * @param title desired message to display on popup
 * @param duration time while disappearing
 * @param exit YES/NO YES to dismiss this controller
 */

-(void)dismissPopupActionWithTitle:(NSString*)title andDuration:(double)duration andExit:(BOOL)exit
{
    
    [popup updateTitleWithInfo:title];
    [UIView animateWithDuration:duration animations:^{
        
        popup.alpha=0.9;
    } completion:^(BOOL finished) {
        
        [popup removeFromSuperview];
        if(exit)
        {
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
        
    }];
    
    
}
/**
 * @discussion close popup
 */
-(IBAction)dismissPopup
{
    
    [self dismissPopupActionWithTitle:@"" andDuration:0 andExit:NO];
    
    
}


@end
