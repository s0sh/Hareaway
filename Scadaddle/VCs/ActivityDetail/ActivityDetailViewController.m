//
//  ActivityDetailViewController.m
//  Scadaddle
//
//  Created by Roman Bigun on 6/22/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "ActivityDetailViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "emsLeftMenuVC.h"
#import "emsMainScreenVC.h"
#import "emsRightMenuVC.h"
#import "emsAPIHelper.h"
#import "emsGlobalLocationServer.h"
#import "ScheduledItemTableViewCell.h"
#import "SchedulerActivityTableViewCell.h"
#import "ABStoreManager.h"
#import "emsProfileVC.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "ActivityGeneralViewController.h"
#import "emsActivityVC.h"
#import "emsScadProgress.h"
#import "YTPlayerViewController.h"
#import "emsDeviceManager.h"
#import "FBHelper.h"
//#import "emsLoginVC.h"
#import "FBWebLoginViewController.h"
#define MEMBERS_TABLE_Y_OFFSET 380
#define MEMBERS_CELL_HEIGHT 65
#define FOOTER_OFFSET_ACCORDING_TO_MEMBERS_COUNT MEMBERS_TABLE_Y_OFFSET

@import AddressBookUI;


@interface ActivityDetailViewController ()<MKMapViewDelegate>
{

    NSArray *activityImagesArray;
    NSMutableArray *scheduledItemsArray;
    NSArray *interestsArray;
    NSDictionary *data;
    NSMutableArray *membersArray;
    NSString *ownerId;
    NSString *currentActivityID;
    activityType aType;
    BOOL footerSettled;
    BOOL canBeMember;
    int curFooterOffset;
    BOOL becomeOnce;
    
    emsScadProgress * subView;
}
@property(nonatomic,retain)IBOutlet UIButton *topRightBtn;
@property(nonatomic,retain)IBOutlet UIButton *topLeftBtn;
@end
@implementation ActivityDetailViewController
@synthesize authorImage,authorNameLbl;

#pragma mark Enter Point

-(id)initWithData:(NSDictionary*)incomeData
{
    self = [super init];
    if(self)
    {
        ownerId = [NSString stringWithFormat:@"%@",incomeData[@"uId"]];
        
        data = [[NSDictionary alloc] initWithDictionary:incomeData[@"activities"]];
        currentActivityID = [[NSString alloc] init];
        currentActivityID = incomeData[@"aId"];
    
        if(data.count==0)
        {
            data = [Server activityDataForID:currentActivityID lat:[[emsGlobalLocationServer sharedInstance] latitude]
                                                               andLong:[[emsGlobalLocationServer sharedInstance] longitude]][@"activities"];
            ownerId = [NSString stringWithFormat:@"%@",data[@"activityOwnerId"]];
            membersArray = [[NSMutableArray alloc] initWithArray:data[@"members"]];
            if(([data[@"activityStatus"] integerValue]==follower ||
                [data[@"activityStatus"] integerValue]==noStatus) &&
                [data[@"placesCount"] integerValue]-[membersArray count]>0 &&
               ![ownerId isEqualToString:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"myid"]]])
            {
                canBeMember = YES;
            }
       }
    
    }
    return self;
}
#pragma mark Initial setup
-(void)viewWillAppear:(BOOL)animated{
    
}
-(void)setDelegates
{
    
    self.activityPhotoScroll.delegate = self;
    self.membersTable.delegate = self;
    self.membersTable.dataSource = self;
    self.scheduledTable.delegate = self;
    self.scheduledTable.dataSource = self;
    self.locationMap.delegate = self;
    self.mainScroll.delegate = self;
}
-(void)initVariables
{
    
    activityImagesArray = [NSArray new];
    scheduledItemsArray = [NSMutableArray new];
    interestsArray = [NSArray new];
    
}
/*!
 * @discussion  Init scheduler items/offsets/other info
 */
-(void)preloadDataWorker
{
    self.authorNameLbl.text = [NSString stringWithFormat:@"%@",data[@"activityOwnerName"]];
    whereAmI =  [[NSString alloc] init];
    NSArray *tmp = [NSArray arrayWithArray:data[@"scheduler"]];
    for(int i=0;i<tmp.count;i++){
        if([tmp[i][@"enable"] integerValue]==1){
            [scheduledItemsArray addObject:tmp[i]];
        }
    }
    self.locationMap.userInteractionEnabled = YES;
    [self loadInfo];
    curFooterOffset = self.footerDinamicView.frame.origin.y+((MEMBERS_CELL_HEIGHT/2)*scheduledItemsArray.count);
    
}
/*!
 * @discussion  Reload activity members info after using option buttons
 * on members cell
 */
-(void)reInitDataAfterUsersActions
{
    data = [Server activityDataForID:currentActivityID lat:[[emsGlobalLocationServer sharedInstance] latitude] andLong:[[emsGlobalLocationServer sharedInstance] longitude]][@"activities"];
    membersArray = [[NSMutableArray alloc] initWithArray:data[@"members"]];
    [self checkMembership];
}
/*!
 * @discussion  Check if current user can be a member of this activity or
 * he is an author and he cannot be a member of self created activity
 */
