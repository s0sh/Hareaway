//
//  emsMainScreenVC.m
//  Scadaddle
//
//  Created by developer on 17/04/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsMainScreenVC.h"
#import "MainScreenCell.h"
#import "User.h"
#import "emsRightMenuVC.h"
#import "emsLeftMenuVC.h"
#import "emsInterestsView.h"
#import "Interest.h"
#import "User.h"
#import "Essence.h"
#import "Notification.h"
#import "DSViewController.h"
#import "IceCreamViewController.h"
#import "emsDeviceManager.h"
#import "Constants.h"
#import "emsMapVC.h"
#import "emsAPIHelper.h"
#import <CoreLocation/CoreLocation.h>
#import "ABStoreManager.h"
#import "emsGlobalLocationServer.h"
#import "ActivityDetailViewController.h"
#import "ScadaddlePopup.h"
#import "emsScadaddleActivityIndicator.h"
#import "emsProfileVC.h"
#import "ActivityGeneralViewController.h"
#import "emsChatVC.h"
#import "emsScadProgress.h"
#import "FBHelper.h"
////#import "emsLoginVC.h"
#import "FBWebLoginViewController.h"

typedef NS_ENUM(NSUInteger,SelectedButton) {
    allButton = 0,
    activityButton,
    singleButton,
    interestsButton,
    rewardsButton
};
@interface emsMainScreenVC ()<UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate,UIAlertViewDelegate>{
    emsInterestsView *tmpCard;
    emsInterestsView *oldCard;
    IBOutlet UIView *leftMenu;
    IBOutlet UIView *RcontentView;
    IBOutlet UIView *rightMenu;
    IBOutlet UIView *contentView;
    int selectedNumber;
    int selectedNumberMenu;
    int scrollViewContentOffsetY;
    //--Popup-------------------------
    ScadaddlePopup *popup;
    NSThread *scadaddlePopupThread;
    //--------------------------------
    int indefPathCurrenScroll;
    int selectedInterest;
    int maxIndexUser;
    int __block currentUserIndex;
    int indexForDeletingUser;
    BOOL parsOnlyOnce;
    emsScadProgress * subView;
    int inrexRemuvedObject;
    
    
}
@property (nonatomic, weak) IBOutlet UIImageView *bgView;
@property (nonatomic, weak) IBOutlet UIImageView *bgViewR;
@property (nonatomic, weak) IBOutlet UIButton *firstBtn;
@property (nonatomic, weak) IBOutlet UIButton *secondBtn;
@property (nonatomic, weak) IBOutlet UIButton *thirdBtn;
@property (nonatomic, weak) IBOutlet UIButton *fourthBtn;
@property (nonatomic, weak) IBOutlet UIButton *fifthBtn;
@property (nonatomic, weak) IBOutlet UITableView *table;
@property (nonatomic, retain)NSMutableArray *buttonsArray;
@property (nonatomic, retain)NSMutableArray *mainArray;
@property (nonatomic, retain)NSMutableArray *essenceArray;
@property (nonatomic, retain)NSMutableArray *essenceArrayPredicated ;
@property (nonatomic, retain)NSMutableArray *parseArray;
@property (nonatomic, retain)NSMutableArray *parseArrayUsers;
@property(nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, weak) IBOutlet UIImageView *emtyTableViewImage;
//--
@property (nonatomic, retain)NSMutableArray *activitiesArray;
@property (nonatomic, retain)NSMutableArray *byInterestArray;
@property (nonatomic, retain)NSMutableArray *rewardsArray;
//--------------------------
@property (nonatomic,assign) SelectedButton selectedButton;
//------------ All
@property (nonatomic, retain) NSMutableArray *dictionaryArray;
@property (nonatomic, retain) NSMutableArray *dictionaryArrayAll;
@property (nonatomic, retain) NSMutableArray *essenceArrayFromDictionaryAll;
@property (nonatomic) NSInteger totalNumberOfAllSection;
@property (nonatomic) NSInteger uploadCountOfAllSection;
@property (nonatomic) BOOL allFineshed;
//------------ Activity
@property (nonatomic, retain) NSMutableArray *dictionaryArrayActivities;
@property (nonatomic, retain) NSMutableArray *essenceArrayFromDictionaryActivities;
@property (nonatomic) NSInteger totalNumberOfActivity;
@property (nonatomic) NSInteger uploadCountOfActivity;
@property (nonatomic) BOOL activityFineshed;
//------------ Single

@property (nonatomic, retain) NSMutableArray *dictionaryArraySingle;
@property (nonatomic, retain) NSMutableArray *essenceArrayFromDictionarySingle;
@property (nonatomic) NSInteger totalNumberOfSingle;
@property (nonatomic) NSInteger uploadCountOfSingle;
@property (nonatomic) BOOL singleFineshed;
//------------ Interests
@property (nonatomic, retain) NSMutableArray *dictionaryArrayInterests;
@property (nonatomic, retain) NSMutableArray *essenceArrayFromDictionaryInterests;
@property (nonatomic) NSInteger totalNumberOfInterests;
@property (nonatomic) NSInteger uploadCountOfInterests;
@property (nonatomic) BOOL interestsFineshed;
//------------ Rewards
@property (nonatomic, retain) NSMutableArray *dictionaryArrayRewards;
@property (nonatomic, retain) NSMutableArray *essenceArrayFromDictionaryRewards;
@property (nonatomic) NSInteger totalNumberOfRewards;
@property (nonatomic) NSInteger uploadCountOfRewards;
@property (nonatomic) BOOL rewardsFineshed;
//-------------------- indicator

@property (nonatomic, strong) emsScadaddleActivityIndicator *activityHeader;
@property (nonatomic, strong) emsScadaddleActivityIndicator *activityFooter;
@end

@implementation emsMainScreenVC


@synthesize activityHeader = _activityHeader;
@synthesize activityFooter = _activityFooter;

#define FOOTERFRAME CGRectMake(81.0f, table.contentSize.height-50, 157.0f, 157.0f)
#define HEADERFRAME CGRectMake(81.0f, -102.0f, 157.0f, 157.0f);
#define  KStringForrmat [NSString stringWithFormat:@"{%f,%f}",KmainScreenWidth,KmainScreen ]
//#define  KtabBarHeight     self.tabBarController.tabBar.frame.size.height
#define  KmainScreen      [UIScreen mainScreen].applicationFrame.size.height
#define  KmainScreenWidth   [UIScreen mainScreen].applicationFrame.size.width

/*!
 *
 * @discussion Show progress view ander superView
 *
*/
-(void)progress{
    
    subView = [[emsScadProgress alloc] initWithFrame:self.view.frame screenView:self.view andSize:CGSizeMake(320, 580)];
    
    [self.view addSubview:subView];
    subView.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        subView.alpha = 1;
    }];
}
/*!
 *
 * @discussion Sets emsScadaddleActivityIndicator  progress view in tablevview Header
 *
*/
- (emsScadaddleActivityIndicator *)activityHeader
{
    if (!_activityHeader) {
        _activityHeader = [[emsScadaddleActivityIndicator alloc] initWithActivityIndicatorStyle:FishActivityIndicatorViewStyleNormal];
        _activityHeader.hidesWhenStopped = NO;
    }
    return _activityHeader;
}
/*!
 *
 * @discussion Method Sets emsScadaddleActivityIndicator  progress view in tablevview Footer
 *
*/
- (emsScadaddleActivityIndicator *)activityFooter
{
    if (!_activityFooter) {
        _activityFooter = [[emsScadaddleActivityIndicator alloc] initWithActivityIndicatorStyle:FishActivityIndicatorViewStyleNormal];
        _activityFooter.hidesWhenStopped = NO;
    }
    return _activityFooter;
}

/*!
 *
 *@discussion Method Sets Header animation
 *
*/
- (void)actionHeader
{
    if (!self.activityHeader.isAnimating) {
        [self startAnimationHeader];
        [self.activityHeader startAnimating];
    }
}
/*!
 *
 * @discussion Method  Sets Footer animation
 *
*/
- (void)actionFooter
{
    if (!self.activityFooter.isAnimating) {
        [self startAnimationFooter];
        [self.activityFooter startAnimating];
    }
}

-(void)startAnimationHeader{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.7];
    self.table.contentInset = UIEdgeInsetsMake(45, 0, 0, 0);
    [UIView commitAnimations];
   
}
-(void)startAnimationFooter{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.table.contentInset = UIEdgeInsetsMake(0, 0, 75, 0);
    [UIView commitAnimations];

}
/*!
 *
 * @discussion Method Stops Header animation
 *
*/
-(void)stopHeader{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    self.table.contentInset = UIEdgeInsetsMake(0, 0.0f, 0.0f, 0.0f);
    [UIView commitAnimations];
    [self.activityHeader stopAnimating];
    self.activityHeader.progress =0;
    [self performSelector:@selector(reloadTableView) withObject:nil afterDelay:5];
}
/*!
 *
 *  @discussion  Method reloads main Table
 *
*/

-(void)reloadTableView{
    [self.table reloadData];
    [self chengeFooterFrame];
    if ([self.dictionaryArray count] == 0) {
        self.emtyTableViewImage.hidden = NO;
    }
    [self performSelector:@selector(stopSubview) withObject:nil afterDelay:.5];
}

