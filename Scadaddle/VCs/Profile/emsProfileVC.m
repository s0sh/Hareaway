//
//  emsProfileVC.m
//  Scadaddle
//
//  Created by developer on 06/04/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsProfileVC.h"
#import "emsProfileCell.h"
#import "UILabel+UILabel_CustomLable.h"
#import "emsInterestsView.h"
#import "emsActivity.h"
#import "emsRightMenuVC.h"
#import "emsLeftMenuVC.h"
#import "User.h"
#import "Notification.h"
#import "Interest.h"
#import "emsActivity.h"
#import "emsInterestsVC.h"
#import "DSViewController.h"
#import "emsDeviceManager.h"
#import "Constants.h"
#import "emsDataScrollView.h"
#import "ActivityScroll.h"
#import "emsInterestsVC.h"
#import "emsSelectInterestProfile.h"
#import "emsAPIHelper.h"
#import "ABStoreManager.h"
#import "emsTagsScroll.h"
#import "emsInterestsScroll.h"
#import "ScadaddlePopup.h"
#import "emsEditProfileVC.h"
#import "emsMainScreenVC.h"
#import "EnterPhoneNumberViewController.h"
#import "emsScadProgress.h"
#import "UserDataManager.h"
#import "YTPlayerViewController.h"
#import "FBHelper.h"
//#import "emsLoginVC.h"
#import "FBWebLoginViewController.h"

@interface emsProfileVC ()<UITableViewDataSource,UITableViewDelegate,rightMenuDelegate,leftMenudelegate,ActivityScrollDelegate,DataScrollDelegate,UIAlertViewDelegate>{
    emsInterestsView *tmpCard;
    emsInterestsView *oldCard;
    BOOL is_selected;
    IBOutlet UIView *leftMenu;
    IBOutlet UIView *RcontentView;
    IBOutlet UIView *rightMenu;
    IBOutlet UIView *contentView;
    IBOutlet UIView *viewWithScroll;
    BOOL reconculateBusiness;
    //----------------------------
    int indefPathCurrenScroll;
    int selectedInterest;
    int maxIndexUser;
    int abautMeHeight;
    int __block currentUserIndex;
    //--Popup-------------------------
    ScadaddlePopup *popup;
    NSThread *scadaddlePopupThread;
    //--------------------------------
    
    emsScadProgress * subView;
    BOOL is_user_profile;
    BOOL is_first_visit;
    BOOL is_emty_about_me;
    
}
@property(nonatomic, weak)IBOutlet UILabel *titleLable;
@property (nonatomic, weak) IBOutlet UIImageView *bgViewR;
@property (nonatomic, weak) IBOutlet UIImageView *bgView;
@property (nonatomic, weak) IBOutlet UIImageView *blueCircle;
@property (nonatomic, weak) IBOutlet UIImageView *redCircle;
@property(nonatomic, weak)IBOutlet UIScrollView *scrollView;
@property (nonatomic) IBOutlet UIView *bussnesView;
@property(nonatomic, weak)IBOutlet UITableView *intesertsTable;
@property (nonatomic) IBOutlet UIView *cellDiscription;
@property(nonatomic, weak)IBOutlet UIButton *phoneBtn;
@property(nonatomic, weak)IBOutlet UILabel *descriptionLable;
@property(nonatomic, weak)IBOutlet UILabel *needLable;
@property(nonatomic, weak)IBOutlet UILabel *sharedLable;
@property (nonatomic, assign) CFTimeInterval fullRotationDuration UI_APPEARANCE_SELECTOR;
@property(retain,nonatomic)NSMutableArray *interestsArray;
@property(retain,nonatomic)NSMutableArray *interestFill;
@property (assign ,nonatomic)NSInteger currentfill;
@property (assign ,nonatomic)NSInteger currentSelection;
@property(nonatomic, weak)IBOutlet UIButton *addInterests;
@property(nonatomic, weak)IBOutlet UIScrollView *dataScrollView;
@property (nonatomic) IBOutlet UIView *viewForFollowers;
//--
@property(retain,nonatomic)NSMutableDictionary *apiDictionary;
@property(retain,nonatomic)NSMutableArray *interestArray;
@property(retain,nonatomic)NSMutableArray *crossInterstArray;
// ---------------------------------------
@property(nonatomic, weak)IBOutlet UIButton *editProfileBTN;
@property(nonatomic, weak)IBOutlet UILabel *editProfileLbl;
//------------------------------------------

@property (nonatomic) IBOutlet UIView *noUserActivitiesView;
@property(nonatomic, weak)IBOutlet UIButton *goToMainBtn;
@property(nonatomic, weak)IBOutlet UIButton *backButton;
//------------------------------------------