-(void)checkMembership
{
    if(([data[@"activityStatus"] integerValue]==follower ||
        [data[@"activityStatus"] integerValue]==noStatus)&&
        [data[@"placesCount"] integerValue]-[membersArray count]>0 &&
       ![ownerId isEqualToString:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"myid"]]]){
    
        canBeMember = YES;
    }else{
        canBeMember = NO;
    }

}
-(void)setupSubviews
{
    
    //Main placeholder for all views
    [self.mainScroll setContentSize:CGSizeMake(320,793)];
    //View with members

    self.footerDinamicView.frame = CGRectMake(0,
                                              400+[scheduledItemsArray count]*38,
                                              self.footerDinamicView.frame.size.width,
                                              self.footerDinamicView.frame.size.height);
    
    if([data[@"placesCount"] integerValue]==0 && membersArray.count==0){
        _placesLeftView.alpha=0;
        _membersTable.alpha=0;
        [self.mainScroll setContentSize:CGSizeMake(320, 893+self.
                                                   footerDinamicView.frame.size.height/2+[scheduledItemsArray count]*38)];
    }
    if([data[@"placesCount"] integerValue]>0 && membersArray.count>0)
    {
        _placesLeftView.alpha=1;
        _membersTable.alpha=1;
        [self.mainScroll setContentSize:CGSizeMake(320,
                                                   893+self.footerDinamicView.frame.size.height-400+([scheduledItemsArray count]*38)+
                                                   (membersArray.count>0?membersArray.count*
                                                    60:150)+150+(canBeMember?100:0))];
        
    }
    if([data[@"placesCount"] integerValue]>0 && canBeMember && membersArray.count==0)
    {
        _placesLeftView.alpha=1;
        _membersTable.alpha=1;
        [self.mainScroll setContentSize:CGSizeMake(320,
                                                   893+self.footerDinamicView.frame.size.height-200+[scheduledItemsArray count]*38)];
        
    }
    if([data[@"placesCount"] integerValue]>0 && !canBeMember && membersArray.count==0)
    {
        _placesLeftView.alpha=1;
        _membersTable.alpha=1;
        [self.mainScroll setContentSize:CGSizeMake(320,
                                                   893+self.footerDinamicView.frame.size.height/2+[scheduledItemsArray count]*38)];
    }
    
    [self.mainScroll addSubview:self.footerDinamicView];

}
/*!
 * @discussion  Loads and places author profile image
 */
-(void)setupAuthorAvatar
{
    [self downloadImage:[NSString stringWithFormat:@"%@",data[@"activityOwnerImg"]]
           andIndicator:nil
           addToImageView:self.authorImage];
    
    [self cornerIm:self.authorImage];
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setDelegates];
    [self initVariables];
    [self addProgress];
    [self progress];
    [self preloadDataWorker];
    [self setupAuthorAvatar];
#pragma mark Internet connection checker [Turned off at this moment]
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachability:) name:@"EMSReachableChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gplusDidShare:) name:@"GooglePlusSharedSuccessfull" object:nil];
    
    
    
}
/*!
 * @discussion  Setup buttons states according to status.
 * if user shared activity - button highlighted
 */
-(void)setupSocialsAccordingToStatus
{
    [UIView animateWithDuration:0.5 animations:^{
        self.gPlusBtn.alpha=0.5;
        self.facebookBtn.alpha=0.5;
        self.twitterBtn.alpha=0.5;
        self.instagramBtn.alpha=0.5;
    } completion:^(BOOL finished) {
       
        [UIView animateWithDuration:0.5 animations:^{
            self.gPlusBtn.alpha=1;
            self.facebookBtn.alpha=1;
            self.twitterBtn.alpha=1;
            self.instagramBtn.alpha=1;
        } completion:^(BOOL finished) {
            
            if([[NSUserDefaults standardUserDefaults] objectForKey:@"SCGPlusShared"])
            {
                [self.gPlusBtn setSelected:YES];
                self.gPlusBtn.userInteractionEnabled=NO;
            }
            if([[NSUserDefaults standardUserDefaults] objectForKey:@"SCFacebookShared"])
            {
                [self.facebookBtn setSelected:YES];
                self.facebookBtn.userInteractionEnabled=NO;
            }
            if([[NSUserDefaults standardUserDefaults] objectForKey:@"SCTwitterShared"])
            {
                [self.twitterBtn setSelected:YES];
                self.twitterBtn.userInteractionEnabled=NO;
            }
            
        }];
    }];
    
    

}
-(void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:YES];
    [self startInterestsThread];
    [self startActivitiesThread];
    [self setupMapView];
    [self reInitDataAfterUsersActions];
    [self checkMembership];
    [self setupSubviews];
    [self stopSubview];
   // [self setupSocialsAccordingToStatus];
    
}
-(void)addProgress
{
    
    subView = [[emsScadProgress alloc] initWithFrame:self.view.frame screenView:self.view andSize:CGSizeMake(320, 580)];
    [self.view addSubview:subView];
}
-(void)progress
{
    
    subView.alpha = 1;
    
    
}
-(void)stopSubview{
    
    [UIView animateWithDuration:0.5 animations:^{
        subView.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
    
}
/*!
 * @discussion to download image by path and set image to appropriate image view
 * @param coverUrl absolute path to image
 * @param targetView set image here after download is complete
 */
-(void)downloadImage:(NSString *)coverUrl andIndicator:(UIActivityIndicatorView*)indicator addToImageView:(UIImageView*)targetView{
    
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
                
            }
            
        });
    });
   
}
/*!
 * @discussion  Go to Activity Builder [EditMode]
 */
-(IBAction)editActivity
{
    [self progress];
    [[ABStoreManager sharedManager] setModeEditing:YES];
    [[ABStoreManager sharedManager] settleEditingActivityID:[data[@"aId"] stringValue]];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ActivityBuilder_4" bundle:nil];
    ActivityGeneralViewController *dreamShot = [storyboard instantiateViewControllerWithIdentifier:@"ActivityGeneralViewController"];
    [self presentViewController:dreamShot animated:YES completion:^{
        [self stopSubview];
    }];

}
/*!
 * @discussion  Unfollow activity
 */
-(IBAction)unfollow
{
    [self progress];
    [Server hideActivity:currentActivityID callback:^{
        
        [self presentViewController:[[emsActivityVC alloc] init] animated:YES completion:^{

            [self stopSubview];
        }];
        
    }];
    
}
/*!
 * @discussion  AlertView delegate
 * @see deleteActivityVoid
 */