/*!
 *
 * @discussion Method Remove progress view from superView
 *
*/
-(void)stopSubview{
    
    [UIView animateWithDuration:0.5 animations:^{
        subView.alpha = 0;
    } completion:^(BOOL finished) {
        [subView removeFromSuperview];
        subView = nil;
    }];
    
}
/*!
 *
 *  @discussion  Method fleshes aff flags
 *
*/
-(void)fleshMarkers{
    
    self.allFineshed = NO;
    self.totalNumberOfAllSection = 0;
    self.activityFineshed = NO;
    self.totalNumberOfActivity = 0;
    self.singleFineshed = NO;
    self.totalNumberOfSingle = 0;
    self.interestsFineshed = NO;
    self.totalNumberOfInterests = 0;
    self.rewardsFineshed = NO;
    self.totalNumberOfRewards = 0;
}

/*!
 *
 * @discussion Method Stops Footer animation
 *
*/
-(void)stopFooter{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    if (self.allFineshed || self.activityFineshed || self.singleFineshed || self.interestsFineshed || self.rewardsFineshed) {
        self.table.contentInset = UIEdgeInsetsMake(0, 0.0f, 50.0f, 0.0f);
        [self remuveFooter];
    }else{
        self.table.contentInset = UIEdgeInsetsMake(0, 0.0f, 0.0f, 0.0f);
    }
    [UIView commitAnimations];
    [self.activityFooter stopAnimating];
    
}

/*!
 *
 *  @discussion  Remove Footer view from superView
 *
*/

-(void)remuveFooter{
    [self.activityFooter removeFromSuperview];
    self.activityFooter = nil;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.activityFooter.frame =CGRectMake(81.0f, self.table.contentSize.height-50, 157.0f, 157.0f);
    self.activityHeader.frame = HEADERFRAME;
}

/*!
 *
 *  @discussion Method  chenges Footer frame
 *
*/
-(void)chengeFooterFrame{
    
    if ([self.dictionaryArray count]>=4) {
        self.activityFooter.frame =CGRectMake(81.0f, (self.table.contentSize.height-50) , 157.0f, 157.0f);
    }else{
        [self.activityFooter removeFromSuperview];
        self.activityFooter = nil;
    }
    
}


/*!
 *  @discussion  Method sets  Rewards array
 *  @return  Array this all data
*/

-(void)getRewards{
    
    self.dictionaryArrayRewards = [[NSMutableArray alloc] init];
    self.essenceArrayFromDictionaryRewards = [[NSMutableArray alloc] init];
    [self.dictionaryArrayRewards addObjectsFromArray:[Server rewards:[[emsGlobalLocationServer sharedInstance] latitude]
                                                             andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                                                            andStart: [NSString stringWithFormat: @"%ld", (long)self.totalNumberOfRewards]
                                                            andLimit: [NSString stringWithFormat: @"%ld", (long)self.uploadCountOfRewards]]];
    
    for (NSDictionary *dic in self.dictionaryArrayRewards) {
        
        Essence * essence = [[Essence alloc] init];
        if (dic[@"uId"]){
            essence.essenceType = userEssence;
            essence.essenceID = dic[@"uId"];
        }
        if (dic[@"aId"]){
            essence.essenceType = activityEssence;
            essence.essenceID = dic[@"activityOwnerId"];
            essence.essenceActivityFollowID = dic[@"aId"];
        }
        
        essence.inrerests = [[NSMutableArray alloc] init];
        [self.essenceArrayFromDictionaryRewards  addObject:essence];
    }
    
}
/*!
 *  @discussion  Method sets  Activities array
 *  @return Activities array
*/
-(void)getAllActivities{
    
    self.dictionaryArrayActivities = [[NSMutableArray alloc] init];
    
    self.essenceArrayFromDictionaryActivities = [[NSMutableArray alloc] init];
    
    [self.dictionaryArrayActivities addObjectsFromArray:[Server activities:[[emsGlobalLocationServer sharedInstance] latitude]
                                                                   andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                                                                  andStart: [NSString stringWithFormat: @"%ld", (long)self.totalNumberOfActivity]
                                                                  andLimit: [NSString stringWithFormat: @"%ld", (long)self.uploadCountOfActivity]]];
    
    
    for (NSDictionary *dic in self.dictionaryArrayActivities) {
        
        Essence * essence = [[Essence alloc] init];
        if (dic[@"uId"]){
            essence.essenceType = userEssence;
            essence.essenceID = dic[@"uId"];
        }
        if (dic[@"aId"]){
            essence.essenceType = activityEssence;
            essence.essenceID = dic[@"activityOwnerId"];
            essence.essenceActivityFollowID = dic[@"aId"];
        }
        
        essence.inrerests = [[NSMutableArray alloc] init];
        [self.essenceArrayFromDictionaryActivities  addObject:essence];
    }
    
}
/*!
 *  @discussion  Method  sets array this single users
*/
-(void)getAllBySingle{
    
    self.dictionaryArraySingle = [[NSMutableArray alloc] init];
    self.essenceArrayFromDictionarySingle = [[NSMutableArray alloc] init];
    [self.dictionaryArraySingle addObjectsFromArray:[Server interests:[[emsGlobalLocationServer sharedInstance] latitude]
                                                              andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                                                            andGender:@"0"
                                                             andStart: [NSString stringWithFormat: @"%ld", (long)self.totalNumberOfSingle]
                                                             andLimit:[NSString stringWithFormat: @"%ld", (long)self.uploadCountOfSingle]]];
    
    for (NSDictionary *dic in self.dictionaryArraySingle) {
        
        Essence * essence = [[Essence alloc] init];
        if (dic[@"uId"]){
            essence.essenceType = userEssence;
            essence.essenceID = dic[@"uId"];
        }
        if (dic[@"aId"]){
            essence.essenceType = activityEssence;
            essence.essenceID = dic[@"activityOwnerId"];
            essence.essenceActivityFollowID = dic[@"aId"];
        }
        essence.inrerests = [[NSMutableArray alloc] init];
        [self.essenceArrayFromDictionarySingle  addObject:essence];
    }
    
}
/*!
 *  @discussion Method Loads all entities according to shared interests
*/
-(void)getAllByInterests{
    
    self.dictionaryArrayInterests = [[NSMutableArray alloc] init];
    self.essenceArrayFromDictionaryInterests = [[NSMutableArray alloc] init];
    [self.dictionaryArrayInterests addObjectsFromArray:[Server interests:[[emsGlobalLocationServer sharedInstance] latitude]
                                                                 andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                                                               andGender:nil
                                                                andStart: [NSString stringWithFormat: @"%ld", (long)self.totalNumberOfInterests]
                                                                andLimit: [NSString stringWithFormat: @"%ld", (long)self.uploadCountOfInterests]]];
    
    
    for (NSDictionary *dic in self.dictionaryArrayInterests) {
        
        Essence * essence = [[Essence alloc] init];
        
        if (dic[@"uId"]){
            essence.essenceType = userEssence;
            essence.essenceID = dic[@"uId"];
        }
        
        if (dic[@"aId"]){
            essence.essenceType = activityEssence;
            essence.essenceID = dic[@"activityOwnerId"];
            essence.essenceActivityFollowID = dic[@"aId"];
        }
        
        essence.inrerests = [[NSMutableArray alloc] init];
        [self.essenceArrayFromDictionaryInterests  addObject:essence];
    }
}

/*!
 *  @discussion Method  Loads all entities/Prepare data for table/Init needed objects
*/
-(void)parseData{
    
    if (self.parseArray.count==0) {
        
        [self.parseArray removeAllObjects];
        [self.parseArrayUsers removeAllObjects];
        [self.dictionaryArrayAll removeAllObjects];
        [self.dictionaryArray removeAllObjects];
        [self.essenceArrayFromDictionaryAll removeAllObjects];
        
        if(!self.parseArray)
            self.parseArray = [[NSMutableArray alloc] init];
        if(!self.parseArrayUsers)
            self.parseArrayUsers = [[NSMutableArray alloc] init];
        if(!self.dictionaryArrayAll)
            self.dictionaryArrayAll = [[NSMutableArray alloc] init];
        if(!self.essenceArrayFromDictionaryAll)
            self.essenceArrayFromDictionaryAll = [[NSMutableArray alloc] init];
        self.selectedButton = allButton;
        
        //----------uploadCount
        self.totalNumberOfAllSection = 0;
        self.uploadCountOfAllSection = 10;
        self.totalNumberOfActivity = 0;
        self.uploadCountOfActivity = 10;
        self.totalNumberOfSingle = 0;
        self.uploadCountOfSingle = 10;
        self.totalNumberOfInterests = 0;
        self.uploadCountOfInterests = 10;
        self.totalNumberOfRewards = 0;
        self.uploadCountOfRewards = 10;
        scrollViewContentOffsetY = 0;
        //----------
        
        
        [self.parseArrayUsers addObjectsFromArray:[Server mainPage:[[emsGlobalLocationServer sharedInstance] latitude]
                                                           andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                                                          andStart: [NSString stringWithFormat: @"%ld", (long)self.totalNumberOfAllSection]
                                                          andLimit:[NSString stringWithFormat: @"%ld",(long)self.uploadCountOfAllSection]]];
        if(self.parseArrayUsers.count>0)
        {
            for (NSDictionary *dic in self.parseArrayUsers) {
                
                Essence * essence = [[Essence alloc] init];
                
                if (dic[@"uId"]){
                    essence.essenceType = userEssence;
                    essence.essenceID = dic[@"uId"];
                }
                
                if (dic[@"aId"]){
                    essence.essenceType = activityEssence;
                    essence.essenceID = dic[@"activityOwnerId"];
                    essence.essenceActivityFollowID = dic[@"aId"];
                }
                
                essence.inrerests = [[NSMutableArray alloc] init];
                [self.parseArray  addObject:essence];
            }
            
            [self.dictionaryArray addObjectsFromArray:self.parseArrayUsers];
            [self.dictionaryArrayAll addObjectsFromArray:self.dictionaryArray];
            [self.essenceArrayFromDictionaryAll addObjectsFromArray:self.parseArray];
            
            [self getAllActivities];
            [self getAllBySingle];
            [self getAllByInterests];
            [self getRewards];
            
            [_table reloadData];
        }
        
        if ([self.parseArrayUsers count] == 0) {
            self.emtyTableViewImage.hidden = NO;
        }
        if(self.parseArray.count>0)
            self.emtyTableViewImage.hidden = YES;
        
        [self chengeFooterFrame];
        
    }
}