@property (nonatomic) IBOutlet UIView *noUserCrosInterestsView;
@property(nonatomic, weak)IBOutlet UIButton *noUserCrosInterestsViewBtn;
//------------------------------------------
@property(nonatomic, weak)IBOutlet UIButton *varificationBTN;;
@property(nonatomic, weak)IBOutlet UIButton *followUser;
@property(nonatomic, weak)IBOutlet UIButton *declineUser;
@property(nonatomic, weak)IBOutlet UIImageView *spectatorInterestsImage;
@property(nonatomic, weak)IBOutlet UIImageView *participantInterestsImage;
@property(nonatomic, weak)IBOutlet UIImageView *aboutImage;
@property(nonatomic, weak)IBOutlet UIImageView *activitiesProfileImage;
@property(nonatomic, weak)IBOutlet UIImageView *comentsImage;
//-webView
@property (nonatomic) IBOutlet UIView *viewThisWebView;
@property(nonatomic, weak)IBOutlet UIButton *doneBtnWebView;
@property(nonatomic, weak)IBOutlet UIWebView *webView;

@end

@implementation emsProfileVC

# define oneInterestOffset -119
# define twoInterestsOffset -92
# define threeInteresOffset - 75
# define fourInterestsOffset - 44
# define fiveInterestsOffset -15

#define  KmainScreen      [UIScreen mainScreen].applicationFrame.size.height
#define  KmainScreenWidth   [UIScreen mainScreen].applicationFrame.size.width
#define  KStringForrmat [NSString stringWithFormat:@"{%f,%f}",KmainScreenWidth,KmainScreen ]

/*!
 *  @discussion  Method sets view for webview
*/

-(void)setViewPicker{
    CGRect frame = self.viewThisWebView.frame;
    frame.origin.y =1200;
    self.viewThisWebView.frame = frame;
    [self.view addSubview:self.viewThisWebView];
}