- (void)alertView:(UIAlertController *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   
    
    if([ownerId isEqualToString:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"myid"]]])
    {
    if (buttonIndex == 1) {
        [self progress];
        [Server removeActivity:currentActivityID callback:^{
            
            
            [[ABStoreManager sharedManager] setneedReloadMainScreen:YES];
            
            [self dismissViewControllerAnimated:YES completion:^{
                 [self stopSubview];
            }];
            
        }];

    }
    }
    else
    {
    
        if (buttonIndex == 1) {
            [self progress];
            [Server hideActivity:currentActivityID callback:^{

                 [[ABStoreManager sharedManager] setneedReloadMainScreen:YES];
                [self dismissViewControllerAnimated:YES completion:^{
                    [self stopSubview];
                }];
            }];
            
        }
        
    
    
    }
}
/*!
 * @discussion  Delete/Hide activity Alert
 */
-(void)deleteActivityVoid
{

    if([ownerId isEqualToString:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"myid"]]])
    {
        UIAlertView *warning = [[UIAlertView alloc] initWithTitle:@"Delete Activity"
                                                          message:@"Are you sure you want to delete current activity?"
                                                         delegate:self
                                                cancelButtonTitle:@"CANCEL"
                                                otherButtonTitles:@"OK", nil];
        [warning show];
    }
    else
    {
        UIAlertView *warning = [[UIAlertView alloc] initWithTitle:@"Hide Activity"
                                                          message:@"Are you sure you want to hide this activity?"
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Ok", nil];
        [warning show];
    }


}
-(IBAction)deleteActivity
{
    [self deleteActivityVoid];
    
}
/*!
 * @discussion  Follow activity
 */
-(IBAction)followActivity
{
    [self progress];
    [Server followActivity:currentActivityID callback:^{
        
        [self.topRightBtn setImage:[UIImage imageNamed:@"close_icon_activitydetail"] forState:UIControlStateNormal];
        [self.topRightBtn addTarget:self action:@selector(deleteActivity) forControlEvents:UIControlEventTouchUpInside];
        self.topLeftBtn.alpha=0;
        
        [[ABStoreManager sharedManager] setneedReloadMainScreen:YES];
    
        [self stopSubview];
        
    }];


}
/*!
 * @discussion  Go to Activity author profile page
 */
-(IBAction)authorInfo
{
    [self progress];
    emsProfileVC *reg = [[emsProfileVC alloc] initWithNibName:@"emsProfileVC" bundle:nil];
    reg.profileUserId = ownerId;
    [self presentViewController:reg animated:YES completion:^{
        [self stopSubview];
    }];

}
/*!
 * @discussion  Get formatted address from geocoder
 */
-(NSString*)streetName
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *curLocation = [[CLLocation alloc] initWithLatitude:[data[@"lat"] doubleValue] longitude:[data[@"lng"] doubleValue]];
    [geocoder reverseGeocodeLocation:curLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         // NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
         
         if (error == nil && [placemarks count] > 0)
         {
             placemark = [placemarks lastObject];
             
             
             whereAmI = ABCreateStringWithAddressDictionary(placemark.addressDictionary, YES);
             NSArray *seperated = [whereAmI componentsSeparatedByString:@"\n"];
             NSMutableString *line = [NSMutableString new];
             for (NSString *name in seperated) {
                 
                 [line appendString:[NSString stringWithFormat:@"%@, ",name]];
                 
             }
             line = [line substringToIndex:line.length-2];
             self.locationLbl.text = line;
             
             
         }
         
     }];
    
    return whereAmI;
    
    
}
/*!
 * @discussion Setup map according to Activity location data
 */
- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        // Try to dequeue an existing pin view first.
        pinView = (MKAnnotationView*)[self.locationMap dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.canShowCallout = YES;
            pinView.image = [UIImage imageNamed:@"location_icon.png"];
            pinView.calloutOffset = CGPointMake(0, 32);
            
            
        } else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}
/*!
 * @discussion  Setup action buttons states according to activity status
 * @see activityType ENUM for statuses
 */
-(void)loadInfo
{

    if([data[@"activityStatus"] integerValue]==hidden)
    {
    
        self.topRightBtn.alpha=0;
        self.topLeftBtn.alpha=0;
    
    }
    if ([data[@"activityStatus"] integerValue]==follower || [data[@"activityStatus"] integerValue]==member)
    {
        
        [self.topRightBtn setImage:[UIImage imageNamed:@"close_icon_activitydetail"] forState:UIControlStateNormal];
        [self.topRightBtn addTarget:self action:@selector(deleteActivity) forControlEvents:UIControlEventTouchUpInside];
        self.topRightBtn.alpha=1;
        self.topLeftBtn.alpha=0;
        
        
    }
    if ([data[@"activityStatus"] integerValue]==noStatus || [data[@"activityStatus"] integerValue]==requestFromUserToBecomeMember)
    {
        
        [self.topRightBtn setImage:[UIImage imageNamed:@"follow_icon_top"] forState:UIControlStateNormal];
        [self.topRightBtn addTarget:self action:@selector(followActivity) forControlEvents:UIControlEventTouchUpInside];
        [self.topLeftBtn setImage:[UIImage imageNamed:@"close_icon_activitydetail"] forState:UIControlStateNormal];
        [self.topLeftBtn addTarget:self action:@selector(deleteActivity) forControlEvents:UIControlEventTouchUpInside];
        self.topLeftBtn.alpha=1;
        self.topRightBtn.alpha=1;
        
    }
    
    if([ownerId isEqualToString:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"myid"]]])
    {
        self.topLeftBtn.alpha=1;
        self.topRightBtn.alpha=1;
        [self.topLeftBtn setImage:[UIImage imageNamed:@"edit_icon_top"] forState:UIControlStateNormal];
        [self.topLeftBtn addTarget:self action:@selector(editActivity) forControlEvents:UIControlEventTouchUpInside];
        [self.topRightBtn setImage:[UIImage imageNamed:@"close_icon_activitydetail"] forState:UIControlStateNormal];
        [self.topRightBtn addTarget:self action:@selector(deleteActivity) forControlEvents:UIControlEventTouchUpInside];
    }
    
}
/*!
 @discussion  Callback G+ after sharing
 */