/*!
 *  @discussion  Method opens profile by notification
*/
-(void)locationUpdates:(NSNotification *)notification
{
    if([notification.name isEqualToString:@"UserProfileFromNotifications"])
    {
        
        emsProfileVC *reg = [[emsProfileVC alloc] initWithNibName:@"emsProfileVC" bundle:nil];
        reg.profileUserId = notification.userInfo[@"userId"];
        [self presentViewController:reg animated:YES completion:^{
            
        }];
        
    }
    else
    {
        
        [self parseData];
    }
    
    [self performSelector:@selector(addFuterProgress) withObject:nil afterDelay:1.0];
    
}


/*!
 *  @discussion Method sets Futer if array count > 4
 *
*/
-(void)addFuterProgress{
    
    
    if ([self.dictionaryArray count]>=4) {
        self.activityFooter.frame =CGRectMake(81.0f, (self.table.contentSize.height-50) , 157.0f, 157.0f);
        [self.table addSubview:self.activityFooter];
    }
}

-(void)dealloc{
    
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    [self parseData];
    if(self.dictionaryArrayAll.count==0)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdates:) name:@"Scadaddle_LocationUpdated_service" object:nil];
    }
    [self dismissPopupAction];
    [self stopSubview];
    
    if ([[ABStoreManager sharedManager] needReloadMainScreen]) {
        
        [[ABStoreManager sharedManager] setneedReloadMainScreen:NO];
        selectedNumber = -1;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:inrexRemuvedObject inSection:0];
        [self.parseArray removeObjectAtIndex:inrexRemuvedObject];
        [self.dictionaryArray removeObjectAtIndex:inrexRemuvedObject];
        [self.table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]  withRowAnimation:UITableViewRowAnimationRight];
        [self performSelector:@selector(reloadTableView) withObject:nil afterDelay:0.35];
        if ([self.parseArray count] == 0) {
            [self progress];
            [self uploadData];
        }else{
            [self performSelector:@selector(reloadTableView) withObject:nil afterDelay:0.35];
        }
        
    }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self progress];
    self.dictionaryArray = [[NSMutableArray alloc] init];
    [self setUpButtons];
    
    selectedNumber = kSelectedNumber;
    selectedNumberMenu = kSelectedNumberMenu;
    maxIndexUser = kZeroIndex;
    //----
    indefPathCurrenScroll = kZeroIndex;
    selectedInterest = kZeroIndex;
    currentUserIndex = kZeroIndex;
    
    [self.table addSubview:self.activityHeader];
    [self performSelector:@selector(addFuterProgress) withObject:nil afterDelay:1.0];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachability:) name:@"EMSReachableChanged" object:nil];
}

/*!
 *  @discussion Checks internet connection
*/

-(void)reachability:(NSNotification *)notification
{
    
    BOOL status =(BOOL)notification.userInfo[@"status"];
    {
        
        if(status==YES){
            [self stopSubview];
        }else if(status == NO){
            [self progress];
        }
        
    }
}