-(void)viewDidDisappear:(BOOL)animated{
    
    for (UIView *view in self.scrollView.subviews) {
        if ([view isKindOfClass:[emsInterestsScroll class]] || [view isKindOfClass:[emsDataScrollView class]] || [view isKindOfClass:[ActivityScroll class]]) {
            [view removeFromSuperview];
        }
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [self progress];
}

/*!
 *
 * @discussion Method Show progress view under superView
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
 * @discussion Method Remove progress view from superView
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
 * @discussion to download image by path and set image to appropriate image view
 * @param coverUrl absolute path to image
 * @param targetView set image here after download is complete
 * @param imageName we use it as a unique key to save image in cache
 */
-(void)downloadImage:(NSString *)coverUrl andIndicator:(UIActivityIndicatorView*)indicator addToImageView:(UIImageView*)targetView andImageName:(NSString*)imageName{
    UIImage *image = [UIImage new];
    
    NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:coverUrl]];
    image  = [UIImage imageWithData:imageData];
    targetView.image = image;
    [indicator stopAnimating];
    if (image == nil) {
        
        targetView.image = [UIImage imageNamed:@"placeholder"];
        
    }else{
        
        if(image){
            [[[ABStoreManager sharedManager] imageCache] setObject:image forKey:imageName];
        }
    }
}
/*!
 * @discussion  check whether image with path @param path cached or not.
 * If cached. add image to target else returns NO to start download
 * @param imageView image view to add retrieved from cache image
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

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:YES];
    
    
    if (self.profileUserId == nil) {
        /*!
         *  if user profile
        */
        self.participantInterestsImage.image = [UIImage imageNamed:@"my_participant_interests_text"];
        self.aboutImage.image = [UIImage imageNamed:@"about_me_text"];
        self.activitiesProfileImage.image = [UIImage imageNamed:@"my_activities_text"];
        self.comentsImage.image = [UIImage imageNamed:@"my_connects_text"];
        //
        
        self.apiDictionary  = (NSMutableDictionary *)[Server profile];
        [self.phoneBtn setTitle:@"PHONE VIRIFICATION" forState:UIControlStateNormal];
        [self.phoneBtn addTarget:self action:@selector(varification:) forControlEvents:UIControlEventTouchUpInside];
        self.editProfileBTN.hidden = NO;
    }else{
        is_user_profile = YES;
        /*!
         *  if your  profile
        */
        self.participantInterestsImage.image = [UIImage imageNamed:@"participant_interests_text"];
        self.aboutImage.image = [UIImage imageNamed:@"about_text"];
        self.activitiesProfileImage.image = [UIImage imageNamed:@"activities_text"];
        self.comentsImage.image = [UIImage imageNamed:@"connects_text"];
        //
        self.spectatorInterestsImage.hidden = YES;
        self.apiDictionary  = (NSMutableDictionary *)[Server profileInfoandUserID:self.profileUserId];
        [self.phoneBtn setTitle:@"SEE FACEBOOK PAGE" forState:UIControlStateNormal];
        [self.phoneBtn addTarget:self action:@selector(showFacebook) forControlEvents:UIControlEventTouchUpInside];
        self.editProfileBTN.hidden = YES;
        self.editProfileLbl.hidden = YES;
        self.backButton.hidden = NO;
        [self setViewPicker];
        self.followUser.hidden = NO;
        self.declineUser.hidden = NO;
    
        if ([[[ self.apiDictionary objectForKey:@"friendStatus"] stringValue] isEqualToString:@"10"]) {
            
            self.declineUser.hidden = NO;
            self.declineUser.frame = CGRectMake(self.declineUser.frame.origin.x + 34, self.declineUser.frame.origin.y, self.declineUser.frame.size.width, self.declineUser.frame.size.height);
            self.followUser.hidden = YES;
        }
        
        if ([[[ self.apiDictionary objectForKey:@"friendStatus"] stringValue] isEqualToString:@"11"]) {
            /*!
             *  hides  delete button
            */
            self.declineUser.hidden = NO;
            self.declineUser.frame = CGRectMake(self.declineUser.frame.origin.x + 24, self.declineUser.frame.origin.y, self.declineUser.frame.size.width, self.declineUser.frame.size.height);
            self.followUser.hidden = YES;
        }
        
        if ([[[ self.apiDictionary objectForKey:@"friendStatus"] stringValue] isEqualToString:@"44"]
            || [[[ self.apiDictionary objectForKey:@"friendStatus"] stringValue] isEqualToString:@"22"]
            || [[[ self.apiDictionary objectForKey:@"friendStatus"] stringValue] isEqualToString:@"2"]
            || [[[ self.apiDictionary objectForKey:@"friendStatus"] stringValue] isEqualToString:@"3"]
            || [[[ self.apiDictionary objectForKey:@"friendStatus"] stringValue] isEqualToString:@"33"]) {
            /*!
             *  hides follow / delete buttons
            */
            self.followUser.hidden = YES;
            self.declineUser.hidden = YES;
        }
        
        NSString *idUser = [NSString stringWithFormat:@"%@",[[UserDataManager sharedManager] getSavedUser][@"id"]];
        
        NSString *myUser = [NSString stringWithFormat:@"%@",[[ self.apiDictionary objectForKey:@"uId"] stringValue]];
        
        if ([myUser isEqualToString:idUser]) {
            /*!
             *  if your own profile
            */
            self.followUser.hidden = YES;
            self.declineUser.hidden = YES;
        }
    }
    
    NSString *str =self.apiDictionary[@"about"];
    
    if (str.length == 0||[str isEqualToString:@" "]||[str isEqualToString:@"null"] || str ==nil) {
        is_emty_about_me = YES;
        
    }
    
    self.crossInterstArray = self.apiDictionary[@"crossInterests"];
    if (![self.crossInterstArray count]) {
        /*!
         *  checks cross array
        */
        self.addInterests.hidden = NO;
        [UIView animateWithDuration:.3
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             if (self.profileUserId != nil) {
                                 
                                 self.noUserCrosInterestsView.hidden = NO;
                                 if (self.profileUserId != nil) {
                                     self.noUserCrosInterestsViewBtn.hidden = YES;
                                 }
                                 
                             }else{
                                 self.viewForFollowers.hidden = NO;
                             }
                             self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height+68);
                             
                             [self.bussnesView setFrame:CGRectMake(self.bussnesView.frame.origin.x, self.bussnesView.frame.origin.y + 72, self.bussnesView.frame.size.width, self.bussnesView.frame.size.height)];
                         }
                         completion:^(BOOL finished){
                             
                         }];
        
    }
    
    [self setUpInteres];
    self.phoneBtn .layer.cornerRadius = 2;
    self.phoneBtn.layer.masksToBounds = YES;
    
    [self _rotateImageViewFrom:0.0f to:M_PI*2 duration:self.fullRotationDuration repeatCount:HUGE_VALF];
    self.intesertsTable.transform =  CGAffineTransformMakeRotation(-(M_PI/2));
    
    [self picData];
    
    //----
    indefPathCurrenScroll = 0;
    selectedInterest = -1;
    currentUserIndex = 0;
    
    /*!
     * adds emsDataScrollView
    */
    
    emsDataScrollView *dataScrollView = [[emsDataScrollView alloc] initWithFrame:CGRectMake(0, 60,351, 149) andData:self.apiDictionary[@"files"] andName:self.apiDictionary[@"name"] andInterestImage:self.apiDictionary[@"primaryInterestsImg"] andFollowings:self.apiDictionary[@"followersCount"] andAge:self.apiDictionary[@"age"]];
    [dataScrollView moveInterests];
    dataScrollView.delegate = self;
    [self.scrollView addSubview:dataScrollView];
    
    if (![self.apiDictionary[@"activities"] count] && self.profileUserId != nil) {
        self.noUserActivitiesView.hidden = NO;
        if (self.profileUserId != nil) {
            self.goToMainBtn.hidden = YES;
        }
    }else{
        int emty_about_int = is_emty_about_me?70:0;
        
        /*!
         * adds ActivityScroll
        */
        
        ActivityScroll *activityScroll  = [[ActivityScroll alloc] initWithFrame:CGRectMake(0, is_user_profile?380:454,323, 115) andData:self.apiDictionary[@"activities"] andDelegate:self];
        
        
        activityScroll.frame = CGRectMake(activityScroll.frame.origin.x, activityScroll.frame.origin.y - emty_about_int , activityScroll.frame.size.width, activityScroll.frame.size.height);
        [activityScroll moveInterests];
        if (self.profileUserId != nil) {
            activityScroll.userActivityID =self.profileUserId;
        }
        [self.scrollView addSubview:activityScroll];
    }
    
    if (!is_user_profile) {
        
        /*!
         * adds emsInterestsScroll ()
        */
         emsInterestsScroll *interestsScroll  = [[emsInterestsScroll alloc] initWithFrame:CGRectMake(0, 226,323, 115) andData:self.apiDictionary[@"interestSpectator"] andAnimation:@"r" andUsingType:profileScrolls];
        
        [interestsScroll moveInterests];
        [self.scrollView addSubview:interestsScroll];
        
    }
    
    /*!
     * adds emsInterestsScroll (Spactator)
    */
    emsInterestsScroll *interestsScrollSpactator  = [[emsInterestsScroll alloc] initWithFrame:CGRectMake(0, is_user_profile?226:300,323, 115) andData:self.apiDictionary[@"interestActivity"]andAnimation:@"l" andUsingType:profileScrolls];
    [interestsScrollSpactator moveInterests];
    
    [self.scrollView addSubview:interestsScrollSpactator];
    
    if (self.profileUserId != nil) {
        
        self.titleLable.text = @" User Profile";
    }else{
        self.titleLable.text = @" My Profile";
    }
    
    [self setUpLable:self.apiDictionary[@"about"]];
    
    [self.intesertsTable reloadData];
    
    [self interestsTableAligment];
    
    [self stopSubview];
    
    if (is_user_profile) {
        
        [self scrollUserProfile];
    }
    [self recanculateScroll];
    
    reconculateBusiness = NO;
    
    [tmpCard removeFromSuperview];
    
    tmpCard = nil;
    
    if (is_emty_about_me) {
        
        [self recanculateWhisEmtyAboutME];
        
    }
}