-(void)gplusDidShare:(NSNotification *)notification
{
    BOOL status = [notification.userInfo[@"shared"] integerValue];
    if(status){
        [self.gPlusBtn setSelected:YES];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"SCGPlusShared"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[[UIAlertView alloc] initWithTitle:@"Google Plus" message:@"Post Successful" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        
    }
}
/*!
 * @discussion Reachability status online/offline
 */
-(void)reachability:(NSNotification *)notification
{
    
    BOOL status = notification.userInfo[@"status"];
    {
    
        if(status==YES){
            [self stopSubview];
        }else if(status == NO){
            [self progress];
        }
    
    }
    
}
#pragma cell delegate
/*!
 * @discussion  Button actions handler
 * @see MemberTableViewCell protocol
 */

- (void)cellController:(MemberTableViewCell*)cellController
        didPressButton:(NSString*)action userId:(NSString *)iId
{
    //Decline activity participation
    
    if([action isEqualToString:@"decline"])
    {
        [self progress];
        [Server acceptMember:currentActivityID andUserId:iId type:NO callback:^{
            
            data = [Server activityDataForID:currentActivityID lat:[[emsGlobalLocationServer sharedInstance] latitude] andLong:[[emsGlobalLocationServer sharedInstance] longitude]][@"activities"];
            
            if(data[@"members"])
                membersArray = [[NSMutableArray alloc] initWithArray:data[@"members"]];
            
            self.placesLbl.text = [NSString stringWithFormat:@"%lu   /",(unsigned long)membersArray.count];
            self.pCount.text = [NSString stringWithFormat:@"%@",data[@"placesCount"]];
            [self.membersTable reloadData];
            [self.topRightBtn setImage:[UIImage imageNamed:@"close_icon_activitydetail"] forState:UIControlStateNormal];
            [self.topRightBtn addTarget:self action:@selector(deleteActivity) forControlEvents:UIControlEventTouchUpInside];
            self.topLeftBtn.alpha=0;
            [self reInitDataAfterUsersActions];
            [self stopSubview];
        }];
        
        
    }
    // Go to user profile page
    
    if([action isEqualToString:@"profile"])
    {
        [self progress];
        emsProfileVC *reg = [[emsProfileVC alloc] initWithNibName:@"emsProfileVC" bundle:nil];
        
        reg.profileUserId = iId;
        [self presentViewController:reg animated:YES completion:^{
            [self stopSubview];
        }];
        
        
    }
    //Accept activity participation
    
    if([action isEqualToString:@"accept"])
    {
        [self progress];
        
        [Server acceptMember:currentActivityID andUserId:iId type:YES callback:^{
            [self reInitDataAfterUsersActions];
            [self stopSubview];
            
        }];
        
    }
    //Hide activity
    
    if([action isEqualToString:@"forget"])
    {
        [self progress];
        [Server followActivity:currentActivityID callback:^{
            
            data = [Server activityDataForID:currentActivityID lat:[[emsGlobalLocationServer sharedInstance] latitude] andLong:[[emsGlobalLocationServer sharedInstance] longitude]][@"activities"];
            
            if(data[@"members"])
                membersArray = [[NSMutableArray alloc] initWithArray:data[@"members"]];
            
            if(membersArray.count>0)
            {
                
                self.left.alpha=1;
                self.right.alpha=1;
                self.member.alpha=1;
                
            }
            self.placesLbl.text = [NSString stringWithFormat:@"%lu   /",(unsigned long)membersArray.count];
            self.pCount.text = [NSString stringWithFormat:@"%@",data[@"placesCount"]];
            if([data[@"activityStatus"] integerValue]==follower || [data[@"activityStatus"] integerValue]==noStatus){
                canBeMember = YES;
                [self.topRightBtn setImage:[UIImage imageNamed:@"close_icon_activitydetail"] forState:UIControlStateNormal];
                [self.topRightBtn addTarget:self action:@selector(deleteActivity) forControlEvents:UIControlEventTouchUpInside];
                self.topRightBtn.alpha=1;
                
            }
            else{
                [self.topRightBtn setImage:[UIImage imageNamed:@"close_icon_activitydetail"] forState:UIControlStateNormal];
                [self.topRightBtn addTarget:self action:@selector(deleteActivity) forControlEvents:UIControlEventTouchUpInside];
                self.topRightBtn.alpha=0;
                self.topLeftBtn.alpha=0;
                canBeMember = NO;
            }
            becomeOnce=NO;
            [self.membersTable reloadData];
            [self stopSubview];
            
        }];
        
        
    }
    //Become a member of current activity request
    if([action isEqualToString:@"becomemember"])
    {
        if(!becomeOnce && canBeMember)
        {
            [self progress];
     
            [Server becomeAMember:currentActivityID andUID:
            [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"myid"]]
                             type:YES];
    
             data = [Server activityDataForID:currentActivityID lat:
                    [[emsGlobalLocationServer sharedInstance] latitude] andLong:
                    [[emsGlobalLocationServer sharedInstance] longitude]][@"activities"];
                
                
                if(data[@"members"])
                    membersArray = [[NSMutableArray alloc] initWithArray:data[@"members"]];
                
                self.placesLbl.text = [NSString stringWithFormat:@"%lu   /",(unsigned long)membersArray.count];
                self.pCount.text = [NSString stringWithFormat:@"%@",data[@"placesCount"]];
                
                if([data[@"activityStatus"] integerValue]==follower || [data[@"activityStatus"] integerValue]==noStatus){
                    canBeMember = YES;
                    [self.topRightBtn setImage:[UIImage imageNamed:@"close_icon_activitydetail"] forState:UIControlStateNormal];
                    [self.topRightBtn addTarget:self action:@selector(deleteActivity) forControlEvents:UIControlEventTouchUpInside];
                    self.topRightBtn.alpha=1;
                    
                }
                else{
                    [self.topRightBtn setImage:[UIImage imageNamed:@"close_icon_activitydetail"] forState:UIControlStateNormal];
                    self.topRightBtn.alpha=1;
                    [self.topRightBtn addTarget:self action:@selector(deleteActivity) forControlEvents:UIControlEventTouchUpInside];
                    self.topLeftBtn.alpha=0;
                    canBeMember = NO;
                }
                becomeOnce=YES;
                [self.membersTable reloadData];
                [self stopSubview];
                
        }
        
    }
    
    
}
-(void)cornerIm:(UIImageView*)imageView{
    imageView.layer.cornerRadius = imageView.frame.size.width / 2;
    imageView.clipsToBounds = YES;
}
/*!
 @discussion  Setup map according to Activity data. Address/Pin
 */