/*!
 *  @discussion UIScrollView delegates
*/
-(void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    if (!self.activityHeader.isAnimating) {
        self.activityHeader.progress = -(scrollView.contentOffset.y /100);
    }
    
    if (!self.activityFooter.isAnimating){
        self.activityFooter.progressFooter = (scrollView.contentOffset.y /100);
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate{
    
    scrollViewContentOffsetY = scrollView.contentOffset.y;
    
    if (scrollView.contentOffset.y <= -75){
        [self actionHeader];
    }
    
    if (scrollView.contentOffset.y >=( self.table.contentSize.height - self.table.frame.size.height+45)){
        [self actionFooter];
    }
}

/*!
 *  @discussion Method sets buttons array
*/
-(void)setUpButtons{
    self.buttonsArray = [[NSMutableArray alloc] init];
    [self.buttonsArray addObject:self.firstBtn];
    [self.buttonsArray addObject:self.secondBtn];
    [self.buttonsArray addObject:self.thirdBtn];
    [self.buttonsArray addObject:self.fourthBtn];
    [self.buttonsArray addObject:self.fifthBtn];
}

/*!
 *  @discussion Method switches data in main table view
*/

-(IBAction)selectBTN:(UIButton*)sender{
    
    for (UIButton *btn in self.buttonsArray) {
        [btn setSelected:NO];
    }
    UIButton *btn =(UIButton *)[self.buttonsArray objectAtIndex:sender.tag];
    [btn setSelected:YES];
    
    [self progress];
    
    switch (sender.tag) {
        case 0:
            [self allAction];
            break;
        case 1:
            [self activity];
            break;
        case 2:
            [self single];
            break;
        case 3:
            [self interests];
            break;
        case 4:
            [self rewards];
            break;
        default:
            break;
    }
    
    self.table.contentInset = UIEdgeInsetsMake(0, 0.0f, 0.0f, 0.0f);
    
    if ([self.dictionaryArray count]) {
        
        [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    
    [self fleshMarkers];
    
    if ([self.dictionaryArray count]>=4) {
        self.activityFooter.frame =CGRectMake(81.0f, (self.table.contentSize.height-50) , 157.0f, 157.0f);
        [self.table addSubview:self.activityFooter];
    }
    
}

#pragma mark - tableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.dictionaryArray  count];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath row] == selectedNumber) {
        return  selectedNumberMenu;
    }
    else return kStandartSellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MainScreenCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainScreenCell"];
    Essence *essence = [self.parseArray objectAtIndex:indexPath.row];
    
    if (!cell) {
        
        NSArray* xibCell = [[NSBundle mainBundle] loadNibNamed:@"MainScreenCell" owner:self options:nil];
        cell = [xibCell objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGFloat x=0;
        for (int i =0; i<[essence.inrerests count];i++ ) {
            
            /*!
            * opens scroll this cross interests
            */
            
            Interest * interest =[essence.inrerests objectAtIndex:i];
            x = x+17;
            cell.sc.contentSize = CGSizeMake(x+10*i, 0);
            UIImageView *interestView= [[UIImageView alloc] init];
            UIImageView *interestCercle= [[UIImageView alloc] init];
            interestView.frame = CGRectMake(x, 0, 34, 34);
            interestCercle.frame = CGRectMake(x, 0, 34, 34);
            interestCercle.image =[UIImage imageNamed:@"circle_interests"];
            UIButton *btn  = [[UIButton alloc] initWithFrame:interestView.frame];
            btn.tag = i;
            interestView.backgroundColor = [UIColor whiteColor];
            interestView.image = [UIImage imageNamed:@"placeholder"];
            if (interest.interestImageURL && ![interest.interestImageURL isEqualToString:@""]) {
                
                if(![self imageHandlerInterest:[NSString stringWithFormat:@"%@%@",SERVER_PATH,interest.interestImageURL] andInterestView:interestView])
                {
                    /*!
                     *Load by path from WEB
                    */
                    [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,interest.interestImageURL]
                           andIndicator:nil addToImageView:interestView andImageName:[NSString stringWithFormat:@"%@%@",SERVER_PATH,interest.interestImageURL]];
                }
                
            }
            x = x+interestView.frame.size.width;
            [btn addTarget:self action:@selector(showUsersByInerests:) forControlEvents:UIControlEventTouchUpInside];
            [self cornerIm:interestView];
            [cell.sc addSubview:interestView];
            [cell.sc addSubview:interestCercle];
            [cell.sc addSubview:btn];
        }
        
    }
    cell.likeBtn.tag = indexPath.row;
    cell.deleteBtn.tag = indexPath.row;
    cell.openScroll.tag = indexPath.row;
    cell.infoBtn.tag = indexPath.row;
    [cell.infoBtn addTarget:self action:@selector(userInfoAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.deleteBtn addTarget:self action:@selector(delUserAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.likeBtn addTarget:self action:@selector(likeUserAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.openScroll addTarget:self action:@selector(openScrollAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.sc.hidden = YES;
    
    [cell configureCellItemsWithData:[self.dictionaryArray objectAtIndex:indexPath.row]];
    
    if (essence.essenceType == rewardEssence) {
        cell.deleteBtn.hidden=YES;
        cell.openScroll.hidden = YES;
        [cell.iceBtn addTarget:self action:@selector(openIceCreamDay:) forControlEvents:UIControlEventTouchUpInside];
        [cell.infoBtn addTarget:self action:@selector(openIceCreamDay:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (essence.showUsers) {
        
        emsInterestsView *newCard = [self getCard];
        newCard.frame = kNewCardFrame;
        
        [cell.usersView addSubview:newCard];
        [UIView animateWithDuration:.4 animations:^{
            
            if (tmpCard != nil) {
                tmpCard.frame = kNewCardFrameTransition ;
                tmpCard.alpha = 0.5;
            }
            
            newCard.frame = kNewCardFrameMainScreen;
            
        } completion:^(BOOL finished) {
            
            [tmpCard removeFromSuperview];
            tmpCard = newCard;
            
        }];
    }
    /*!
     opens scroll this cross interests
    */
    if (essence.selected) {
        cell.sc.hidden = NO;
        cell.usersView.hidden = NO;
        
        if (cell.sc.contentSize.width == 0) {
            cell.noCrossInterests.hidden = NO;
            cell.grayLine.hidden = YES;
            if ( essence.essenceType == userEssence){
                cell.noCrossInterests.image = [UIImage imageNamed:@"non_activity_img-1"];
            }else{
                cell.noCrossInterests.image = [UIImage imageNamed:@"non_interest_img-2"];
            }
        }
        if (!essence.notAnimateScroll) {
          
            cell.sc.frame = kCellScrollRight ;
            [UIView animateWithDuration:0.3 animations:^{
                cell.sc.frame = kCellScrollLeft;
            } completion:^(BOOL finished) {
                essence.notAnimateScroll = YES;
            }];
            
        }
    }
    /*!
     hides scroll this cross interests
    */
    if (essence.hidePressedScroll) {
    
        cell.sc.hidden = NO;
        cell.sc.frame = CGRectMake(cell.sc.frame.origin.x,
                                   cell.sc.frame.origin.y ,
                                   cell.sc.frame.size.width,
                                   cell.sc.frame.size.height);
        [UIView animateWithDuration:0.3 animations:^{
            cell.sc.frame = kCellScrollRight;
            
        } completion:^(BOOL finished) {
            cell.sc.hidden = YES;
            if (cell.sc.contentSize.width == 0) {
                cell.noCrossInterests.hidden = NO;
                cell.grayLine.hidden = YES;
                if ( essence.essenceType == userEssence){
                    cell.noCrossInterests.image = [UIImage imageNamed:@"non_interest_img-2"];
                }else{
                    cell.noCrossInterests.image = [UIImage imageNamed:@"non_activity_img-1"];
                }
            }
            
            essence.hidePressedScroll = NO;
        }];
        
    }
    
    return cell;
}


/*!
 *  @discussion Method  Opens IceCreamViewController
*/
-(void)openIceCreamDay:(UIButton *)sender
{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[emsDeviceManager isIphone6plus]?@"IceCream_6plus":@"IceCream" bundle:nil];
    IceCreamViewController *iceCream = [storyboard instantiateViewControllerWithIdentifier:@"IceCreamViewController"];
    [self presentViewController:iceCream animated:YES completion:^{
        
    }];
    
}

/*!
 *  @discussion Method  Opens scroll this cross interests
*/
-(void)openScrollAction:(UIButton *)sender{
    
    Essence *essence = [self.parseArray objectAtIndex:sender.tag];
    indefPathCurrenScroll = (int)sender.tag;
    
    if (essence.selected || essence.showUsers) {
        [essence.inrerests removeAllObjects];
        essence.selected = NO;
        selectedNumber = -1;
        essence.hidePressedScroll = YES;
        for (Essence *es in self.parseArray) {
            es.showUsers = NO;
        }
        [self.table beginUpdates];
        [self.table endUpdates];
        [self.table reloadData];
        
    }else{
        
        selectedNumberMenu =kSelectedNumberMenu;
        [self.table beginUpdates];
        [self.table endUpdates];
        [self.table reloadData];
        
        [self setUpNotifications: essence andInterests:[Server crossInterests:essence.essenceID]];
        
        for (Essence *es in self.parseArray) {
            es.selected = NO;
            es.notAnimateScroll = NO;
            es.showUsers = NO;
        }
        essence.selected = YES;
        selectedNumber = (int)sender.tag;
        selectedNumberMenu =kSelectedNumberMenu;
        [self.table beginUpdates];
        [self.table endUpdates];
        [self.table reloadData];
        essence.selected = YES;
        selectedNumber = (int)sender.tag;
        selectedNumberMenu =kSelectedNumberMenu;
        [self.table beginUpdates];
        [self.table endUpdates];
       
    }
    
    [self chengeFooterFrame];
}

/*!
 *  @discussion Method  presents emsProfileVC this current user
*/
-(void)userInfoAction:(UIButton*)sender
{
    inrexRemuvedObject =(int)sender.tag;
    
    Essence *essence = [self.parseArray objectAtIndex:sender.tag];
    
    if (essence.essenceType == userEssence) {
        
        emsProfileVC *reg = [[emsProfileVC alloc] initWithNibName:@"emsProfileVC" bundle:nil];
        
        reg.profileUserId = essence.essenceID;
        
        [self presentViewController:reg animated:YES completion:^{
            
        }];
        
    }
    if (essence.essenceType == activityEssence) {
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:[NSNumber numberWithUnsignedInteger:kPIMainScreen] forKey:@"fromScreen"];
        [prefs synchronize];
        
        [self presentViewController:[[ActivityDetailViewController alloc] initWithData:[self.dictionaryArray objectAtIndex:sender.tag]] animated:YES completion:^{
            
        }];
        
    }
    
}
/*!
 *  @discussion Method adds user to followers
*/

-(void)likeUserAction:(UIButton*)sender{
    
    Essence *essence = [self.parseArray objectAtIndex:sender.tag];
    
    if (essence.essenceType == userEssence) {
        
        [Server followUser:essence.essenceID callback:^{
            
            if (sender.tag == selectedNumber) {
                selectedNumber = -1;
            }
            if (sender.tag < selectedNumber) {
                selectedNumber =selectedNumber -1;
                indefPathCurrenScroll = indefPathCurrenScroll -1;
            }
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
            [self.parseArray removeObjectAtIndex:sender.tag];
            [self.dictionaryArray removeObjectAtIndex:sender.tag];
            [self.table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]  withRowAnimation:UITableViewRowAnimationRight];
            [self performSelector:@selector(reloadTableView) withObject:nil afterDelay:0.35];
            if ([self.parseArray count] == 0) {
                [self progress];
                [self uploadData];
            }else{
                [self performSelector:@selector(reloadTableView) withObject:nil afterDelay:0.35];
            }
        }];
    }
    if (essence.essenceType == activityEssence) {
        
        [Server followActivity:essence.essenceActivityFollowID callback:^{
            
            if (sender.tag == selectedNumber) {
                selectedNumber = -1;
            }
            if (sender.tag < selectedNumber) {
                selectedNumber =selectedNumber -1;
                indefPathCurrenScroll = indefPathCurrenScroll -1;
            }
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
            [self.parseArray removeObjectAtIndex:sender.tag];
            [self.dictionaryArray removeObjectAtIndex:sender.tag];
            [self.table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]  withRowAnimation:UITableViewRowAnimationRight];
            
            if ([self.parseArray count] == 0) {
                [self progress];
                [self uploadData];
            }else{
                [self performSelector:@selector(reloadTableView) withObject:nil afterDelay:0.35];
            }
            
            
        }];
    }
    
}
/*!
 *  @discussion Method deletes entity from participant array and from view
*/

-(void)delUserAction:(UIButton*)sender{
    
    indexForDeletingUser = (int)sender.tag;
    
    
    Essence *essence = [self.parseArray objectAtIndex:indexForDeletingUser];
    
    
    if (essence.essenceType == userEssence) {
        [Server deleteUser:essence.essenceID callback:^{
            
            if (indexForDeletingUser == selectedNumber) {
                selectedNumber = -1;
            }
            if (indexForDeletingUser < selectedNumber ) {
                selectedNumber = selectedNumber-1;
                indefPathCurrenScroll = indefPathCurrenScroll -1;
            }
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexForDeletingUser inSection:0];
            [self.parseArray removeObjectAtIndex:indexForDeletingUser];
            [self.dictionaryArray removeObjectAtIndex:indexForDeletingUser];
            [self.table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]  withRowAnimation:UITableViewRowAnimationLeft];
            [self.table performSelector:@selector(reloadData) withObject:nil afterDelay:0.35];
            
        }];
    }
    
    if (essence.essenceType == activityEssence) {
        
        [Server hideActivity:essence.essenceID callback:^{
            
            if (indexForDeletingUser == selectedNumber) {
                selectedNumber = -1;
            }
            if (indexForDeletingUser < selectedNumber ) {
                selectedNumber = selectedNumber-1;
                indefPathCurrenScroll = indefPathCurrenScroll -1;
            }
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexForDeletingUser inSection:0];
            [self.parseArray removeObjectAtIndex:indexForDeletingUser];
            [self.dictionaryArray removeObjectAtIndex:indexForDeletingUser];
            [self.table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]  withRowAnimation:UITableViewRowAnimationLeft];
            [self.table performSelector:@selector(reloadData) withObject:nil afterDelay:0.35];
            
        }];
    }
    
    
    
}

/*!
 *  @discussion  Method sets view this users
*/

-(void)showUsersByInerests:(UIButton*)sender{
    selectedInterest = (int)sender.tag;
    for (Essence *es in self.parseArray) {
        es.selected = NO;
        es.notAnimateScroll = NO;
        es.showUsers = NO;
    }
    Essence *essence = [self.parseArray objectAtIndex:indefPathCurrenScroll];
    essence.showUsers = YES;
    
    if (selectedNumberMenu !=indefPathCurrenScroll) {
        selectedNumber = indefPathCurrenScroll;
        selectedNumberMenu = selectedNumberMenuScroll;
        [self.table beginUpdates];
        [self.table endUpdates];
        [self.table reloadData];
    }
    
    Interest * interest =[essence.inrerests objectAtIndex:selectedInterest];
    maxIndexUser =(int) [interest.usersByInterests count];
    [UIView animateWithDuration:2.4 animations:^{
        
    } completion:^(BOOL finished) {
        
    }];
    
    [self chengeFooterFrame];
}


/*!
 *  @discussion  Method removes view this users from view
*/

-(void)deletaFavoreteFromList:(UIButton*)sender{
    
    if (selectedNumberMenu !=sender.tag) {
        selectedNumber = (int)sender.tag;
        selectedNumberMenu =selectedNumberMenuScroll;
        [self.table beginUpdates];
        [self.table endUpdates];
        [self.table reloadData];
    }
    
    [UIView animateWithDuration:0.4 animations:^{
      
    } completion:^(BOOL finished) {
        
        [self nextWordAction:(int)sender.tag ];
        
    }];
}

/*!
 *  @discussion  Method leafs view this users to the left
*/

- (IBAction)nextWordAction:(int)index{
    
    if (currentUserIndex >= 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        MainScreenCell *cellDiscription = (MainScreenCell *)[_table cellForRowAtIndexPath:indexPath];
        emsInterestsView *newCard = [self getCard];
        newCard.frame = CGRectMake(320, newCard.frame.origin.y, newCard.frame.size.width, newCard.frame.size.height);
        [cellDiscription.usersView addSubview:newCard];
        [UIView animateWithDuration:0.4 animations:^{
            if (tmpCard != nil) {
                tmpCard.frame = CGRectMake(-100, newCard.frame.origin.y, newCard.frame.size.width, newCard.frame.size.height);;
                tmpCard.alpha = 0.5;
            }
            
            newCard.frame = CGRectMake(80, newCard.frame.origin.y, newCard.frame.size.width, newCard.frame.size.height);
            
        } completion:^(BOOL finished) {
            
            [tmpCard removeFromSuperview];
            tmpCard = newCard;
            
        }];
        
    }else{
        
        for (UIButton *b in tmpCard.subviews) {
            if (b.tag ==876 ) {
                [b removeFromSuperview];
            }
        }
        currentUserIndex++;
    }
}

/*!
 *  @discussion  Method gets Users from cross interests Array
 *  @return  an emsInterestsView  as a UIView
*/


- (emsInterestsView *)getCard{
    
    Essence *essence = [self.parseArray objectAtIndex:indefPathCurrenScroll];
    Interest * interest =[essence.inrerests objectAtIndex:selectedInterest];
    User *user =(User *)[interest.usersByInterests objectAtIndex:currentUserIndex];
    
    emsInterestsView *newCard = [[emsInterestsView alloc] initWithWord:user.name  andUser:user andImage:nil  andUrl:interest.interestImageURL result:^(BOOL bl) {
        
        if (bl) {
            currentUserIndex --;
            [self nextWordAction:selectedNumber];
        }
        if (!bl) {
            currentUserIndex ++;
            [self nextRihgt:selectedNumber];
        }
        
    } cellBlock:^(BOOL bl) {
        
        if (bl) {
            currentUserIndex = 0;
            for (Essence *es in self.parseArray) {
                es.selected = NO;
                es.notAnimateScroll = NO;
                es.showUsers = NO;
            }
            
            Essence *essence = [self.parseArray objectAtIndex:selectedNumber];
            essence.selected = YES;
            selectedNumberMenu =kSelectedNumberMenu;
            [self.table beginUpdates];
            [self.table endUpdates];
            [self.table reloadData];
            
        }
        
    }userBlock:^(User *user){
        
        emsProfileVC *reg = [[emsProfileVC alloc] initWithNibName:@"emsProfileVC" bundle:nil];
        reg.profileUserId = user.userId;
        [self presentViewController:reg animated:YES completion:^{
            
        }];
        
    }];
    
    if (currentUserIndex == 0) {
        for (UIButton *b in newCard.subviews) {
            if (b.tag ==876 ) {
                [b removeFromSuperview];
            }
        }
    }
    if (currentUserIndex == maxIndexUser - 1) {
        for (UIButton *b in newCard.subviews) {
            if (b.tag ==1234 ) {
                [b removeFromSuperview];
            }
            
        }
    }
    
    if (maxIndexUser==1) {
        for (UIButton *b in newCard.subviews) {
            if (b.tag ==1234 ) {
                [b removeFromSuperview];
            }
            if (b.tag ==876 ) {
                [b removeFromSuperview];
            }
        }
    }
    return newCard;
}

/*!
 *  @discussion  Method leafs view this users to the right
 */

- (IBAction)nextRihgt:(int)index{
    
    if (currentUserIndex < maxIndexUser) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        MainScreenCell *cellDiscription = (MainScreenCell *)[self.table cellForRowAtIndexPath:indexPath];
        emsInterestsView *newCard = [self getCard];
        newCard.frame = CGRectMake(-100, newCard.frame.origin.y, newCard.frame.size.width, newCard.frame.size.height);
        newCard.alpha = 0;
        [cellDiscription.usersView addSubview:newCard];
        [UIView animateWithDuration:.4 animations:^{
            
            if (tmpCard != nil) {
                tmpCard.frame = CGRectMake(344, newCard.frame.origin.y, newCard.frame.size.width, newCard.frame.size.height);;
                tmpCard.alpha = 0.5;
            }
            
            newCard.frame = CGRectMake(80, newCard.frame.origin.y, newCard.frame.size.width, newCard.frame.size.height);
            newCard.alpha = 1;
        } completion:^(BOOL finished) {
            
            [tmpCard removeFromSuperview];
            tmpCard = newCard;
            
        }];
    }else{
        
        for (UIButton *b in tmpCard.subviews) {
            if (b.tag ==1234 ) {
                [b removeFromSuperview];
            }
        }
        currentUserIndex --;
    }
}

/*!
 *  @discussion  Method presents emsMapVC
*/

-(IBAction)mapAction:(id)sender{
    [self presentViewController:[[emsMapVC alloc] init] animated:YES completion:^{
        
    }];
}

/*!
 *  @discussion  Method reloads main table view
*/
-(IBAction)sociarRodar:(id)sender{
    [self startUpdating];
    
    [self allAction];
    
    for (UIButton *btn in self.buttonsArray) {
        [btn setSelected:NO];
    }
    
    UIButton *btn =(UIButton *)[self.buttonsArray objectAtIndex:0];
    [btn setSelected:YES];
    [self dismissPopupAction];
}

#pragma mark - CLLocationManagerDelegate


/*!
 *  @discussion Method returns user location
*/
- (void)locationManager:(CLLocationManager*)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined: {
          
        } break;
        case kCLAuthorizationStatusDenied: {
           
        } break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways: {
            [self.locationManager startUpdatingLocation]; //Will update location immediately
        } break;
        default:
            break;
    }
}