/*!
 *  @discussion  Method sets frame to main scroll recording of input values
*/
-(void)recanculateWhisEmtyAboutME{
    
    self.aboutImage.hidden =YES;
    self.descriptionLable .hidden = YES;
    
    int activitiesProfileImageOfset = is_user_profile ? 292 : 366;
    
    self.activitiesProfileImage.frame = CGRectMake( self.activitiesProfileImage.frame.origin.x , activitiesProfileImageOfset ,  self.activitiesProfileImage.frame.size.width ,  self.activitiesProfileImage.frame.size.height );
    
    int comentsImageOfset = is_user_profile ? 446:516;
    
    self.comentsImage.frame = CGRectMake( self.comentsImage.frame.origin.x, comentsImageOfset , self.comentsImage.frame.size.width, self.comentsImage.frame.size.height);
    
    int intesertsTableOfset = is_user_profile?462:532;
    
    self.intesertsTable.frame = CGRectMake(self.intesertsTable.frame.origin.x, intesertsTableOfset , self.intesertsTable.frame.size.width, self.intesertsTable.frame.size.height);
    int noUserActivitiesViewOfset = is_user_profile?314:384;
    
    self.noUserActivitiesView.frame = CGRectMake( self.noUserActivitiesView.frame.origin.x, noUserActivitiesViewOfset,  self.noUserActivitiesView.frame.size.width, self.noUserActivitiesView.frame.size.height);
    
    
    int viewForFollowersOfset = is_user_profile ? 462:532;
    
    self.viewForFollowers.frame = CGRectMake(self.viewForFollowers.frame.origin.x, viewForFollowersOfset, self.viewForFollowers.frame.size.width, self.viewForFollowers.frame.size.height);
    
    int noUserCrosInterestsViewOfset = is_user_profile ? 466:602;
    
    self.noUserCrosInterestsView.frame = CGRectMake(self.noUserCrosInterestsView.frame.origin.x, noUserCrosInterestsViewOfset, self.noUserCrosInterestsView.frame.size.width,  self.noUserCrosInterestsView.frame.size.height);
    
    int bussnesViewOfset = is_user_profile ? 504 : self.bussnesView.frame.origin.y - 70;
    
    self.bussnesView.frame = CGRectMake(self.bussnesView.frame.origin.x, bussnesViewOfset, self.bussnesView.frame.size.width,  self.bussnesView.frame.size.height);
    
    int scrollViewContentSizeOfset = is_user_profile ? 696 : 766;
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width ,  scrollViewContentSizeOfset);
}
/*!
 *  @discussion  Method sets User Profile scroll
*/
-(void)scrollUserProfile{
    
    if (is_first_visit) {
        
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width,self.scrollView.contentSize.height - 74 )];
        self.spectatorInterestsImage.hidden = YES;
        
        for (UIView *vw in [self.scrollView subviews]) {
            
            
            if ([vw isKindOfClass:[UIView class]]) {
                
                if (![vw isKindOfClass:[emsDataScrollView class]] && vw!=self.backButton && vw!=self.followUser  && vw!=self.declineUser && vw!=self.titleLable && ![vw isKindOfClass:[ActivityScroll class]] && ![vw isKindOfClass:[emsInterestsScroll class]]) {
                    
                    
                    CGRect rc = [vw frame];
                    
                    [vw setFrame:CGRectMake(rc.origin.x, rc.origin.y - 74, rc.size.width, rc.size.height)];
                    
                }
            }
            is_first_visit = NO;
        }
    }
}