-(void)setupMapView
{
    CLLocationCoordinate2D coord = {.latitude = [data[@"lat"] doubleValue], .longitude = [data[@"lng"] doubleValue]};
    double miles = 5.0;
    double scalingFactor = ABS( (cos(2 * M_PI * coord.latitude / 360.0) ));
    MKCoordinateSpan span = {.latitudeDelta = miles/69.0, .longitudeDelta =  miles/(scalingFactor * 69.0)};
    MKCoordinateRegion region = {coord, span};
    [self.locationMap setRegion:region];
    self.locationMap.mapType = MKMapTypeSatellite;
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = coord;
    [self.locationMap addAnnotation:point];
    self.locationLbl.text = [self streetName];
    // If an existing pin view was not available, create one.
    pinView = [[MKAnnotationView alloc] initWithAnnotation:point reuseIdentifier:@"CustomPinAnnotationView"];
    pinView.canShowCallout = YES;
    pinView.image = [UIImage imageNamed:@"location_icon.png"];
    pinView.calloutOffset = CGPointMake(0, 32);

}
/*!
 * @discussion  Places the rest of information on the fly, after scheduler
 * items are listed on the view
 */
-(void)placeFooterUnderTheScheduler
{
    
        [UIView animateWithDuration:0.01
                     animations:^{
    
                         self.footerDinamicView.frame = CGRectMake(self.footerDinamicView.frame.origin.x,
                                                                   curFooterOffset-30,
                                                                   self.footerDinamicView.frame.size.width,
                                                                   self.footerDinamicView.frame.size.height);
                     }
                     completion:^(__unused BOOL finished)
     {
         [UIView animateWithDuration:0.5
                          animations:^{
         self.footerDinamicView.frame = CGRectMake(self.footerDinamicView.frame.origin.x,
                                                   curFooterOffset+20,
                                                   self.footerDinamicView.frame.size.width,
                                                   self.footerDinamicView.frame.size.height);
                              
                          }];
     
     }];
    
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
}
/*!
 @discussion  Play Youtube video [After press activity video thumbnail]
 */
-(IBAction)playVideo:(UIButton*)sender
{

    NSString *test = data[@"activitiesImages"][sender.tag][@"link"];
    NSArray *stringComponents = [test componentsSeparatedByString:@"="];
    NSString *res = [stringComponents objectAtIndex:1];
    
    [[NSUserDefaults standardUserDefaults] setValue:res forKey:@"currentYTVideoID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ActivityBuilder_4" bundle:nil];
    YTPlayerViewController *notebook = [storyboard instantiateViewControllerWithIdentifier:@"YTPlayer"];
    [self presentViewController:notebook animated:YES completion:^{
        
    }];
    
}
/*!
 * @discussion  Fill in all data for activity card+Activity images/videos
 */
-(void)loadActivities
{
    
    if(data.count>3)
    {
        
        self.nameLbl.text = data[@"activityTitle"];
        self.distanseLbl.text = [NSString stringWithFormat:@"%@yd",data[@"distance"]];
        self.aboutLbl.text = data[@"description"];
        [self cornerIm:self.interestImage];
        
        UIActivityIndicatorView *interestIndicator = [[UIActivityIndicatorView alloc] init];
        interestIndicator.center = self.interestImage.center;
        interestIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [interestIndicator startAnimating];
        
        [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,data[@"primaryInterestsImg"]] andIndicator:interestIndicator addToImageView:self.interestImage];
        
        int index = 0;
        NSArray *images = [NSArray arrayWithArray:data[@"activitiesImages"]];
        for(int i=0;i<images.count;i++)
        {
            UIImageView *mainImage = [[UIImageView alloc] initWithFrame:CGRectMake(index, 0,320 , self.activityPhotoScroll.frame.size.height)];
            
            [self.activityPhotoScroll addSubview:mainImage];
            
            [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,images[i][@"path884x454"]] andIndicator:nil addToImageView:mainImage];
            if([[NSString stringWithFormat:@"%@",images[i][@"type"]] isEqualToString:@"video"])
            {
            
                UIButton *videoBtn = [[UIButton alloc] initWithFrame:CGRectMake(index+mainImage.frame.size.width/2-20, mainImage.frame.size.height/2-20, 40, 40)];
                [videoBtn addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
                [videoBtn setImage:[UIImage imageNamed:@"play_icon"] forState:UIControlStateNormal];
                videoBtn.tag = i;
                [self.activityPhotoScroll addSubview:videoBtn];
                
            }
            
            index += 320;
            [self.activityPhotoScroll setContentOffset:CGPointMake(index, 0)];
        }
        [self.activityPhotoScroll setContentSize:CGSizeMake(index, self.activityPhotoScroll.frame.size.height)];
        
        
    }
    if(data[@"members"])
        membersArray = [[NSMutableArray alloc] initWithArray:data[@"members"]];
    
    if(membersArray.count>0)
    {
        
        self.left.alpha=1;
        self.right.alpha=1;
        self.member.alpha=1;
        
    }
    
    self.placesLbl.text = [NSString stringWithFormat:@"%lu   /",(unsigned long)membersArray.count];
    self.pCount.text = [NSString stringWithFormat:@"%@",data[@"placesCount"]];
    [self.membersTable reloadData];
    [self.activityPhotoScroll setContentOffset:CGPointMake(0, 0)];

}
-(void)startActivitiesThread{
    [self loadActivities];
}
-(void)startInterestsThread{
    [ self interestsScrollLoad ];
}
/*!
 * @discussion  Load interests into the Interests scroll
 */