/*!
 *  @discussion Method stops Updating
 *
*/
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.locationManager stopUpdatingLocation];
    
}

/*!
 *  @discussion Method sets map visible region
*/
-(void)initLicator
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse
       
        ) {
        [self.locationManager requestWhenInUseAuthorization];
       
    } else {
        [self.locationManager startUpdatingLocation];
    }
    
    
}

#pragma Mark rightMenuDelegate

/*!
 * @discussion Method cleans child view controllers
*/

-(void)notificationSelected:(Notification *)notification
{
    [[self.childViewControllers lastObject] willMoveToParentViewController:nil];
    [[[self.childViewControllers lastObject] view] removeFromSuperview];
    [[self.childViewControllers lastObject] removeFromParentViewController];

}


#pragma Mark leftMenudelegate

/*!
 * @discussion Sets up Left Menu
 * @param actionsTypel actions that were chosen
 * @see emsLeftMenuVC
*/

-(void)actionPresed:(ActionsType)actionsTypel complite:(void (^)())complite{
    
    if (actionsTypel == quitAction) {
        
        [self progressForQuit:^{
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FBWebLogin" bundle:nil];
            FBWebLoginViewController *notebook = [storyboard instantiateViewControllerWithIdentifier:@"FBWebLogin"];
            
            [self presentViewController:notebook animated:YES completion:^{
                [self stopSubviewForQuit];
                [[self.childViewControllers lastObject] willMoveToParentViewController:nil];
                [[[self.childViewControllers lastObject] view] removeFromSuperview];
                [[self.childViewControllers lastObject] removeFromParentViewController];
                
            }];
        }];
        
    }
    complite();
}

/*!
 *  @discussion Method sets Righ Menu did receive remote notification
*/

-(void)openNotificationsFromPush
{
    
    emsRightMenuVC *emsRightMenu = [ [emsRightMenuVC alloc] initWithDelegate:self];
    NSLog(@"emsLeftMenu %@",emsRightMenu.delegate);
    
}
/*!
 *  @discussion Sets up Righ Menu
 *
*/
-(IBAction)showRightMenu{
    
    emsRightMenuVC *emsRightMenu = [ [emsRightMenuVC alloc] initWithDelegate:self];
    NSLog(@"emsLeftMenu %@",emsRightMenu.delegate);
}


/*!
 *@discussion Method Sets up Left Menu
 *
*/
-(IBAction)showLeftMenu{
    
    emsLeftMenuVC *emsLeftMenu =[[emsLeftMenuVC alloc] initWithDelegate:self ];
    NSLog(@"emsLeftMenu %@",emsLeftMenu.delegate);
}
/*!
 *  @discussion scrollView delegate
 *
*/

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    if (-75 >= scrollViewContentOffsetY){
        [self updateData];
    }
    
    if (scrollView.contentOffset.y >=( self.table.contentSize.height - self.table.frame.size.height+45)){
        [self uploadData];
        
    }
}