/*!
 *  @discussion  Method sets frame to interests view
*/
-(void)interestsTableAligment{
    
    int ofsetDevider = (int)[self.crossInterstArray count];
    
    if (ofsetDevider==1) {
        [self.intesertsTable setContentOffset:CGPointMake(0, oneInterestOffset ) animated:YES];
    }
    if (ofsetDevider==2) {
        [self.intesertsTable setContentOffset:CGPointMake(0, twoInterestsOffset) animated:YES];
    }
    if (ofsetDevider==3) {
        [self.intesertsTable setContentOffset:CGPointMake(0, threeInteresOffset) animated:YES];
    }
    if (ofsetDevider==4) {
        [self.intesertsTable setContentOffset:CGPointMake(0, fourInterestsOffset) animated:YES];
    }
    if (ofsetDevider==5) {
        [self.intesertsTable setContentOffset:CGPointMake(0, fiveInterestsOffset) animated:YES];
    }
}


-(void)dealloc{
    
    NSLog(@"%@ dealloc", self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    reconculateBusiness = NO;
    is_first_visit = YES;
    self.apiDictionary = [[NSMutableDictionary alloc] init];
    self. crossInterstArray = [[NSMutableArray alloc] init];
    [self setScroll];
}

/*!
 *  @discussion  Method sets interests array
*/
-(void)setUpInteres{
    
    self.interestArray = [[NSMutableArray alloc]init];
    
    for (NSString *dic in self.crossInterstArray) {
        
        NSDictionary *dic1 = [self.crossInterstArray valueForKey:dic];
        
        Interest * interest =  [[Interest alloc] init];
        
        interest.usersByInterests = [[NSMutableArray alloc] init];
        
        interest.interestImageURL =[dic1 objectForKey:@"interestImg"];
        
        NSArray *dic2 =  [dic1 objectForKey:@"crossUsers"];// масси пользователей по каждому кружечку
        
        for (NSDictionary *dic3 in dic2) {
            
            User *user = [[User alloc] init];
            user.image =[dic3 objectForKey:@"userImg"];
            user.name =[dic3 objectForKey:@"username"];
            user.userId =[dic3 objectForKey:@"uId"];
            user.activities =[dic3 objectForKey:@"interestsStr"];
            [interest.usersByInterests addObject:user];
            
        }
        
        [_interestArray addObject:interest];
    }
    
}

-(void)setUpInterest{
    
    self.interestsArray = [[NSMutableArray alloc] init];
    for (int i = 0 ; i <=10 ; i++) {
        Interest * interest = [[Interest alloc] init];
        [self.interestsArray addObject:interest];
    }
    
}
/*!
 *  @discussion  Method sets lable text
*/

-(void)setUpLable:(NSString *)description{
    
    NSString *txt = description;
    
    [self.descriptionLable setText:[NSString stringWithFormat:@"%@",txt]];
    
}

/*!
 *  @discussion  Method sets view for users
*/
-(void)picData{
    
    self.cellDiscription.frame =CGRectZero;
    self.cellDiscription.hidden = YES;
    [self.scrollView addSubview:self.cellDiscription];
    
}
/*!
 *  @discussion  Method sets main scroll
*/
-(void)setScroll{
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width,self.scrollView.frame.size.height)];
    [self.scrollView setFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.view.frame.size.height)];
    [viewWithScroll addSubview:self.scrollView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*!
 *  @discussion  Method leafs view this users to the left
*/
- (IBAction)nextWordAction{
    
    if (currentUserIndex >= 0) {
        emsInterestsView *newCard = [self getCard];
        newCard.frame = kNewCardFrame;
        [self.cellDiscription addSubview:newCard];
        
        [UIView animateWithDuration:.3 animations:^{
            
            if (tmpCard != nil) {
                tmpCard.frame = kNewCardFrameTransition ;
                tmpCard.alpha = 0.5;
            }
            
            newCard.frame = kNewCardFrameTransitionDone;
            
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
 *  @discussion  scrollView delegate
*/

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    if (scrollView == self.intesertsTable) {
        if (is_selected) {
            is_selected=NO;
            [self recanculateScroll];
            reconculateBusiness = NO;
            [UIView animateWithDuration:.5
                                  delay:0.0
                                options: UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 
                                 self.cellDiscription.alpha = 0.0;
                                 [self.cellDiscription setFrame:CGRectMake(self.intesertsTable.frame.origin.x, self.intesertsTable.frame.origin.y - 60, self.intesertsTable.frame.size.width, 85)];
                             }
                             completion:^(BOOL finished){
                                 
                                 [tmpCard removeFromSuperview];
                                 
                                 tmpCard = nil;
                             }];
            
            
        }
    }
}
/*!
 *  @discussion  Method leafs view this users to the right
*/
- (IBAction)nextRihgt{
    
    if (currentUserIndex < maxIndexUser) {
        emsInterestsView *newCard = [self getCard];
        
        newCard.frame = kNewCardFrameTransition;
        newCard.alpha = 0;
        [self.cellDiscription addSubview:newCard];
        
        [UIView animateWithDuration:.4 animations:^{
            
            if (tmpCard != nil) {
                tmpCard.frame = kNewCardFrameTransitionRihgt;
                tmpCard.alpha = 0.5;
            }
            
            newCard.frame = kNewCardFrameTransitionDone;
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
 *  @discussion  Method gets Users from cross interests Array
 *  @return: an emsInterestsView  as a UIView
*/
- (emsInterestsView *)getCard{
    
    Interest * interest =[self.interestArray objectAtIndex:selectedInterest];
    
    User *user =(User *)[interest.usersByInterests objectAtIndex:currentUserIndex];
    
    emsInterestsView *newCard = [[emsInterestsView alloc] initWithWord:@"Profile" andUser:user andImage:interest.interestImage andUrl:user.imageURL result:^(BOOL bl) {
        
        if (bl) {
            currentUserIndex --;
            [self nextWordAction];
        }
        if (!bl) {
            currentUserIndex ++;
            [self nextRihgt];
        }
        
    } cellBlock:^(BOOL bl) {
        
    }userBlock:^(User *user) {
        
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


# pragma mark tableView

/*!
 *  @discussion tableView delegates
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return  [self.crossInterstArray count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    emsProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    
    if (!cell) {
        
        NSArray* xibCell = [[NSBundle mainBundle] loadNibNamed:@"emsProfileCell" owner:self options:nil];
        
        cell = [xibCell objectAtIndex:0];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.transform = CGAffineTransformMakeRotation(1.57);
        
        Interest *interest =[self.interestArray objectAtIndex:indexPath.row];
        
        [cell configureCellItemsWithData:interest.interestImageURL];
        
        [self cornerIm:cell.cellInterestView];
        
        if (indexPath.row == 0) {
            cell.line.hidden = YES;
        }
    }
    return  cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 57;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    is_selected = YES;
    
    Interest * interest =[self.interestArray objectAtIndex:indexPath.row];
    
    maxIndexUser = (int)[interest.usersByInterests count];
    
    if (selectedInterest != (int)indexPath.row) {
        /*!
         *  adds users view
         */
        currentUserIndex = 0;
        [tableView setContentOffset:CGPointMake(0, (indexPath.row*57) - 116) animated:YES];
        selectedInterest =  (int)indexPath.row;
        [self nextWordAction];
        self.cellDiscription.hidden = NO;
        self.cellDiscription.alpha = 0;
        [self.cellDiscription setFrame:CGRectMake(self.intesertsTable.frame.origin.x, self.intesertsTable.frame.origin.y+59, self.intesertsTable.frame.size.width, 0)];
        [self recanculateScrollDown ];
        reconculateBusiness =YES;
        
        [UIView animateWithDuration:.1
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             
                             self.cellDiscription.alpha = 1;
                             [self.cellDiscription setFrame:CGRectMake(self.intesertsTable.frame.origin.x, self.intesertsTable.frame.origin.y+59, self.intesertsTable.frame.size.width, 85)];
                         }
                         completion:^(BOOL finished){
                             
                         }];
        
    }else{
        /*!
         *  removes users view
         */
        selectedInterest = -1;
        [self recanculateScroll];
        reconculateBusiness = NO;
        [UIView animateWithDuration:.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             
                             
                             self.cellDiscription.alpha = 0.0;
                             [self.cellDiscription setFrame:CGRectMake(self.intesertsTable.frame.origin.x, self.intesertsTable.frame.origin.y - 60, self.intesertsTable.frame.size.width, 85)];
                         }
                         completion:^(BOOL finished){
                             
                             [tmpCard removeFromSuperview];
                             
                             tmpCard = nil;
                             
                         }];
    }
}



- (void)_rotateImageViewFrom:(CGFloat)fromValue to:(CGFloat)toValue duration:(CFTimeInterval)duration repeatCount:(CGFloat)repeatCount
{
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:fromValue];
    rotationAnimation.toValue = [NSNumber numberWithFloat:toValue];
    rotationAnimation.RepeatCount = repeatCount;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeRemoved;
    rotationAnimation.duration = 1.9;
    [self.blueCircle.layer addAnimation:rotationAnimation forKey:@"rotation"];
    [self.redCircle.layer addAnimation:rotationAnimation forKey:@"rotation"];
}




# pragma Resize Screen
/*!
 *  @discussion Method adds users view
*/
-(void)recanculateScrollDown{
    
    if ( !reconculateBusiness) {
        
        [UIView animateWithDuration:.3
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             
                             self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height+68);
                             
                             [self.bussnesView setFrame:CGRectMake(self.bussnesView.frame.origin.x, self.bussnesView.frame.origin.y + 72, self.bussnesView.frame.size.width, self.bussnesView.frame.size.height)];
                         }
                         completion:^(BOOL finished){
                             
                         }];
        
    }
    
}

/*!
 *  @discussion Method removes users view from superview
*/
-(void)recanculateScroll{
    
    if ( reconculateBusiness) {
        
        [UIView animateWithDuration:.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             
                             self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height-68);
                             [self.bussnesView setFrame:CGRectMake(self.bussnesView.frame.origin.x, self.bussnesView.frame.origin.y - 72, self.bussnesView.frame.size.width, self.bussnesView.frame.size.height)];
                         }
                         completion:^(BOOL finished){
                             
                         }];
    }
}

/*!
 *  @discussion Method sets corner radius to images
*/
-(void)cornerIm:(UIImageView*)imageView{
    imageView .layer.cornerRadius = imageView.frame.size.height/2;
    imageView.layer.masksToBounds = YES;
}
/*!
 *  @discussion Verification phone numbers
*/
-(IBAction)varification:(id)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PhoneVerification" bundle:nil];
    EnterPhoneNumberViewController *phone = [storyboard instantiateViewControllerWithIdentifier:@"PhoneNumber"];
    [self presentViewController:phone animated:YES completion:^{
        
    }];
    
}