-(void)interestsScrollLoad
{
       interestsArray = data[@"interests"];
    
        int index = 10;
   
    for (int i=0;i<interestsArray.count;i++)
    {
        
        
        UIImageView *mainImageBg = [[UIImageView alloc] initWithFrame:CGRectMake(index-1, 0, 45, 45)];
        mainImageBg.image = [UIImage imageNamed:@"shared_users"];
        [self.interestsScroll addSubview:mainImageBg];
        UIImageView *mainImage = [[UIImageView alloc] initWithFrame:CGRectMake(index, 1, 43, 43)];
        [self.interestsScroll addSubview:mainImage];
        //Set name of current interest
        UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(index, 44, 44, 20)];
        nameLbl.font = [UIFont systemFontOfSize:10.f];
        nameLbl.text = interestsArray[i][@"name"];
        nameLbl.textAlignment = NSTextAlignmentCenter;
        [self.interestsScroll addSubview:nameLbl];
        //Configure ImageView for interest image
        [self cornerIm:mainImage];
        
        //Download image
        [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,interestsArray[i][@"interestImg"]] andIndicator:nil addToImageView:mainImage];
        index += 60;
        /*
         Centered Gray Line
         */
        if(i!=0)
        {
        
        UIView *cgl = [[UIView alloc] initWithFrame:CGRectMake(mainImageBg.frame.origin.x-
                                                               mainImageBg.frame.size.width, 21.5, mainImageBg.frame.size.width, 3)];
        cgl.backgroundColor = [UIColor lightGrayColor];
        [self.interestsScroll insertSubview:cgl atIndex:0];
            
        }
        
        [self.interestsScroll setContentOffset:CGPointMake(index, 0)];
        
    }
        
    [self.interestsScroll setContentSize:CGSizeMake(index, self.interestsScroll.frame.size.height)];
        CGFloat newContentOffsetX = (self.interestsScroll.contentSize.width - self.interestsScroll.frame.size.width) / 2;
        self.interestsScroll.contentOffset = CGPointMake(newContentOffsetX, 0);
    
    
    if(interestsArray.count<=5)
        self.interestsScroll.userInteractionEnabled = NO;
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    NSLog(@"didReceiveMemoryWarning - %@",self);
    // Dispose of any resources that can be recreated.
}

#pragma Mark rightMenuDelegate


-(void)notificationSelected:(Notification *)notification
{
    [[self.childViewControllers lastObject] willMoveToParentViewController:nil];
    [[[self.childViewControllers lastObject] view] removeFromSuperview];
    [[self.childViewControllers lastObject] removeFromParentViewController];
    
    NSLog(@"notification %lu", (unsigned long)notification);
    
}
/*!
 * @discussion  opens Notification popup
 */
-(IBAction)showRightMenu{
    
    emsRightMenuVC *emsRightMenu = [ [emsRightMenuVC alloc] initWithDelegate:self];
    NSLog(@"emsLeftMenu %@",emsRightMenu.delegate);
}
/*!
 * @discussion  opens Main menu popup
 */
#pragma Mark leftMenudelegate
-(IBAction)showLeftMenu{
    emsLeftMenuVC *emsLeftMenu =[[emsLeftMenuVC alloc]initWithDelegate:self ];
    NSLog(@"emsLeftMenu %@",emsLeftMenu.delegate);
}
-(void)actionPresed:(ActionsType)actionsTypel complite:(void (^)())complite{
    
    NSLog(@"actionsTypel %lu", (unsigned long)actionsTypel);
    //Calls when user press quit button on the Menu
    if (actionsTypel == quitAction) {
        
        subView = nil;
        [subView removeFromSuperview];
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


#pragma mark Table delegates

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.scheduledTable)
    {
        return 38;//88
    
    }
    return MEMBERS_CELL_HEIGHT;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    if (tableView == self.scheduledTable){
        return scheduledItemsArray.count;
    }
    else if(tableView == self.membersTable){
        if(canBeMember)
           return membersArray.count+1;
        else
            return membersArray.count;
        
    }
    return 0;
    
}
/*!
 * @discussion  text format
 */
-(NSAttributedString *)attributedTimeText:(NSString*)text
{
    
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:text];
    [string addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"MyriadPro-Cond" size:21] range:NSMakeRange(6,2)];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0,8)];
    
    return string;
}
/*!
 * @discussion  text format
 */
-(NSAttributedString *)attributedTimeWithDayOfWeek_custom:(NSString*)text
{
    
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:text];
    [string addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"MyriadPro-Cond" size:25] range:NSMakeRange(0,8)];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0,3)];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(3,8)];
    [string addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"MyriadPro-Cond" size:18] range:NSMakeRange(9,2)];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(9,2)];
    
    return string;
}
-(IBAction)saveActivity:(id)sender
{
    
    
    
}
/*!
 * @discussion  Get Day Of Weak e.g shirt 'FR' for Friday
 */
-(NSString*)dayOfWeek:(NSString*)newDate
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en/US"]];
    NSDate *capturedStartDate = [dateFormatter dateFromString:newDate];
    
    NSDateFormatter *nowDateFormatter = [[NSDateFormatter alloc] init];
    NSArray *daysOfWeek = @[@"",@"SU",@"MO",@"TU",@"WE",@"TH",@"FR",@"SA"];
    [nowDateFormatter setDateFormat:@"e"];
    NSInteger weekdayNumber = (NSInteger)[[nowDateFormatter stringFromDate:capturedStartDate] integerValue];
    NSLog(@"Day of Week: %@",[daysOfWeek objectAtIndex:weekdayNumber]);
    
    return [daysOfWeek objectAtIndex:weekdayNumber];
    
}
/*!
 * @discussion  Get Day Of Weak (short) e.g FR for Friday
 */