#pragma mark - Predicate

/*!
 *  allAction
 *  @discussion  Method sets  Array this all data
 *  @return: Array this all data
*/

-(IBAction)allAction{
    
    self.emtyTableViewImage.hidden = YES;
    selectedNumber = -1;
    [self.table beginUpdates];
    [self.table endUpdates];
    [self.table reloadData];
    
    self.selectedButton = allButton;
    
    NSArray *arr = [Server mainPage:[[emsGlobalLocationServer sharedInstance] latitude]
                            andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                           andStart:@"0"
                           andLimit:@"10"];
    [self.parseArray removeAllObjects];
    [self.dictionaryArray removeAllObjects];
    for (NSDictionary *dic in arr) {
        
        Essence * essence = [[Essence alloc] init];
        
        if (dic[@"uId"]){
            essence.essenceType = userEssence;
            essence.essenceID = dic[@"uId"];
        }
        
        if (dic[@"aId"]){
            essence.essenceType = activityEssence;
            essence.essenceID = dic[@"activityOwnerId"];
            essence.essenceActivityFollowID = dic[@"aId"];
        }
        
        essence.inrerests = [[NSMutableArray alloc] init];
        [self.parseArray  addObject:essence];
        
    }
    
    [self.dictionaryArray addObjectsFromArray:arr];
    
    if ([self.dictionaryArray count] == 0) {
        self.emtyTableViewImage.hidden = NO;
    }
    
    [self.table reloadData];
    
    [self performSelector:@selector(stopSubview) withObject:nil afterDelay:.5];
    
   [self.table reloadData];
}

/*!
 *  @discussion  Method sets activities Array
 *  @return: Array of activities
*/
-(IBAction)activity{
   
    self.emtyTableViewImage.hidden = YES;
    selectedNumber = -1;
    [self.table beginUpdates];
    [self.table endUpdates];
    [self.table reloadData];
    
    self.selectedButton = activityButton;
    
    NSArray *arr = [Server activities:[[emsGlobalLocationServer sharedInstance] latitude]
                              andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                             andStart:[NSString stringWithFormat: @"%@",@"0"]
                             andLimit:[NSString stringWithFormat: @"%@",@"10"]];
    
    [self.parseArray removeAllObjects];
    [self.dictionaryArray removeAllObjects];
    
    
    for (NSDictionary *dic in arr) {
        
        Essence * essence = [[Essence alloc] init];
        if (dic[@"uId"]){
            essence.essenceType = userEssence;
            essence.essenceID = dic[@"uId"];
        }
        if (dic[@"aId"]){
            essence.essenceType = activityEssence;
            essence.essenceID = dic[@"activityOwnerId"];
            essence.essenceActivityFollowID = dic[@"aId"];
        }
        [self.parseArray  addObject:essence];
    }
    
    
    [self.dictionaryArray addObjectsFromArray:arr];
    [self reloadTableView];
}

/*!
 *  @discussion  Method sets Interests Array
 *  @return: Array of Interests
*/
-(IBAction)single{
    
    self.emtyTableViewImage.hidden = YES;
    selectedNumber = -1;
    [self.table beginUpdates];
    [self.table endUpdates];
    [self.table reloadData];
    
    self.selectedButton = singleButton;
    
    NSArray *arr =  [Server interests:[[emsGlobalLocationServer sharedInstance] latitude]
                              andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                            andGender:@"0"
                             andStart:@"0"
                             andLimit:@"10"];
    
    
    [self.parseArray removeAllObjects];
    [self.dictionaryArray removeAllObjects];
    
    for (NSDictionary *dic in arr) {
        
        Essence * essence = [[Essence alloc] init];
        
        if (dic[@"uId"]){
            essence.essenceType = userEssence;
            essence.essenceID = dic[@"uId"];
        }
        
        if (dic[@"aId"]){
            essence.essenceType = activityEssence;
            essence.essenceID = dic[@"activityOwnerId"];
            essence.essenceActivityFollowID = dic[@"aId"];
        }
        
        essence.inrerests = [[NSMutableArray alloc] init];
        [self.parseArray  addObject:essence];
    }
    [self.dictionaryArray addObjectsFromArray:arr];
    
    [self reloadTableView];
    
}

/*!
 *  @discussion  Method sets Interests Array
 *  @return: Array of Interests
*/
-(IBAction)interests{
   
    self.emtyTableViewImage.hidden = YES;
    selectedNumber = -1;
    [self.table beginUpdates];
    [self.table endUpdates];
    [self.table reloadData];
    
    self.selectedButton = interestsButton;
    
    NSArray *arr = [Server interests:[[emsGlobalLocationServer sharedInstance] latitude]
                             andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                           andGender:nil
                            andStart:@"0"
                            andLimit:@"10"];
    [self.parseArray removeAllObjects];
    [self.dictionaryArray removeAllObjects];
    for (NSDictionary *dic in arr) {
        
        Essence * essence = [[Essence alloc] init];
        
        if (dic[@"uId"]){
            essence.essenceType = userEssence;
            essence.essenceID = dic[@"uId"];
        }
        
        if (dic[@"aId"]){
            essence.essenceType = activityEssence;
            essence.essenceID = dic[@"activityOwnerId"];
            essence.essenceActivityFollowID = dic[@"aId"];
        }
        
        essence.inrerests = [[NSMutableArray alloc] init];
        
        [self.parseArray  addObject:essence];
        
    }
    
    [self.dictionaryArray addObjectsFromArray:arr];
    
    [self reloadTableView];
    
}
/*!
 *  @discussion  Method sets Rewards Array
 *  @return: Array of Rewards
*/

-(IBAction)rewards{
   
    self.emtyTableViewImage.hidden = YES;
    selectedNumber = -1;
    [self.table beginUpdates];
    [self.table endUpdates];
    [self.table reloadData];
    
    self.selectedButton = rewardsButton;
    
    NSArray *arr = [Server rewards:[[emsGlobalLocationServer sharedInstance] latitude]
                           andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                          andStart:@"0"
                          andLimit:@"10"];
    
    
    [self.parseArray removeAllObjects];
    [self.dictionaryArray removeAllObjects];
    
    for (NSDictionary *dic in arr) {
        
        Essence * essence = [[Essence alloc] init];
        
        if (dic[@"uId"]){
            essence.essenceType = userEssence;
            essence.essenceID = dic[@"uId"];
        }
        
        if (dic[@"aId"]){
            essence.essenceType = activityEssence;
            essence.essenceID = dic[@"activityOwnerId"];
            essence.essenceActivityFollowID = dic[@"aId"];
        }
        
        essence.inrerests = [[NSMutableArray alloc] init];
        
        [self.parseArray  addObject:essence];
        
    }
    
    [self.dictionaryArray addObjectsFromArray:arr];
    [self reloadTableView];
    
}
/*!
 *  @discussion  Method updates main tableview
*/
-(void)reloudTable:(NSArray *)arr{
    [self.essenceArrayPredicated  removeAllObjects];
    [self.essenceArrayPredicated  addObjectsFromArray:arr];
    for (Essence *es in self.essenceArrayPredicated) {
        es.selected = NO;
        es.notAnimateScroll = NO;
        es.showUsers = NO;
    }
    for (Essence *es in self.parseArray) {
        es.selected = NO;
        es.notAnimateScroll = NO;
        es.showUsers = NO;
    }
    selectedNumber = -1;
    [self.table reloadData];
    
}
/*!
 *  @discussion Method sets corner radius to images
*/
-(void)cornerIm:(UIImageView*)imageView{
    imageView .layer.cornerRadius = imageView.frame.size.height/2;
    imageView.layer.masksToBounds = YES;
}

/*!
 *  @discussion  Method updates  particular section
*/

-(void)updateData{
    
    selectedNumber = -1;
    [self.table beginUpdates];
    [self.table endUpdates];
    [self.table reloadData];
    switch (self.selectedButton) {
        case allButton:[self updateAll];
            break;
        case activityButton:[self updateActivity];
            break;
        case singleButton:[self updateSingle];
            break;
        case interestsButton:[self updateInterests];
            break;
        case rewardsButton:[self updateRewards];
            break;
        default:
            break;
    }
    
}
/*!
 *  @discussion  Method updates  particular section
*/
-(void)uploadData{
    
    switch (self.selectedButton) {
        case allButton:[self uploadAll];
            break;
        case activityButton:[self uploadActivity];
            break;
        case singleButton:[self uploadSingle];
            break;
        case interestsButton:[self uploadInterests];
            break;
        case rewardsButton:[self uploadRewards];
            break;
        default:
            break;
    }
}