-(IBAction)addInterestsAction{
    
    emsInterestsVC *vc = [[emsInterestsVC alloc] init];
    vc.hideBackButton = YES;
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

/*!
 *  @discussion Sets Popup Custom Progress bar with blur background and Scadaddle
*/
-(void)updationLocationThread
{
    
    popup = [[ScadaddlePopup alloc] initWithFrame:self.view.frame withTitle:@"Loading location..." withProgress:YES andButtonsYesNo:NO forTarget:self andMessageType:-1];
    [self.view addSubview:popup];
    
}
-(void)startUpdatingLocation
{
    [NSThread detachNewThreadSelector:@selector(updationLocationThread) toTarget:self withObject:nil];
    
}
-(void)startUpdating
{
    
    popup = [[ScadaddlePopup alloc] initWithFrame:self.view.frame withTitle:@"Loading..." withProgress:YES andButtonsYesNo:NO forTarget:self andMessageType:-1];
    [self.view addSubview:popup];
    
}

/*!
 * Remove progress view from superView
*/
-(IBAction)dismissPopup
{
    
    [self dismissPopupAction];
}
-(void)dismissPopupAction
{
    
    [UIView animateWithDuration:0.01 animations:^{
        
        popup.alpha=0.9;
    } completion:^(BOOL finished) {
        
        [popup removeFromSuperview];
        
    }];
    
}

/*!
 *  @discussion Method presents emsMainScreenVC
*/

-(IBAction)goToMainScreen{
    
    [self presentViewController:[[emsMainScreenVC alloc] init] animated:YES completion:^{
        
    }];
    
}


#pragma Mark rightMenuDelegate

/*!
 *  @discussion Sets up right Menu
*/
-(IBAction)showRightMenu{
    
    emsRightMenuVC *emsRightMenu = [ [emsRightMenuVC alloc] initWithDelegate:self];
    NSLog(@"emsLeftMenu %@",emsRightMenu.delegate);
}
/*!
 *
 * @discussion Method cleans child view controllers
 *
*/
-(void)notificationSelected:(Notification *)notification
{
    [[self.childViewControllers lastObject] willMoveToParentViewController:nil];
    [[[self.childViewControllers lastObject] view] removeFromSuperview];
    [[self.childViewControllers lastObject] removeFromParentViewController];
    
    NSLog(@"notification %lu", (unsigned long)notification);
    
}

#pragma Mark leftMenudelegate

/*!
 *
 *  @discussion Sets up Left Menu
 *
*/
-(IBAction)showLeftMenu{
    emsLeftMenuVC *emsLeftMenu =[[emsLeftMenuVC alloc]initWithDelegate:self ];
    NSLog(@"emsLeftMenu %@",emsLeftMenu.delegate);
}


/*!
 *
 * @discussion Sets up Left Menu
 * @param actionsTypel actions that were chosen
 * @see emsLeftMenuVC
*/
-(void)actionPresed:(ActionsType)actionsTypel complite:(void (^)())complite{
    
    NSLog(@"actionsTypel %lu", (unsigned long)actionsTypel);
    
    
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
 *  back
 *  @discussion Method presents emsEditProfileV
 
*/
-(IBAction)editProfile{
    
    [self presentViewController:[[emsEditProfileVC alloc] initWithData:self.apiDictionary ] animated:YES completion:^{
        
    }];
    
    
}

/*!
 *  back
 *  @discussion Method dismisses self
*/
-(IBAction)back{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

/*!
 *  delUserAction
 *  @discussion Method adds user to followers
*/

-(IBAction)followUserAction{
    
    [Server followUser:self.profileUserId  callback:^{
        
        [UIView animateWithDuration:0.2 animations:^{
            self.followUser.alpha = 0;
            self.declineUser.frame  = self.followUser.frame;
        } completion:^(BOOL finished) {
            
            [[ABStoreManager sharedManager] setneedReloadMainScreen:YES];
            
        }];
        
    }];
}

/*!
 *  delUserAction
 *  @discussion Method deletes user from participant array and from view( in maim screen)
*/

-(IBAction)declineUserAction
{
    
    UIAlertView *warning = [[UIAlertView alloc] initWithTitle:@"Hide User"
                                                      message:@"Are you sure you want to hide this user?"
                                                     delegate:self
                                            cancelButtonTitle:@"CANCEL"
                                            otherButtonTitles:@"OK", nil];
    [warning show];
    
    
}


/*!
 *
 * @discussion alertView delegate
 *
*/
- (void)alertView:(UIAlertController *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 1) {
        
        
        [Server deleteUser:self.profileUserId callback:^{
            
            [UIView animateWithDuration:0.2 animations:^{
                
                self.declineUser.alpha = 0;
            } completion:^(BOOL finished) {
                
                [[ABStoreManager sharedManager] setneedReloadMainScreen:YES];
                
                [self dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }];
            
        }];
        
        
    }
    
}



/*!
 * hideFacebook
 * @discussion Method  hides webView this user facebook page
 *
*/
-(IBAction)hideFacebook{
    
    [UIView animateWithDuration:0.4 animations:^{
        self.viewThisWebView.alpha = 0;
        
    } completion:^(BOOL finished) {
        [self.viewThisWebView removeFromSuperview];
        
    }];
}

/*!
 * setUpWebView
 * @discussion Method  sets webView this user facebook page
 *
*/
-(IBAction)showFacebook{
    [self setUpWebView];
    self.doneBtnWebView.layer.cornerRadius =  2;
    self.doneBtnWebView.layer.masksToBounds = YES;
    self.viewThisWebView.frame = CGRectMake(0, 0 , 320, 500);
    self.viewThisWebView.alpha = 0;
    [self.view addSubview:  self.viewThisWebView];
    
    [UIView animateWithDuration:0.4 animations:^{
        self.viewThisWebView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)setUpWebView{
    
    NSString* url = [NSString stringWithFormat:@"https://www.facebook.com/%@",self.apiDictionary[@"fbId"]];
    NSURL* nsUrl = [NSURL URLWithString:url];
    NSURLRequest* request = [NSURLRequest requestWithURL:nsUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    [self.webView loadRequest:request];
    
}

/*!
 *
 * Method called to clean class instances
 *
*/
-(void)clearData{
    for (UIView *view in self.view.subviews) {// временный dealloc
        [view removeFromSuperview];
    }
    [_apiDictionary removeAllObjects];
    [_crossInterstArray removeAllObjects];
    [_interestArray removeAllObjects];
    [self.webView removeFromSuperview];
    self.webView = nil;
}


/*!
 *
 * @discussion Method Performs upon pressing on any left menu button
 *
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
/*!
 *
 * @discussion Method Performs upon pressing on any left menu button
 *
*/
-(void)stopSubviewForQuit{
    
    [UIView animateWithDuration:0.5 animations:^{
        subView.alpha = 0;
    } completion:^(BOOL finished) {
        [subView removeFromSuperview];
        subView = nil;
    }];
}

@end