-(NSString*)strTime:(NSString*)timeObj
{
    
    double unixTimeStamp =[timeObj doubleValue];
    NSTimeInterval _interval=unixTimeStamp;
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:_interval];
    NSDateFormatter *formatter= [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en/US"];
    [formatter setLocale:locale];
    [formatter setDateFormat:@"hh:mm a"];
    NSString *res = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
    return res;
    
}
/*!
 * @discussion  Format string for scheduler
 */
-(NSString*)strTimeWithDay:(NSString*)timeObj andDate:(NSString *)dateStr
{
    
    double unixTimeStamp =[timeObj doubleValue];
    NSTimeInterval _interval=unixTimeStamp;
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:_interval];
    
    double unixTimeStamp1 =[dateStr doubleValue];
    NSTimeInterval _interval1=unixTimeStamp1;
    NSDate *date1 = [[NSDate alloc] initWithTimeIntervalSince1970:_interval1];
    
    NSDateFormatter *formatter= [[NSDateFormatter alloc] init];
    NSDateFormatter *formatterDate= [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en/US"];
    [formatter setLocale:locale];
    [formatterDate setDateFormat:@"MM-dd-yyyy"];
    [formatterDate setLocale:locale];
    [formatterDate setDateStyle:NSDateFormatterMediumStyle];
    [formatter setDateFormat:@"hh:mm a"];
    NSString *res = [NSString stringWithFormat:@"%@ %@ %@",[self dayOfWeek:[formatterDate stringFromDate:date1]],[formatter stringFromDate:date],[formatterDate stringFromDate:date]];
    return res;
    
}
/*!
 * @discussion  Shares Facebook/Twitter
 * @note accounts uses from smartphone settings
 */
-(IBAction)share:(UIButton*)sender
{
   
    NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_PATH,data[@"activitiesImages"][0][@"path884x454"]]]];
    UIImage *image  = [UIImage imageWithData:imageData];
    
    if(sender.tag==0)//Facebook
    {
        
        
        SLComposeViewController *controller = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeFacebook];
        [controller setInitialText:data[@"description"]];
        [controller setTitle:data[@"activityTitle"]];
        [controller addImage:image];
        [self presentViewController:controller animated:YES completion:nil];
        [controller setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Canceled");
                    break;
                case SLComposeViewControllerResultDone:
                {
                    NSLog(@"Post Successful");
                    [self.facebookBtn setSelected:YES];
                    [[[UIAlertView alloc] initWithTitle:@"Facebook" message:@"Post Successful" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"SCFacebookShared"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                    break;
                    
                default:
                    break;
            }
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }];

    
    }else if(sender.tag==1)//Twitter
    {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [controller setInitialText:data[@"description"]];
        [controller setTitle:data[@"activityTitle"]];
        [controller addImage:image];
        [self presentViewController:controller animated:YES completion:Nil];
        [controller setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Canceled");
                    break;
                case SLComposeViewControllerResultDone:
                {
                    [[[UIAlertView alloc] initWithTitle:@"Twitter" message:@"Post Successful" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                    [self.twitterBtn setSelected:YES];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"SCTwitterShared"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                    break;
                    
                default:
                    break;
            }
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }];

        
    }
}
/*!
 * @discussion  to get readable date from unix date in string format
 * @param 'timeObj' Unix date in string
 */

-(NSString*)strDate:(NSString*)timeObj
{
    
    double unixTimeStamp =[timeObj doubleValue];
    NSTimeInterval _interval=unixTimeStamp;
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:_interval];
    NSDateFormatter *formatter= [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en/US"];
    [formatter setLocale:locale];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    return [formatter stringFromDate:date];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(tableView == self.scheduledTable)
    {
       
        SchedulerActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SchedulerCell"];
        
        if (cell == nil)
        {
            NSLog(@"indexPath.row %ld",(long)indexPath.row);
        }
        
        if (!cell) {
            
            NSArray* xibCell = [[NSBundle mainBundle] loadNibNamed:@"SchedulerCell" owner:self options:nil];
            cell = [xibCell objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            /////Stored data
            NSDictionary *tmpData = [NSDictionary dictionaryWithDictionary:[scheduledItemsArray objectAtIndex:indexPath.row]];
            int type =[[NSString stringWithFormat:@"%@",[tmpData objectForKey:vSchedulerType]] intValue];
            NSString *typeStr =[[ABStoreManager sharedManager]  translateTypeIntoString:type];
            NSString *time = [NSString stringWithFormat:@"%@",[tmpData objectForKey:vScheduledTime]];
            NSString *date = [NSString stringWithFormat:@"%@",[tmpData objectForKey:vScheduledDate]];
            cell.schedulerTypeLbl.text = typeStr;
            cell.schedulerTypeLbl.textColor = [UIColor blackColor];
            if([typeStr isEqualToString:@"Custom"]){
                
                NSMutableString *dateDays = [NSMutableString new];
                [dateDays appendString:[NSString stringWithFormat:@"%@, ",[self strTime:time]]];
                NSArray *daysArray = [NSArray arrayWithArray:[tmpData objectForKey:vDaysArray]];
                for(int i=0;i<daysArray.count;i++)
                {
                    [dateDays appendString:[NSString stringWithFormat:i==0?@"%@":@"/%@",daysArray[i]]];
                    
                
                }
                cell.dateTimeLbl.text = dateDays;
                
            }
            else if([typeStr isEqualToString:@"Once"])
            {
                cell.dateTimeLbl.text = [self strTimeWithDay:time andDate:time];
                
            }
            else if([typeStr isEqualToString:@"Weekends"] || [typeStr isEqualToString:@"Everyday"])
            {
                
                cell.dateTimeLbl.text = [self strTime:time];
                
            }
            else if([typeStr isEqualToString:@"Monthly"])
            {
                
                NSString *newTitle = [NSString stringWithFormat:@"Each %@ day",tmpData[@"dayOfMonth"]];
                cell.dateTimeLbl.text = newTitle;
                
            }

        }
       
        return cell;
        
    
    }
    MemberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MemberTableViewCell"];
    
    if (!cell) {
        
        NSArray* xibCell = [[NSBundle mainBundle] loadNibNamed:@"MemberTableViewCell" owner:self options:nil];
        cell = [xibCell objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
    }
    cell.delegate = self;
    if((membersArray.count==0 || (membersArray.count>0 && indexPath.row==membersArray.count)) && canBeMember)
    {
    
        [cell.avatarImage setImage:[UIImage imageNamed:@"smile_member"]];
        cell.nameLbl.text = @"BECOME A MEMBER";
        cell.aId = [data[@"aId"] intValue];
        cell.acceptBtn.alpha=0;
        cell.declineBtn.alpha=0;
        [cell.infoOrBecomeAMemberBtn setImage:[UIImage imageNamed:@"add_icon_activitydetail"] forState:UIControlStateNormal];
        if([cell respondsToSelector:@selector(becomeMember)])
        {
            
             [cell.infoOrBecomeAMemberBtn removeTarget:cell action:@selector(forgetActivity) forControlEvents:UIControlEventTouchUpInside];
             [cell.infoOrBecomeAMemberBtn addTarget:cell action:@selector(becomeMember) forControlEvents:UIControlEventTouchUpInside];
            
        }
        
        return cell;
    
    }
    if([ownerId isEqualToString:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"myid"]]] && ![[NSString stringWithFormat:@"%@",membersArray[indexPath.row][@"uId"]] isEqualToString:ownerId])
    {
        
            [cell configureCellIfUserIsOwner:membersArray[indexPath.row]];
            return cell;
      
    }
    else
    {
        [cell configureCellItemsWithData:membersArray[indexPath.row]];
        return cell;
    }
    
    return cell;
    
}
-(IBAction)getOutFromHere:(UIButton*)sender
{
    
    [self dismissViewControllerAnimated:NO completion:^{
        [self clearData ];
    }];
  
}
/*!
 @discussion  Remove self from activity member
 */