/*!
 *  @discussion  Method updates Array this all data by drop down scroll
 *  @return: Array of Array this all data
*/
-(void)updateAll{
    
    NSArray *arr = [Server mainPage:[[emsGlobalLocationServer sharedInstance] latitude]
                            andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                           andStart:@"0"
                           andLimit:[NSString stringWithFormat: @"%ld", (unsigned long)[self.parseArray count]]];
    if(arr.count>0)
    {
        [self.parseArray removeAllObjects];
        [self.dictionaryArray removeAllObjects];
        for (NSDictionary *dic in arr) {
            
            Essence * essence = [[Essence alloc] init];
            
            if (dic[@"uId"]){
                essence.essenceType = userEssence;
                essence.essenceID = dic[@"uId"];
            }
            
            if (dic[@"aId"]){
                essence.essenceType = activityEssence;
                essence.essenceID = dic[@"activityOwnerId"];
                essence.essenceActivityFollowID = dic[@"aId"];
            }
            
            essence.inrerests = [[NSMutableArray alloc] init];
            [self.parseArray  addObject:essence];
            
        }
        
        [self.dictionaryArray addObjectsFromArray:arr];
    }
    [self stopHeader]; // Stop heider
    
}
/*!
 *  @discussion  Method uploads Array this all data by drop up scroll
 *  @return: Array of Array this all data
*/
-(void)uploadAll{
    
    if(!self.allFineshed){
        self.totalNumberOfAllSection = self.totalNumberOfAllSection + self.uploadCountOfAllSection ;
        NSArray *arr = [Server mainPage:[[emsGlobalLocationServer sharedInstance] latitude]
                                andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                               andStart:[NSString stringWithFormat: @"%ld", (long)self.totalNumberOfAllSection]
                               andLimit:[NSString stringWithFormat: @"%ld", (long)self.uploadCountOfAllSection]];
        
        if ([arr count]==0) {
            self.allFineshed = YES;
            [self stopFooter];
            
            return;
        }
        
        for (NSDictionary *dic in arr) {
            
            Essence * essence = [[Essence alloc] init];
            
            if (dic[@"uId"]){
                essence.essenceType = userEssence;
                essence.essenceID = dic[@"uId"];
            }
            
            if (dic[@"aId"]){
                essence.essenceType = activityEssence;
                essence.essenceID = dic[@"activityOwnerId"];
                essence.essenceActivityFollowID = dic[@"aId"];
            }
            
            [self.parseArray  addObject:essence];
            
        }
        [self.dictionaryArray addObjectsFromArray:arr];
        [self reloadTableView];
    }
    
    [self stopFooter];
    
}
/*!
 *  @discussion  Method uploads Activities Array by drop up scroll
 *  @return: Array of Activities
*/

-(void)uploadActivity{
    
    if(!self.activityFineshed){
        
        self.totalNumberOfActivity = self.totalNumberOfActivity + self.uploadCountOfActivity ;
        NSArray *arr = [Server activities:[[emsGlobalLocationServer sharedInstance] latitude]
                                  andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                                 andStart:[NSString stringWithFormat: @"%ld", (long)self.totalNumberOfActivity]
                                 andLimit:[NSString stringWithFormat: @"%ld", (long)self.uploadCountOfAllSection]];
        
        if ([arr count]==0) {
            self.activityFineshed = YES;
            [self stopFooter];
            
            
            return;
        }
        
        for (NSDictionary *dic in arr) {
            
            Essence * essence = [[Essence alloc] init];
            if (dic[@"uId"]){
                essence.essenceType = userEssence;
                essence.essenceID = dic[@"uId"];
            }
            if (dic[@"aId"]){
                essence.essenceType = activityEssence;
                essence.essenceID = dic[@"activityOwnerId"];
                essence.essenceActivityFollowID = dic[@"aId"];
            }
            [self.parseArray  addObject:essence];
        }
        
        [self.dictionaryArray addObjectsFromArray:arr];
        [self reloadTableView];
    }
    [self stopFooter];
}

/*!
 *  @discussion  Method updates Activities Array by drop down scroll
 *  @return: Array of Activities
*/
-(void)updateActivity{
    
    NSArray *arr = [Server activities:[[emsGlobalLocationServer sharedInstance] latitude]
                              andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                             andStart:@"0"
                             andLimit:[NSString stringWithFormat: @"%ld", (unsigned long)[self.parseArray count]]];
    
    [self.parseArray removeAllObjects];
    [self.dictionaryArray removeAllObjects];
    for (NSDictionary *dic in arr) {
        
        Essence * essence = [[Essence alloc] init];
        if (dic[@"uId"]){
            essence.essenceType = userEssence;
            essence.essenceID = dic[@"uId"];
        }
        
        if (dic[@"aId"]){
            essence.essenceType = activityEssence;
            essence.essenceID = dic[@"activityOwnerId"];
            essence.essenceActivityFollowID = dic[@"aId"];
        }
        
        essence.inrerests = [[NSMutableArray alloc] init];
        [self.parseArray  addObject:essence];
        
    }
    
    [self.dictionaryArray addObjectsFromArray:arr];
    [self stopHeader];// Stop heider
}



/*!
 *  @discussion  Method uploads Single users Array by drop up scroll
 *  @return: Array of Single users
*/

-(void)uploadSingle{
    
    if(!self.singleFineshed){
        
        self.totalNumberOfSingle = self.totalNumberOfSingle + self.uploadCountOfSingle ;
        NSArray *arr =  [Server interests:[[emsGlobalLocationServer sharedInstance] latitude]
                                  andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                                andGender:@"0"
                                 andStart:[NSString stringWithFormat: @"%ld", (long)self.totalNumberOfSingle]
                                 andLimit:[NSString stringWithFormat: @"%ld", (long)self.uploadCountOfSingle]];
        
        if ([arr count]==0) {
            self.singleFineshed = YES;
            
            [self stopFooter];
            
            return;
            
        }
        
        for (NSDictionary *dic in arr) {
            
            Essence * essence = [[Essence alloc] init];
            if (dic[@"uId"]){
                essence.essenceType = userEssence;
                essence.essenceID = dic[@"uId"];
            }
            
            if (dic[@"aId"]){
                essence.essenceType = activityEssence;
                essence.essenceID = dic[@"activityOwnerId"];
                essence.essenceActivityFollowID = dic[@"aId"];
            }
            
            [self.parseArray  addObject:essence];
            
        }
        
        
        [self.dictionaryArray addObjectsFromArray:arr];
        [self reloadTableView];
    }
    
    [self stopFooter];
}
/*!
 *  @discussion  Method updates Single users Array by drop down scroll
 *  @return: Array of Single users
*/

-(void)updateSingle{
    
    
    NSArray *arr =  [Server interests:[[emsGlobalLocationServer sharedInstance] latitude]
                              andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                            andGender:@"0"
                             andStart:@"0"
                             andLimit:[NSString stringWithFormat: @"%ld", (unsigned long)[self.parseArray count]]];
    
    if(arr.count>0)
    {
        [self.parseArray removeAllObjects];
        [self.dictionaryArray removeAllObjects];
        for (NSDictionary *dic in arr) {
            
            Essence * essence = [[Essence alloc] init];
            
            if (dic[@"uId"]){
                essence.essenceType = userEssence;
                essence.essenceID = dic[@"uId"];
            }
            
            if (dic[@"aId"]){
                essence.essenceType = activityEssence;
                essence.essenceID = dic[@"activityOwnerId"];
                essence.essenceActivityFollowID = dic[@"aId"];
            }
            
            essence.inrerests = [[NSMutableArray alloc] init];
            
            [self.parseArray  addObject:essence];
            
        }
        
        [self.dictionaryArray addObjectsFromArray:arr];
    }
    [self stopHeader]; // Стоп для Хидера
    
}


/*!
 *  @discussion  Method uploads Interests Array by drop up scroll
 *  @return: Array of Interests
*/
-(void)uploadInterests{
    
    if(!self.interestsFineshed){
        
        self.totalNumberOfInterests = self.totalNumberOfInterests + self.uploadCountOfInterests ;
        
        
        NSArray *arr = [Server interests:[[emsGlobalLocationServer sharedInstance] latitude]
                                 andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                               andGender:@"0"
                                andStart:[NSString stringWithFormat: @"%ld", (long)self.totalNumberOfInterests]
                                andLimit:[NSString stringWithFormat: @"%ld", (long)self.uploadCountOfInterests]];
        
        if ([arr count]==0) {
            self.interestsFineshed = YES;
            [self stopFooter];
            return;
        }
        
        for (NSDictionary *dic in arr) {
            
            Essence * essence = [[Essence alloc] init];
            
            if (dic[@"uId"]){
                essence.essenceType = userEssence;
                essence.essenceID = dic[@"uId"];
            }
            
            if (dic[@"aId"]){
                essence.essenceType = activityEssence;
                essence.essenceID = dic[@"activityOwnerId"];
                essence.essenceActivityFollowID = dic[@"aId"];
            }
            
            [self.parseArray  addObject:essence];
            
        }
        
        
        [self.dictionaryArray addObjectsFromArray:arr];
        
        [self reloadTableView];
    }
    
    [self stopFooter];
    
}

/*!
 *  @discussion  Method updates Interests Array by drop down scroll
 *  @return: Array of Interests
*/

-(void)updateInterests{
    
    
    NSArray *arr = [Server interests:[[emsGlobalLocationServer sharedInstance] latitude]
                             andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                           andGender:@"0"
                            andStart:@"0"
                            andLimit:[NSString stringWithFormat: @"%ld", (unsigned long)[self.parseArray count]]];
    if ([arr count]==0) {
        
        
        [self.parseArray removeAllObjects];
        [self.dictionaryArray removeAllObjects];
        for (NSDictionary *dic in arr) {
            
            Essence * essence = [[Essence alloc] init];
            
            if (dic[@"uId"]){
                essence.essenceType = userEssence;
                essence.essenceID = dic[@"uId"];
            }
            
            if (dic[@"aId"]){
                essence.essenceType = activityEssence;
                essence.essenceID = dic[@"activityOwnerId"];
                essence.essenceActivityFollowID = dic[@"aId"];
            }
            
            essence.inrerests = [[NSMutableArray alloc] init];
            
            [self.parseArray  addObject:essence];
            
        }
        
        [self.dictionaryArray addObjectsFromArray:arr];
        
    }
    [self stopHeader]; // Stop heider
}



/*!
 *  @discussion  Method uploads Rewards Array by drop up scroll
 *  @return: Array of Rewards
*/

-(void)uploadRewards{
    
    if(!self.rewardsFineshed){
        
        self.totalNumberOfRewards = self.totalNumberOfRewards + self.uploadCountOfRewards ;
        
        
        NSArray *arr = [Server rewards:[[emsGlobalLocationServer sharedInstance] latitude]
                               andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                              andStart:[NSString stringWithFormat: @"%ld", (long)self.totalNumberOfRewards]
                              andLimit:[NSString stringWithFormat: @"%ld", (long)self.uploadCountOfRewards]];
        
        if ([arr count]==0) {
            self.rewardsFineshed = YES;
            [self stopFooter];
            return;
            
        }
        
        for (NSDictionary *dic in arr) {
            
            Essence * essence = [[Essence alloc] init];
            
            if (dic[@"uId"]){
                essence.essenceType = userEssence;
                essence.essenceID = dic[@"uId"];
            }
            
            if (dic[@"aId"]){
                essence.essenceType = activityEssence;
                essence.essenceID = dic[@"activityOwnerId"];
                essence.essenceActivityFollowID = dic[@"aId"];
            }
            
            [self.parseArray  addObject:essence];
            
        }
        
        [self.dictionaryArray addObjectsFromArray:arr];
        
        [self reloadTableView];
    }
    
    [self stopFooter];
    
    
}


/*!
 *  @discussion  Method updates Rewards Array by drop down scroll
 *  @return: Array of Rewards
*/

-(void)updateRewards{
    
    NSArray *arr = [Server rewards:[[emsGlobalLocationServer sharedInstance] latitude]
                           andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                          andStart:@"0"
                          andLimit:[NSString stringWithFormat: @"%ld", (unsigned long)[self.parseArray count]]];
    
    
    [self.parseArray removeAllObjects];
    [self.dictionaryArray removeAllObjects];
    
    for (NSDictionary *dic in arr) {
        
        Essence * essence = [[Essence alloc] init];
        
        if (dic[@"uId"]){
            essence.essenceType = userEssence;
            essence.essenceID = dic[@"uId"];
        }
        
        if (dic[@"aId"]){
            essence.essenceType = activityEssence;
            essence.essenceID = dic[@"activityOwnerId"];
            essence.essenceActivityFollowID = dic[@"aId"];
        }
        
        essence.inrerests = [[NSMutableArray alloc] init];
        
        [self.parseArray  addObject:essence];
        
    }

    [self.dictionaryArray addObjectsFromArray:arr];
    [self stopHeader]; // Stop heider
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


/*!
 *  @discussion  Method sets Users Array for each crass interest
 *  @return: Essence object with Interest object as a NSObject
*/

-(void)setUpNotifications:(Essence *)essence andInterests:(NSArray *)interests{
    
    [essence.inrerests removeAllObjects];
    
    for (NSString *dic in interests) {
        
        NSDictionary *dic1 = [interests valueForKey:dic];
        
        Interest * interest =  [[Interest alloc] init];
        
        interest.usersByInterests = [[NSMutableArray alloc] init];
        
        interest.interestImageURL =[dic1 objectForKey:@"interestImg"];
        
        NSArray *dic2 =  [dic1 objectForKey:@"crossUsers"];//Users Array for each crass interest
        
        for (NSDictionary *dic3 in dic2) {
            
            User *user = [[User alloc] init];
            user.image =[dic3 objectForKey:@"userImg"];
            user.name =[dic3 objectForKey:@"username"];
            user.userId =[dic3 objectForKey:@"uId"];
            user.activities =[dic3 objectForKey:@"interestsStr"];
            [interest.usersByInterests addObject:user];
        }
        
        [essence.inrerests addObject:interest];
    }
    
}
/*!
 * @discussion  check whether image with path @param path cached or not.
 * If cached. add image to target else returns NO to start download
 * @param imageView image view to add retrived from cache image
 * @param path path to image
 */
-(BOOL)imageHandlerInterest:(NSString*)path andInterestView:(UIImageView *)imageView
{
    
    
    UIImage *image = [[[ABStoreManager sharedManager] imageCache] objectForKey:path];
    if(image)
    {
        imageView.image = image;
        
        return YES;
    }
    
    imageView.image = [UIImage imageNamed:@"placeholder"];
    
    return NO;
}
/*!
 * @discussion to download image by path and set image to appropriate image view
 * @param coverUrl absolute path to image
 * @param targetView set image here after download is complete
 * @param imageName we use it as a unique key to save image in cache
 */
-(void)downloadImage:(NSString *)coverUrl andIndicator:(UIActivityIndicatorView*)indicator addToImageView:(UIImageView*)targetView andImageName:(NSString*)imageName{
    __block UIImage *image = [UIImage new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:coverUrl]];
        image  = [UIImage imageWithData:imageData];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [indicator stopAnimating];
            if (image == nil) {
                
                targetView.image = [UIImage imageNamed:@"placeholder"];
                
            }else{
                targetView.image = image;
                if(image!=nil){
                    [[[ABStoreManager sharedManager] imageCache] setObject:image forKey:imageName];
                }
                
            }
            
        });
    });
    
}
/*!
 *  @discussion UIAlertView delegate
*/

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    if (alertView.tag == 123) {
        
        if (buttonIndex == 1) {
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ActivityBuilder_4" bundle:nil];
            ActivityGeneralViewController *dreamShot = [storyboard instantiateViewControllerWithIdentifier:@"ActivityGeneralViewController"];
            [self presentViewController:dreamShot animated:YES completion:^{
                
            }];
            
        }
        
        
    }else{
        
        
        if (buttonIndex == 1) {
            
            Essence *essence = [self.parseArray objectAtIndex:indexForDeletingUser];
            
            
            if (essence.essenceType == userEssence) {
                [Server deleteUser:essence.essenceID callback:^{
                    
                    if (indexForDeletingUser == selectedNumber) {
                        selectedNumber = -1;
                    }
                    if (indexForDeletingUser < selectedNumber ) {
                        selectedNumber = selectedNumber-1;
                        indefPathCurrenScroll = indefPathCurrenScroll -1;
                    }
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexForDeletingUser inSection:0];
                    [self.parseArray removeObjectAtIndex:indexForDeletingUser];
                    [self.dictionaryArray removeObjectAtIndex:indexForDeletingUser];
                    [self.table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]  withRowAnimation:UITableViewRowAnimationLeft];
                    [self.table performSelector:@selector(reloadData) withObject:nil afterDelay:0.35];
                    
                }];
            }
            
            if (essence.essenceType == activityEssence) {
                
                [Server hideActivity:essence.essenceID callback:^{
                    
                    if (indexForDeletingUser == selectedNumber) {
                        selectedNumber = -1;
                    }
                    if (indexForDeletingUser < selectedNumber ) {
                        selectedNumber = selectedNumber-1;
                        indefPathCurrenScroll = indefPathCurrenScroll -1;
                    }
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexForDeletingUser inSection:0];
                    [self.parseArray removeObjectAtIndex:indexForDeletingUser];
                    [self.dictionaryArray removeObjectAtIndex:indexForDeletingUser];
                    [self.table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]  withRowAnimation:UITableViewRowAnimationLeft];
                    [self.table performSelector:@selector(reloadData) withObject:nil afterDelay:0.35];
                    
                }];
            }
            
        }
        
    }
}

/*!
 *  @discussion Sets Popup Custom Progress bar with blured background and Scadaddle
*/
-(void)updationLocationThread
{
    
    popup = [[ScadaddlePopup alloc] initWithFrame:self.view.frame withTitle:@"Loading location..." withProgress:YES andButtonsYesNo:NO forTarget:self andMessageType:-1];
    [self.view addSubview:popup];
    
}
-(void)startUpdatingLocation
{
    
    
}
-(void)startUpdating
{
    
}

/*!
 * Remuve progress view from superView
*/
-(void)dismissPopupAction
{
    
    [UIView animateWithDuration:0.01 animations:^{
        
        popup.alpha=0.9;
    } completion:^(BOOL finished) {
        
        [popup removeFromSuperview];
        
    }];
    
    
}
-(IBAction)dismissPopup
{
    
    [self dismissPopupAction];
}

/*!
 * Method called to clean class instances
*/
-(void)clearData{
    
    for (UIView *view in self.view.subviews) {
        [view removeFromSuperview];
    }
    _activityFooter = nil;
    _activityHeader = nil;
    [_parseArray removeAllObjects];
    [_parseArrayUsers removeAllObjects];
    [_dictionaryArray removeAllObjects];
    [_dictionaryArrayAll removeAllObjects];
    [_dictionaryArrayActivities removeAllObjects];
    [_dictionaryArrayInterests removeAllObjects];
    [_dictionaryArraySingle removeAllObjects];
    [_dictionaryArrayRewards removeAllObjects];
    [_essenceArrayFromDictionaryAll removeAllObjects];
    [_essenceArrayFromDictionaryActivities removeAllObjects];
    [_essenceArrayFromDictionaryInterests removeAllObjects];
    [_essenceArrayFromDictionarySingle removeAllObjects];
    [_essenceArrayFromDictionaryRewards removeAllObjects];
    
}


/*!
 * @discussion Method Performs upon pressing on any left menu button
*/
-(void)progressForQuit:(void (^)())callback;{
    
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

-(void)stopSubviewForQuit{
    
    [UIView animateWithDuration:0.5 animations:^{
        subView.alpha = 0;
    } completion:^(BOOL finished) {
        [subView removeFromSuperview];
        subView = nil;
    }];
}



@end