-(IBAction)declineActivity
{

    [self deleteActivityVoid];
    
}
/*!
 * @discussion  Follow activity and go to SocialRadar page
 */
-(IBAction)acceptActivity
{
    
    [Server followActivity:currentActivityID callback:^{
        
        [self presentViewController:[[emsMainScreenVC alloc] init] animated:YES completion:^{
            
        }];
        
    }];

}
/*!
 * @discussion to void all needed objects
 */
-(void)clearData{
    
    for (UIView *view in self.view.subviews) {// временный dealloc
        [view removeFromSuperview];
    }
    [self.mainScroll removeFromSuperview];
    self.mainScroll = nil;
    data  = nil;
    pinView = nil;
    interestsArray = nil;
    
}
/*!
 * @discussion  to start progress indicator
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
/*!
 @discussion  Share Activity with G+
 */
-(IBAction)shareGooglePlus
{

    GPlusHelper *gph = [GPlusHelper new];
   
    NSArray *images = [NSArray arrayWithArray:data[@"activitiesImages"]];
    
    __block UIImage *image = [UIImage new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_PATH,images[0][@"path884x454"]]]];
        
        image  = [UIImage imageWithData:imageData];
        dispatch_sync(dispatch_get_main_queue(), ^{
        [gph shareActivityImage:image andText:self.aboutLbl.text];
            
        });
    });


}
/*!
 @depricated
 */
-(IBAction)instaGramWallPost
{
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://"];
    if([[UIApplication sharedApplication] canOpenURL:instagramURL]) //check for App is install or not
    {
        NSArray *images = [NSArray arrayWithArray:data[@"activitiesImages"]];
       
        
        __block UIImage *image = [UIImage new];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_PATH,images[0][@"path884x454"]]]];
                                                                
            image  = [UIImage imageWithData:imageData];
            dispatch_sync(dispatch_get_main_queue(), ^{
               
#pragma mark Open Instagram app and share This Activity
                
                NSData *imageData = UIImagePNGRepresentation(image); //convert image into .png format.
                NSFileManager *fileManager = [NSFileManager defaultManager];//create instance of NSFileManager
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
                NSString *documentsDirectory = [paths objectAtIndex:0]; //create NSString object, that holds our exact path to the documents directory
                NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"insta.igo"]]; //add our image to the path
                [fileManager createFileAtPath:fullPath contents:imageData attributes:nil]; //finally save the path (image)
                NSLog(@"image saved");
                
                CGRect rect = CGRectMake(0 ,0 , 0, 0);
                UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
                [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
                UIGraphicsEndImageContext();
                NSString *fileNameToSave = [NSString stringWithFormat:@"Documents/insta.igo"];
                NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:fileNameToSave];
                NSLog(@"jpg path %@",jpgPath);
                NSString *newJpgPath = [NSString stringWithFormat:@"file://%@",jpgPath];
                NSLog(@"with File path %@",newJpgPath);
                NSURL *igImageHookFile = [[NSURL alloc]initFileURLWithPath:newJpgPath];
                NSLog(@"url Path %@",igImageHookFile);
                self.documentController.UTI = @"com.instagram.exclusivegram";
                self.documentController = [self setupControllerWithURL:igImageHookFile usingDelegate:self];
                self.documentController=[UIDocumentInteractionController interactionControllerWithURL:igImageHookFile];
                NSString *caption = self.aboutLbl.text; //settext as Default Caption
                self.documentController.annotation=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",caption],@"InstagramCaption", nil];
                [self.documentController presentOpenInMenuFromRect:rect inView: self.view animated:YES];
                
                
            });
        });
        
        
    }
    else
    {
        NSLog (@"Instagram not found");
    }
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    NSLog(@"file url %@",fileURL);
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    
    return interactionController;
}
@end
