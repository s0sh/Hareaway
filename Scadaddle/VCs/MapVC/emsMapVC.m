//
//  emsMapVC.m
//  Scadaddle
//
//  Created by developer on 13/05/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsMapVC.h"
#import "emsRightMenuVC.h"
#import "emsLeftMenuVC.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "emsMapEssentionAnnotation.h"
#import "emsMapEssence.h"
#import "emsMapEssenceView.h"
#import "emsLogic.h"
#import "emsDeviceManager.h"
#import "emsProfileVC.h"
#import "emsMainScreenVC.h"
#import "emsAPIHelper.h"
#import "ABStoreManager.h"
#import "emsGlobalLocationServer.h"
#import "ScadaddlePopup.h"
#import "emsScadProgress.h"
#import "ActivityDetailViewController.h"
#import "emsScadProgress.h"
#import "FBHelper.h"
#import "FBWebLoginViewController.h"

@interface emsMapVC ()< MKMapViewDelegate, CLLocationManagerDelegate>{
    
    CLLocation *curLocation;
    //--Popup-------------------------
    ScadaddlePopup *popup;
    NSThread *scadaddlePopupThread;
    //--------------------------------
    emsScadProgress * subView;
}
@property (nonatomic, weak) IBOutlet UIButton *firstBtn;
@property (nonatomic, weak) IBOutlet UIButton *secondBtn;
@property (nonatomic, weak) IBOutlet UIButton *thirdBtn;
@property (nonatomic, weak) IBOutlet UIButton *fourthBtn;
@property (nonatomic, weak) IBOutlet UIButton *fifthBtn;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain)NSMutableArray *buttonsArray;
@property (nonatomic, retain)NSMutableArray *annotationsArray;
@property (nonatomic, retain)NSMutableArray *annotationsArrayPredicated ;
@property (nonatomic, retain)NSMutableArray *parseArray;
@property (nonatomic, retain)NSMutableArray *parseArrayUsers;
//------------ All
@property (nonatomic, retain) NSMutableArray *dictionaryArray;
@property (nonatomic, retain) NSMutableArray *dictionaryArrayAll;
@property (nonatomic, retain) NSMutableArray *essenceArrayFromDictionaryAll;
@property (nonatomic) NSInteger totalNumberOfAllSection;
@property (nonatomic) NSInteger uploadCountOfAllSection;
@property (nonatomic) BOOL allFineshed;
//------------ Activity
@property (nonatomic, retain) NSMutableArray *essenceArrayFromDictionaryActivities;
@property (nonatomic) NSInteger totalNumberOfActivity;
@property (nonatomic) NSInteger uploadCountOfActivity;
@property (nonatomic) BOOL activityFineshed;
//------------ Single
@property (nonatomic, retain) NSMutableArray *essenceArrayFromDictionarySingle;
@property (nonatomic) NSInteger totalNumberOfSingle;
@property (nonatomic) NSInteger uploadCountOfSingle;
@property (nonatomic) BOOL singleFineshed;
//------------ Interests
@property (nonatomic, retain) NSMutableArray *essenceArrayFromDictionaryInterests;
@property (nonatomic) NSInteger totalNumberOfInterests;
@property (nonatomic) NSInteger uploadCountOfInterests;
@property (nonatomic) BOOL interestsFineshed;
//------------ Rewards
@property (nonatomic, retain) NSMutableArray *essenceArrayFromDictionaryRewards;
@property (nonatomic) NSInteger totalNumberOfRewards;
@property (nonatomic) NSInteger uploadCountOfRewards;
@property (nonatomic) BOOL rewardsFineshed;
//

@end

@implementation emsMapVC

/*!
 * @discussion Show progress view ander superView
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
 * @discussion Remove progress view from superView
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
 *  @discussion  Method adds rewards pins on map
 *  @return: an `emsMapEssence` objects as a NSObject
 *  @param :'latitude' and 'longitude' should be passed to get information  of particular rewards' pins
 *  @warning: there is shout work locations classes
 *
 */
-(void)getRewards{//------------ Rewards
 
    self.essenceArrayFromDictionaryRewards = [[NSMutableArray alloc] init];
    
    NSMutableArray *dictionaryArrayRewards = [[NSMutableArray alloc]initWithArray:[Server rewards:[[emsGlobalLocationServer sharedInstance] latitude]
                                                                                          andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                                                                                         andStart: [NSString stringWithFormat: @"%ld", (long)self.totalNumberOfRewards]
                                                                                         andLimit: [NSString stringWithFormat: @"%d", 1000]]];
    
    for (NSDictionary *dic in dictionaryArrayRewards) {
        
        emsMapEssence *mapAnnotation = [[emsMapEssence alloc] init];
        if (dic[@"uId"]){
            mapAnnotation.essenceType = userEssence;
            mapAnnotation.essenceID = dic[@"uId"];
        }
        
        if (dic[@"aId"]){
            mapAnnotation.essenceType = activityEssence;
            mapAnnotation.essenceID = dic[@"activityOwnerId"];
            mapAnnotation.essenceActivityFollowID = dic[@"aId"];
        }
        
        mapAnnotation.title = dic[@"name"];
        mapAnnotation.subtitle = dic[@"interestsStr"];
        mapAnnotation.interestImageUrl = dic[@"primaryInterestsImg"];
        mapAnnotation.annotationImageUrl = dic[@"userImg"];
        
        double latitude = [dic[@"lat"] doubleValue];
        double longitude = [dic[@"lng"]doubleValue];
        
        mapAnnotation.coordinate =  CLLocationCoordinate2DMake(latitude,
                                                               longitude);
        
        CLLocationCoordinate2D newCoordinate = [mapAnnotation coordinate];
        CLLocationCoordinate2D oldCoordinate = [self.locationManager.location coordinate];
        CLLocation *newLocation = [[CLLocation alloc] initWithCoordinate: newCoordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:1 timestamp:nil];
        CLLocation *oldLocation = [[CLLocation alloc] initWithCoordinate: oldCoordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:1 timestamp:nil];
        CLLocationDistance kilometers = [newLocation distanceFromLocation:oldLocation] / 914.4;
        int k = kilometers;
        mapAnnotation.distance = [NSString stringWithFormat:@"%d",k];
        oldLocation = nil;
        newLocation = nil;
        
        __weak typeof(emsMapEssence) *weakMapAnnotation = mapAnnotation;
        
        mapAnnotation.infoBlock = ^{
            
            if (dic[@"uId"]){
                
                emsProfileVC *reg = [[emsProfileVC alloc] initWithNibName:@"emsProfileVC" bundle:nil];
                
                reg.profileUserId = dic[@"uId"];
                
                [self presentViewController:reg animated:YES completion:^{
                    
                }];
            }
            
            if (dic[@"aId"]){
                
                [self presentViewController:[[ActivityDetailViewController alloc] initWithData:dic] animated:YES completion:^{
                    
                }];
            }
            
        };
        mapAnnotation.deleteBlock = ^(id<MKAnnotation> obj){
            
            [self.mapView removeAnnotation: obj];
            
            [self deleteUser:weakMapAnnotation];
        };
        mapAnnotation.followBlock = ^(id<MKAnnotation> obj){
            
            [self.mapView removeAnnotation: obj];
            
            [self followUser:weakMapAnnotation];
        };
        mapAnnotation.closeSelfOnMap  = ^(id<MKAnnotation> obj){
            
            [self.mapView deselectAnnotation:obj animated:YES ];
            
        };
        
        [self.essenceArrayFromDictionaryRewards  addObject:mapAnnotation];
    }
}
/*!
 *  @discussion  Method adds activity pins on map
 *  @return: an `emsMapEssence` objects as a NSObject
 *  @param :'latitude' and 'longitude' should be passed to get information  of particular activities pins
 *  @warning: there is shout work locations classes
 *
 */

-(void)getAllActivities{ //------------ Activity
    
    self.essenceArrayFromDictionaryActivities = [[NSMutableArray alloc] init];
    NSMutableArray * dictionaryArrayActivities = [[NSMutableArray alloc] initWithArray:[Server activities:[[emsGlobalLocationServer sharedInstance] latitude]
                                                                                                  andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                                                                                                 andStart: [NSString stringWithFormat: @"%ld", (long)self.totalNumberOfActivity]
                                                                                                 andLimit:[NSString stringWithFormat: @"%d",100 /*self.uploadCountOfAllSection*/]]];
    
    
    
    for (NSDictionary *dic in dictionaryArrayActivities) {
        
        emsMapEssence *mapAnnotation = [[emsMapEssence alloc] init];
        
        if (dic[@"uId"]){
            mapAnnotation.essenceType = userEssence;
            mapAnnotation.essenceID = dic[@"uId"];
        }
        
        if (dic[@"aId"]){
            mapAnnotation.essenceType = activityEssence;
            mapAnnotation.essenceID = dic[@"activityOwnerId"];
            mapAnnotation.essenceActivityFollowID = dic[@"aId"];
        }
        mapAnnotation.title = dic[@"name"];
        mapAnnotation.subtitle = dic[@"interestsStr"];
        mapAnnotation.interestImageUrl = dic[@"primaryInterestsImg"];
        mapAnnotation.annotationImageUrl = dic[@"userImg"];

        double latitude = [dic[@"lat"] doubleValue];
        double longitude = [dic[@"lng"]doubleValue];
        
        mapAnnotation.coordinate =  CLLocationCoordinate2DMake(latitude,
                                                               longitude);
        
        CLLocationCoordinate2D newCoordinate = [mapAnnotation coordinate];
        CLLocationCoordinate2D oldCoordinate = [self.locationManager.location coordinate];
        CLLocation *newLocation = [[CLLocation alloc] initWithCoordinate: newCoordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:1 timestamp:nil];
        CLLocation *oldLocation = [[CLLocation alloc] initWithCoordinate: oldCoordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:1 timestamp:nil];
        CLLocationDistance kilometers = [newLocation distanceFromLocation:oldLocation] / 914.4;
        int k = kilometers;
        mapAnnotation.distance = [NSString stringWithFormat:@"%d",k];
        oldLocation = nil;
        newLocation = nil;
        
        __weak typeof(emsMapEssence) *weakMapAnnotation = mapAnnotation;
        
        mapAnnotation.infoBlock = ^{
            
            if (dic[@"uId"]){
                emsProfileVC *reg = [[emsProfileVC alloc] initWithNibName:@"emsProfileVC" bundle:nil];
                
                reg.profileUserId = dic[@"uId"];
                
                [self presentViewController:reg animated:YES completion:^{
                    
                }];
            }
            
            if (dic[@"aId"]){
                
                [self presentViewController:[[ActivityDetailViewController alloc] initWithData:dic] animated:YES completion:^{
                    
                }];
            }
        };
        
        mapAnnotation.deleteBlock = ^(id<MKAnnotation> obj){
            
            [self.mapView removeAnnotation: obj];
            
            [self deleteUser:weakMapAnnotation];
        };
        
        mapAnnotation.followBlock = ^(id<MKAnnotation> obj){
            
            [self.mapView removeAnnotation: obj];
            
            [self followUser:weakMapAnnotation];
        };
        
        mapAnnotation.closeSelfOnMap  = ^(id<MKAnnotation> obj){
            
            [self.mapView deselectAnnotation:obj animated:YES ];
        };
        
        [self.essenceArrayFromDictionaryActivities  addObject:mapAnnotation];
    }
}

/*!
 *  @discussion  Method adds single users pins on map
 *  @return: an `emsMapEssence` objects as a NSObject
 *  @param :'latitude' and 'longitude' should be passed to get information  of particular single users pins
 *  @warning: there is shout work locations classes
*/

-(void)getAllBySingle{ //------------ Single
    
    NSMutableArray * dictionaryArraySingle = [[NSMutableArray alloc] initWithArray:[Server interests:[[emsGlobalLocationServer sharedInstance] latitude]
                                                                                            andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                                                                                            andGender:@"0"
                                                                                            andStart: [NSString stringWithFormat: @"%ld", (long)self.totalNumberOfSingle]
                                                                                            andLimit:[NSString stringWithFormat: @"%d", 100]]];
    self.essenceArrayFromDictionarySingle = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dic in dictionaryArraySingle) {
        
        emsMapEssence *mapAnnotation = [[emsMapEssence alloc] init];
        
        if (dic[@"uId"]){
            mapAnnotation.essenceType = userEssence;
            mapAnnotation.essenceID = dic[@"uId"];
        }
        
        if (dic[@"aId"]){
            mapAnnotation.essenceType = activityEssence;
            mapAnnotation.essenceID = dic[@"activityOwnerId"];
            mapAnnotation.essenceActivityFollowID = dic[@"aId"];
        }
        
        mapAnnotation.title = dic[@"name"];
        mapAnnotation.subtitle = dic[@"interestsStr"];
        mapAnnotation.interestImageUrl = dic[@"primaryInterestsImg"];
        mapAnnotation.annotationImageUrl = dic[@"userImg"];
        
        double latitude = [dic[@"lat"] doubleValue];
        double longitude = [dic[@"lng"]doubleValue];
        
        mapAnnotation.coordinate =  CLLocationCoordinate2DMake(latitude,
                                                               longitude);
        
        CLLocationCoordinate2D newCoordinate = [mapAnnotation coordinate];
        CLLocationCoordinate2D oldCoordinate = [self.locationManager.location coordinate];
        CLLocation *newLocation = [[CLLocation alloc] initWithCoordinate: newCoordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:1 timestamp:nil];
        CLLocation *oldLocation = [[CLLocation alloc] initWithCoordinate: oldCoordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:1 timestamp:nil];
        CLLocationDistance kilometers = [newLocation distanceFromLocation:oldLocation] / 914.4;
        int k = kilometers;
        mapAnnotation.distance = [NSString stringWithFormat:@"%d",k];
        oldLocation = nil;
        newLocation = nil;
        __weak typeof(emsMapEssence) *weakMapAnnotation = mapAnnotation;
        
        mapAnnotation.infoBlock = ^{
            
            if (dic[@"uId"]){
                emsProfileVC *reg = [[emsProfileVC alloc] initWithNibName:@"emsProfileVC" bundle:nil];
                
                reg.profileUserId = dic[@"uId"];
                
                [self presentViewController:reg animated:YES completion:^{
                    
                }];
            }
            
            if (dic[@"aId"]){
                
                [self presentViewController:[[ActivityDetailViewController alloc] initWithData:dic] animated:YES completion:^{
                    
                }];
            }
        };
        
        mapAnnotation.deleteBlock = ^(id<MKAnnotation> obj){
            
            [self.mapView removeAnnotation: obj];
            
            [self deleteUser:weakMapAnnotation];
        };
        
        mapAnnotation.followBlock = ^(id<MKAnnotation> obj){
            
            [self.mapView removeAnnotation: obj];
            
            [self followUser:weakMapAnnotation];
        };
    
        mapAnnotation.closeSelfOnMap  = ^(id<MKAnnotation> obj){
            
            [self.mapView deselectAnnotation:obj animated:YES ];
            
        };
        
        [self.essenceArrayFromDictionarySingle  addObject:mapAnnotation];
    }
}

/*!
 *  @discussion  Method adds users by interests pins on map
 *  @return: an `emsMapEssence` objects as a NSObject
 *  @param :'latitude' and 'longitude' should be passed to get information  of particular single users pins
 *  @warning: there is shout work locations classes
 *
 */
-(void)getAllByInterests{ //------------ Interests
    

    
    NSMutableArray * dictionaryArrayInterests = [[NSMutableArray alloc] initWithArray:[Server interests:[[emsGlobalLocationServer sharedInstance] latitude]
                                                                                                andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                                                                                              andGender:nil
                                                                                               andStart: [NSString stringWithFormat: @"%ld", (long)self.totalNumberOfInterests]
                                                                                               andLimit: [NSString stringWithFormat: @"%d", 100]]];;
    self.essenceArrayFromDictionaryInterests = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dic in dictionaryArrayInterests) {
        
        emsMapEssence *mapAnnotation = [[emsMapEssence alloc] init];
        
        if (dic[@"uId"]){
            mapAnnotation.essenceType = userEssence;
            mapAnnotation.essenceID = dic[@"uId"];
        }
        
        if (dic[@"aId"]){
            mapAnnotation.essenceType = activityEssence;
            mapAnnotation.essenceID = dic[@"activityOwnerId"];
            mapAnnotation.essenceActivityFollowID = dic[@"aId"];
        }
        mapAnnotation.title = dic[@"name"];
        mapAnnotation.subtitle = dic[@"interestsStr"];
        mapAnnotation.interestImageUrl = dic[@"primaryInterestsImg"];
        mapAnnotation.annotationImageUrl = dic[@"userImg"];
        
        double latitude = [dic[@"lat"] doubleValue];
        double longitude = [dic[@"lng"]doubleValue];
        
        mapAnnotation.coordinate =  CLLocationCoordinate2DMake(latitude,
                                                               longitude);
        
        CLLocationCoordinate2D newCoordinate = [mapAnnotation coordinate];
        CLLocationCoordinate2D oldCoordinate = [self.locationManager.location coordinate];
        CLLocation *newLocation = [[CLLocation alloc] initWithCoordinate: newCoordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:1 timestamp:nil];
        CLLocation *oldLocation = [[CLLocation alloc] initWithCoordinate: oldCoordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:1 timestamp:nil];
        CLLocationDistance kilometers = [newLocation distanceFromLocation:oldLocation] / 914.4;
        int k = kilometers;
        mapAnnotation.distance = [NSString stringWithFormat:@"%d",k];
        oldLocation = nil;
        newLocation = nil;
        
        __weak typeof(emsMapEssence) *weakMapAnnotation = mapAnnotation;
        
        mapAnnotation.infoBlock = ^{
            
            if (dic[@"uId"]){
                
                emsProfileVC *reg = [[emsProfileVC alloc] initWithNibName:@"emsProfileVC" bundle:nil];
                
                reg.profileUserId = dic[@"uId"];
                
                [self presentViewController:reg animated:YES completion:^{
                    
                }];
            }
            
            if (dic[@"aId"]){
                
                [self presentViewController:[[ActivityDetailViewController alloc] initWithData:dic] animated:YES completion:^{
                    
                }];
            }
            
        };
        
        mapAnnotation.deleteBlock = ^(id<MKAnnotation> obj){
            
            [self.mapView removeAnnotation: obj];
            
            [self deleteUser:weakMapAnnotation];
            
        };
        
        mapAnnotation.followBlock = ^(id<MKAnnotation> obj){
            
            [self.mapView removeAnnotation: obj];
            
            [self followUser:weakMapAnnotation];
        };
        
        mapAnnotation.closeSelfOnMap  = ^(id<MKAnnotation> obj){
            
            [self.mapView deselectAnnotation:obj animated:YES ];
        };
        
        [self.essenceArrayFromDictionaryInterests  addObject:mapAnnotation];
    }
    
}

/*!
 *  @discussion Method adds user to followers
*/
-(void)followUser:(emsMapEssence *)mapEssence{
    
    emsMapEssence *essence = mapEssence;
    
    if (essence.essenceType == userEssence) {
        
        [Server followUser:essence.essenceID callback:^{
            
        }];
        
    }
    if (essence.essenceType == activityEssence) {
        
        [Server followActivity:essence.essenceActivityFollowID callback:^{
            
            
        }];
    }
}

/*!
 *  @discussion Method deletes entity from participant array and from view(in main screen)
*/
-(void)deleteUser:(emsMapEssence *)mapEssence{
    
    emsMapEssence *essence = mapEssence;
    
    if (essence.essenceType == userEssence) {
        
        [Server deleteUser:essence.essenceID callback:^{
            
        }];
        
    }
    if (essence.essenceType == activityEssence) {
        
        
        [Server hideActivity:essence.essenceActivityFollowID callback:^{
            
        }];
        
    }
}
/*!
 *  @discussion  initial arrays + adds users  pins on map
 *  @return: an `emsMapEssence` objects as a NSObject
 *  @param :'latitude' and 'longitude' should be passed to get information  of particular single users pins
 *  @warning: there is shout work locations classes
 *
 */
-(void)parseData{
    
    self.parseArray = [[NSMutableArray alloc] init];
    self.parseArrayUsers = [[NSMutableArray alloc] init];
    self.dictionaryArrayAll = [[NSMutableArray alloc] init];
    self.essenceArrayFromDictionaryAll = [[NSMutableArray alloc] init];
    //----------uploadCount
    self.totalNumberOfAllSection = 0;
    self.uploadCountOfAllSection = 1;
    self.totalNumberOfActivity = 0;
    self.uploadCountOfActivity = 1;
    self.totalNumberOfSingle = 0;
    self.uploadCountOfSingle = 1;
    self.totalNumberOfInterests = 0;
    self.uploadCountOfInterests = 1;
    self.totalNumberOfRewards = 0;
    self.uploadCountOfRewards = 1;
    
    [self.parseArrayUsers addObjectsFromArray:[Server mainPage:[[emsGlobalLocationServer sharedInstance] latitude]
                                                       andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                                                      andStart: [NSString stringWithFormat: @"%ld", (long)self.totalNumberOfAllSection]
                                                      andLimit:[NSString stringWithFormat: @"%d",100 /*self.uploadCountOfAllSection*/]]];
    
    
    
    
    
    for (NSDictionary *dic in self.parseArrayUsers) {
        
        emsMapEssence *mapAnnotation = [[emsMapEssence alloc] init];
        
        if (dic[@"uId"]){
            mapAnnotation.essenceType = userEssence;
            mapAnnotation.essenceID = dic[@"uId"];
        }
        
        if (dic[@"aId"]){
            mapAnnotation.essenceType = activityEssence;
            mapAnnotation.essenceID = dic[@"activityOwnerId"];
            mapAnnotation.essenceActivityFollowID = dic[@"aId"];
        }
        
        mapAnnotation.title = dic[@"name"];
        mapAnnotation.subtitle = dic[@"interestsStr"];
        mapAnnotation.interestImageUrl = dic[@"primaryInterestsImg"];
        mapAnnotation.annotationImageUrl = dic[@"userImg"];
        
        double latitude = [dic[@"lat"] doubleValue];
        double longitude = [dic[@"lng"]doubleValue];
        
        mapAnnotation.coordinate =  CLLocationCoordinate2DMake(latitude,
                                                               longitude);
        CLLocationCoordinate2D newCoordinate = [mapAnnotation coordinate];
        CLLocationCoordinate2D oldCoordinate = [self.locationManager.location coordinate];
        CLLocation *newLocation = [[CLLocation alloc] initWithCoordinate: newCoordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:1 timestamp:nil];
        CLLocation *oldLocation = [[CLLocation alloc] initWithCoordinate: oldCoordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:1 timestamp:nil];
        CLLocationDistance kilometers = [newLocation distanceFromLocation:oldLocation] / 914.4;
        int k = kilometers;
        mapAnnotation.distance = [NSString stringWithFormat:@"%d",k];
        oldLocation = nil;
        newLocation = nil;
        
        __weak typeof(emsMapEssence) *weakMapAnnotation = mapAnnotation;
        
        mapAnnotation.deleteBlock = ^(id<MKAnnotation> obj){
            
            [self.mapView removeAnnotation: obj];
            
            [self deleteUser:weakMapAnnotation];
        };
        
        mapAnnotation.followBlock = ^(id<MKAnnotation> obj){
            
            [self.mapView removeAnnotation: obj];
            
            [self followUser:weakMapAnnotation];
        };
        
        mapAnnotation.closeSelfOnMap  = ^(id<MKAnnotation> obj){
            
            [self.mapView deselectAnnotation:obj animated:YES ];
            
        };
        
        mapAnnotation.infoBlock = ^{
            
            if (dic[@"uId"]){
                
                emsProfileVC *reg = [[emsProfileVC alloc] initWithNibName:@"emsProfileVC" bundle:nil];
                
                reg.profileUserId = dic[@"uId"];
                
                [self presentViewController:reg animated:YES completion:^{
                    
                }];
            }
            
            if (dic[@"aId"]){
                
                [self presentViewController:[[ActivityDetailViewController alloc] initWithData:dic] animated:YES completion:^{
                    
                }];
            }
        };
        
        
        [self.mapView addAnnotation:[emsMapEssentionAnnotation annotationWithThumbnail:mapAnnotation]];
        [self.annotationsArray  addObject:mapAnnotation];
    }
    
    
    [self getAllActivities ];
    [self getAllBySingle];
    [self getAllByInterests];
    [self getRewards];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:YES];
    [self parseData ];
  
    [self performSelector:@selector(stopSubview) withObject:nil afterDelay:1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachability:) name:@"EMSReachableChanged" object:nil];
}

/*!
 *  @discussion Checks internet connection
 *
 */
-(void)reachability:(NSNotification *)notification
{
    BOOL status = (BOOL)notification.userInfo[@"status"];
    {
        
        if(status==YES){
             [self stopSubview];
        }else if(status == NO){
            [self progress];
        }
        
    }
    
}
#pragma mark - CLLocationManagerDelegate
/*!
 *  @discussion Method returns user location
 *
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
 *  @discussion Method sets map visible region
 *
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
    region.center.latitude = self.locationManager.location.coordinate.latitude;
    region.center.longitude = self.locationManager.location.coordinate.longitude;
    region.span.longitudeDelta = 3.5f;
    region.span.longitudeDelta = 3.5f;
    [self.mapView setRegion:region animated:NO];
    [self.locationManager stopUpdatingLocation];
    
}
/*!
 *  @discussion Method sets map visible region
 *
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
    
    _mapView.mapType = MKMapTypeStandard;
    
}



-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:YES];
    
}
-(void)dealloc{
    NSLog(@"%@ dealloc", self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self progress];
    self.annotationsArray = [[NSMutableArray alloc] init];
    [self setUpButtons];
    [self initLicator];
    
}

/*!
 *  @discussion Method sets buttons array
 *
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
 *  @discussion Method sets selected state to button
 *
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
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma Mark Map

/*!
 *  @discussion mapView delegate
 *
 */
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view conformsToProtocol:@protocol(MapEssenceViewProtocol)]) {
        [((NSObject<MapEssenceViewProtocol> *)view) didSelectAnnotationViewInMap:mapView];
    }
}
/*!
 *  @discussion mapView delegate
 *
 */
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view conformsToProtocol:@protocol(MapEssenceViewProtocol)]) {
        [((NSObject<MapEssenceViewProtocol> *)view) didDeselectAnnotationViewInMap:mapView];
    }
}
/*!
 *  @discussion mapView delegate
 *
 */
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([[annotation class] isEqual:[MKUserLocation class]]) {
        MKAnnotationView *view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"customAnnotation"];
        view.image = [UIImage imageNamed:@"location_icon"];
        return view;
    }
    if ([annotation conformsToProtocol:@protocol(JPSThumbnailAnnotationProtocol)]) {
        
        return [((NSObject<JPSThumbnailAnnotationProtocol> *)annotation) annotationViewInMap:mapView];
    }
    return nil;
}


/*!
 *  @discussion  Method updates users pins on map
 *  @return: an `emsMapEssence` objects as a NSObject
 *  @param :'latitude' and 'longitude' should be passed to get information  of particular single users pins
 *  @warning: there is shout work locations classes
 */

-(void)updateAll{
    
    [self.parseArrayUsers removeAllObjects];
    
    [self.parseArrayUsers addObjectsFromArray:[Server mainPage:[[emsGlobalLocationServer sharedInstance] latitude]
                                                       andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                                                      andStart: [NSString stringWithFormat: @"%ld", (long)self.totalNumberOfAllSection]
                                                      andLimit:[NSString stringWithFormat: @"%d",100 /*self.uploadCountOfAllSection*/]]];
    
    
    for (NSDictionary *dic in self.parseArrayUsers) {
        
        emsMapEssence *mapAnnotation = [[emsMapEssence alloc] init];
        
        if (dic[@"uId"]){
            mapAnnotation.essenceType = userEssence;
            mapAnnotation.essenceID = dic[@"uId"];
            mapAnnotation.infoBlock = ^{
                if (dic[@"uId"]){
                    emsProfileVC *reg = [[emsProfileVC alloc] initWithNibName:@"emsProfileVC" bundle:nil];
                    
                    reg.profileUserId = dic[@"uId"];
                    
                    [self presentViewController:reg animated:YES completion:^{
                        
                    }];
                }
                
                if (dic[@"aId"]){
                    
                    [self presentViewController:[[ActivityDetailViewController alloc] initWithData:dic] animated:YES completion:^{
                        
                    }];
                }
            };
            
        }
        
        if (dic[@"aId"]){
            mapAnnotation.essenceType = activityEssence;
            mapAnnotation.essenceID = dic[@"activityOwnerId"];
            mapAnnotation.essenceActivityFollowID = dic[@"aId"];
        }

        mapAnnotation.title = dic[@"name"];
        mapAnnotation.subtitle = dic[@"interestsStr"];
        mapAnnotation.interestImageUrl = dic[@"primaryInterestsImg"];
        mapAnnotation.annotationImageUrl = dic[@"userImg"];
        
        double latitude = [dic[@"lat"] doubleValue];
        double longitude = [dic[@"lng"]doubleValue];
        
        mapAnnotation.coordinate =  CLLocationCoordinate2DMake(latitude,
                                                               longitude);
        CLLocationCoordinate2D newCoordinate = [mapAnnotation coordinate];
        CLLocationCoordinate2D oldCoordinate = [self.locationManager.location coordinate];
        CLLocation *newLocation = [[CLLocation alloc] initWithCoordinate: newCoordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:1 timestamp:nil];
        CLLocation *oldLocation = [[CLLocation alloc] initWithCoordinate: oldCoordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:1 timestamp:nil];
        CLLocationDistance kilometers = [newLocation distanceFromLocation:oldLocation] / 914.4;
        int k = kilometers;
        mapAnnotation.distance = [NSString stringWithFormat:@"%d",k];
        oldLocation = nil;
        newLocation = nil;
        
        __weak typeof(emsMapEssence) *weakMapAnnotation = mapAnnotation;
        
        mapAnnotation.deleteBlock = ^(id<MKAnnotation> obj){
            
            [self.mapView removeAnnotation: obj];
            
            [self deleteUser:weakMapAnnotation];
        };
        
        mapAnnotation.followBlock = ^(id<MKAnnotation> obj){
            
            [self.mapView removeAnnotation: obj];
            
            [self followUser:weakMapAnnotation];
        };
        
        mapAnnotation.closeSelfOnMap  = ^(id<MKAnnotation> obj){
            
            [self.mapView deselectAnnotation:obj animated:YES ];
            
        };
        
        [self.mapView addAnnotation:[emsMapEssentionAnnotation annotationWithThumbnail:mapAnnotation]];
        
        [self.annotationsArray  addObject:mapAnnotation];
    }
    
    
}

/*!
 *  @discussion  Method reloads map view
 */

-(IBAction)mapAction:(id)sender{
    
    [self progress];
    for (UIButton *btn in self.buttonsArray) {
        [btn setSelected:NO];
    }
    UIButton *btn =(UIButton *)[self.buttonsArray objectAtIndex:0];
    [btn setSelected:YES];
    
    [self updateAll];
    
    [self performSelector:@selector(stopSubview) withObject:nil afterDelay:1];
}
-(IBAction)sociarRodar:(id)sender{
    [self presentViewController:[[emsMainScreenVC alloc] init] animated:YES completion:^{
        [self clearData ];
    }];
}

#pragma Mark rightMenuDelegate

/*!
 *  @discussion Right Menu Delegate method
 */

-(void)notificationSelected:(Notification *)notification
{
    [[self.childViewControllers lastObject] willMoveToParentViewController:nil];
    [[[self.childViewControllers lastObject] view] removeFromSuperview];
    [[self.childViewControllers lastObject] removeFromParentViewController];
    
    
}

#pragma mark - Predicate

/*!
 *  @discussion Method refreshes pins on map view
 */

-(void)reloudTable:(NSArray *)arr{
   
    
    NSMutableArray *locs = [[NSMutableArray alloc] init];
    
    for (id <MKAnnotation> annot in [self.mapView annotations])
    {
        if ( [annot isKindOfClass:[ MKUserLocation class]] ) {
        }
        else {
            [locs addObject:annot];
        }
    }
    [self.mapView removeAnnotations:locs];
    
    locs = nil;
    
    for (int i = 0; i < [arr count]; i++) {
        
        emsMapEssence *mapAnnotation = [arr objectAtIndex:i];
        
        [self.mapView addAnnotation:[emsMapEssentionAnnotation annotationWithThumbnail:mapAnnotation]];
        
    }
    
}




#pragma mark - Predicates

/*!
 *  @discussion  Method updates users pins on map by clicks by "all" button
 *  @return: an `emsMapEssence` objects as a NSObject
 *  @param :'latitude' and 'longitude' should be passed to get information  of particular single users pins
 *  @warning: there is shout work locations classes
 */

-(IBAction)allAction{
    
    NSMutableArray * dictionaryArrayActivities = [[NSMutableArray alloc] initWithArray:[Server mainPage:[[emsGlobalLocationServer sharedInstance] latitude]
                                                                                                andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                                                                                               andStart: [NSString stringWithFormat: @"%ld", (long)self.totalNumberOfAllSection]
                                                                                               andLimit:[NSString stringWithFormat: @"%d",100 /*self.uploadCountOfAllSection*/]]];
    
    
    
    
    
    for (NSDictionary *dic in dictionaryArrayActivities) {
        
        emsMapEssence *mapAnnotation = [[emsMapEssence alloc] init];
        
        if (dic[@"uId"]){
            mapAnnotation.essenceType = userEssence;
            mapAnnotation.essenceID = dic[@"uId"];
            mapAnnotation.infoBlock = ^{
                emsProfileVC *reg = [[emsProfileVC alloc] initWithNibName:@"emsProfileVC" bundle:nil];
                
                reg.profileUserId = dic[@"uId"];
                
                [self presentViewController:reg animated:YES completion:^{
                    
                }];
            };
            
        }
        
        if (dic[@"aId"]){
            mapAnnotation.essenceType = activityEssence;
            mapAnnotation.essenceID = dic[@"activityOwnerId"];
            mapAnnotation.essenceActivityFollowID = dic[@"aId"];
        }
        mapAnnotation.title = dic[@"name"];
        mapAnnotation.subtitle = dic[@"interestsStr"];
        mapAnnotation.interestImageUrl = dic[@"primaryInterestsImg"];
        mapAnnotation.annotationImageUrl = dic[@"userImg"];
        
        double latitude = [dic[@"lat"] doubleValue];
        double longitude = [dic[@"lng"]doubleValue];
        
        mapAnnotation.coordinate =  CLLocationCoordinate2DMake(latitude,
                                                               longitude);
        CLLocationCoordinate2D newCoordinate = [mapAnnotation coordinate];
        CLLocationCoordinate2D oldCoordinate = [self.locationManager.location coordinate];
        CLLocation *newLocation = [[CLLocation alloc] initWithCoordinate: newCoordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:1 timestamp:nil];
        CLLocation *oldLocation = [[CLLocation alloc] initWithCoordinate: oldCoordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:1 timestamp:nil];
        CLLocationDistance kilometers = [newLocation distanceFromLocation:oldLocation] / 914.4;
        int k = kilometers;
        mapAnnotation.distance = [NSString stringWithFormat:@"%d",k];
        oldLocation = nil;
        newLocation = nil;
        
        __weak typeof(emsMapEssence) *weakMapAnnotation = mapAnnotation;
        
        mapAnnotation.deleteBlock = ^(id<MKAnnotation> obj){
            
            [self.mapView removeAnnotation: obj];
            
            [self deleteUser:weakMapAnnotation];
        };
        
        mapAnnotation.followBlock = ^(id<MKAnnotation> obj){
            
            [self.mapView removeAnnotation: obj];
            
            [self followUser:weakMapAnnotation];
        };
        
        mapAnnotation.closeSelfOnMap  = ^(id<MKAnnotation> obj){
            
            [self.mapView deselectAnnotation:obj animated:YES ];
            
        };
        
        [self.mapView addAnnotation:[emsMapEssentionAnnotation annotationWithThumbnail:mapAnnotation]];
        [self.annotationsArray  addObject:mapAnnotation];
    }
    
    
    [self.parseArray removeAllObjects];
    
    [self.parseArray addObjectsFromArray:self.self.annotationsArray ];
    
    [self reloudTable:self.parseArray];
    
    [self performSelector:@selector(stopSubview) withObject:nil afterDelay:1];
}


/*!
 *  @discussion  Method updates activity pins on map by clicks by "Activity" button
 *  @return: an `emsMapEssence` objects as a NSObject
 *  @param :'latitude' and 'longitude' should be passed to get information  of particular activities pins
 *  @warning: there is shout work locations classes
 */

-(IBAction)activity{ // Activity Action
    
    NSMutableArray * dictionaryArrayActivities = [[NSMutableArray alloc] initWithArray:[Server activities:[[emsGlobalLocationServer sharedInstance] latitude]
                                                                                                  andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                                                                                                  andStart: [NSString stringWithFormat: @"%ld", (long)self.totalNumberOfActivity]
                                                                                                  andLimit:[NSString stringWithFormat: @"%d",100 /*self.uploadCountOfAllSection*/]]];
    for (NSDictionary *dic in dictionaryArrayActivities) {
        
        emsMapEssence *mapAnnotation = [[emsMapEssence alloc] init];
        
        if (dic[@"uId"]){
            mapAnnotation.essenceType = userEssence;
            mapAnnotation.essenceID = dic[@"uId"];
        }
        
        if (dic[@"aId"]){
            mapAnnotation.essenceType = activityEssence;
            mapAnnotation.essenceID = dic[@"activityOwnerId"];
            mapAnnotation.essenceActivityFollowID = dic[@"aId"];
        }
        mapAnnotation.title = dic[@"name"];
        mapAnnotation.subtitle = dic[@"interestsStr"];
        mapAnnotation.interestImageUrl = dic[@"primaryInterestsImg"];
        mapAnnotation.annotationImageUrl = dic[@"userImg"];
        
        double latitude = [dic[@"lat"] doubleValue];
        double longitude = [dic[@"lng"]doubleValue];
        
        mapAnnotation.coordinate =  CLLocationCoordinate2DMake(latitude,
                                                               longitude);
        
        CLLocationCoordinate2D newCoordinate = [mapAnnotation coordinate];
        CLLocationCoordinate2D oldCoordinate = [self.locationManager.location coordinate];
        CLLocation *newLocation = [[CLLocation alloc] initWithCoordinate: newCoordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:1 timestamp:nil];
        CLLocation *oldLocation = [[CLLocation alloc] initWithCoordinate: oldCoordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:1 timestamp:nil];
        CLLocationDistance kilometers = [newLocation distanceFromLocation:oldLocation] / 914.4;
        int k = kilometers;
        mapAnnotation.distance = [NSString stringWithFormat:@"%d",k];
        oldLocation = nil;
        newLocation = nil;
        
        __weak typeof(emsMapEssence) *weakMapAnnotation = mapAnnotation;
        
        mapAnnotation.infoBlock = ^{
            if (dic[@"uId"]){
                emsProfileVC *reg = [[emsProfileVC alloc] initWithNibName:@"emsProfileVC" bundle:nil];
                
                reg.profileUserId = dic[@"uId"];
                
                [self presentViewController:reg animated:YES completion:^{
                    
                }];
            }
            
            if (dic[@"aId"]){
                
                [self presentViewController:[[ActivityDetailViewController alloc] initWithData:dic] animated:YES completion:^{
                    
                }];
            }
            
        };
        
        mapAnnotation.deleteBlock = ^(id<MKAnnotation> obj){
            
            [self.mapView removeAnnotation: obj];
            
            [self deleteUser:weakMapAnnotation];
        };
        
        mapAnnotation.followBlock = ^(id<MKAnnotation> obj){
            
            [self.mapView removeAnnotation: obj];
            
            [self followUser:weakMapAnnotation];
        };
        
        mapAnnotation.closeSelfOnMap  = ^(id<MKAnnotation> obj){
            
            [self.mapView deselectAnnotation:obj animated:YES ];
            
        };
        
        [self.essenceArrayFromDictionaryActivities  addObject:mapAnnotation];
    }
    
    
    [self.parseArray removeAllObjects];
    
    [self.parseArray addObjectsFromArray:self.essenceArrayFromDictionaryActivities];
    
    [self reloudTable:self.parseArray];
    
    [self performSelector:@selector(stopSubview) withObject:nil afterDelay:1];
}


/*!
 *  @discussion  Method updates single users pins on map by clicks by "Single" button
 *  @return: an `emsMapEssence` objects as a NSObject
 *  @param :'latitude' and 'longitude' should be passed to get information  of particular single users pins
 *  @warning: there is shout work locations classes
 */
-(IBAction)single{

    NSMutableArray * dictionaryArraySingle = [[NSMutableArray alloc] initWithArray:[Server interests:[[emsGlobalLocationServer sharedInstance] latitude]
                                                                                            andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                                                                                            andGender:@"0"
                                                                                            andStart: [NSString stringWithFormat: @"%ld", (long)self.totalNumberOfSingle]
                                                                                            andLimit:[NSString stringWithFormat: @"%d", 100]]];
    self.essenceArrayFromDictionarySingle = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dic in dictionaryArraySingle) {
        
        emsMapEssence *mapAnnotation = [[emsMapEssence alloc] init];
        
        if (dic[@"uId"]){
            mapAnnotation.essenceType = userEssence;
            mapAnnotation.essenceID = dic[@"uId"];
        }
        
        if (dic[@"aId"]){
            mapAnnotation.essenceType = activityEssence;
            mapAnnotation.essenceID = dic[@"activityOwnerId"];
            mapAnnotation.essenceActivityFollowID = dic[@"aId"];
        }
        
        mapAnnotation.title = dic[@"name"];
        mapAnnotation.subtitle = dic[@"interestsStr"];
        mapAnnotation.interestImageUrl = dic[@"primaryInterestsImg"];
        mapAnnotation.annotationImageUrl = dic[@"userImg"];
        
        double latitude = [dic[@"lat"] doubleValue];
        double longitude = [dic[@"lng"]doubleValue];
        
        mapAnnotation.coordinate =  CLLocationCoordinate2DMake(latitude,
                                                               longitude);
        
        CLLocationCoordinate2D newCoordinate = [mapAnnotation coordinate];
        CLLocationCoordinate2D oldCoordinate = [self.locationManager.location coordinate];
        CLLocation *newLocation = [[CLLocation alloc] initWithCoordinate: newCoordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:1 timestamp:nil];
        CLLocation *oldLocation = [[CLLocation alloc] initWithCoordinate: oldCoordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:1 timestamp:nil];
        CLLocationDistance kilometers = [newLocation distanceFromLocation:oldLocation] / 914.4;
        int k = kilometers;
        mapAnnotation.distance = [NSString stringWithFormat:@"%d",k];
        oldLocation = nil;
        newLocation = nil;
        
        __weak typeof(emsMapEssence) *weakMapAnnotation = mapAnnotation;
        
        mapAnnotation.infoBlock = ^{
            if (dic[@"uId"]){
                emsProfileVC *reg = [[emsProfileVC alloc] initWithNibName:@"emsProfileVC" bundle:nil];
                
                reg.profileUserId = dic[@"uId"];
                
                [self presentViewController:reg animated:YES completion:^{
                    
                }];
            }
            
            if (dic[@"aId"]){
                
                [self presentViewController:[[ActivityDetailViewController alloc] initWithData:dic] animated:YES completion:^{
                    
                }];
            }
            
        };
        
        mapAnnotation.deleteBlock = ^(id<MKAnnotation> obj){
            
            [self.mapView removeAnnotation: obj];
            
            [self deleteUser:weakMapAnnotation];
        };
        
        mapAnnotation.followBlock = ^(id<MKAnnotation> obj){
            
            [self.mapView removeAnnotation: obj];
            
            [self followUser:weakMapAnnotation];
        };
        
        mapAnnotation.closeSelfOnMap  = ^(id<MKAnnotation> obj){
            
            [self.mapView deselectAnnotation:obj animated:YES ];
            
        };
        
        [self.essenceArrayFromDictionarySingle  addObject:mapAnnotation];
    }
    
    [self.parseArray removeAllObjects];
    
    [self.parseArray addObjectsFromArray:self.essenceArrayFromDictionarySingle];
    
    [self reloudTable:self.parseArray];
    [self performSelector:@selector(stopSubview) withObject:nil afterDelay:1];
}
/*!
 *  @discussion  Method updates single users pins on map by clicks by "Single" button
 *  @return: an `emsMapEssence` objects as a NSObject
 *  @param :latitude and longitude should be passed to get information  of particular single users pins
 *  @warning: there is shout work locations classes
 */

-(IBAction)interests{
    
    NSMutableArray * dictionaryArrayInterests = [[NSMutableArray alloc] initWithArray:[Server interests:[[emsGlobalLocationServer sharedInstance] latitude]
                                                                                                andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                                                                                                andGender:nil
                                                                                                andStart: [NSString stringWithFormat: @"%ld", (long)self.totalNumberOfInterests]
                                                                                                andLimit: [NSString stringWithFormat: @"%d", 100]]];;
    self.essenceArrayFromDictionaryInterests = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dic in dictionaryArrayInterests) {
        
        emsMapEssence *mapAnnotation = [[emsMapEssence alloc] init];
        
        if (dic[@"uId"]){
            mapAnnotation.essenceType = userEssence;
            mapAnnotation.essenceID = dic[@"uId"];
        }
        
        if (dic[@"aId"]){
            mapAnnotation.essenceType = activityEssence;
            mapAnnotation.essenceID = dic[@"activityOwnerId"];
            mapAnnotation.essenceActivityFollowID = dic[@"aId"];
        }

        mapAnnotation.title = dic[@"name"];
        mapAnnotation.subtitle = dic[@"interestsStr"];
        mapAnnotation.interestImageUrl = dic[@"primaryInterestsImg"];
        mapAnnotation.annotationImageUrl = dic[@"userImg"];
        
        double latitude = [dic[@"lat"] doubleValue];
        double longitude = [dic[@"lng"]doubleValue];
        
        mapAnnotation.coordinate =  CLLocationCoordinate2DMake(latitude,
                                                               longitude);
        
        CLLocationCoordinate2D newCoordinate = [mapAnnotation coordinate];
        CLLocationCoordinate2D oldCoordinate = [self.locationManager.location coordinate];
        CLLocation *newLocation = [[CLLocation alloc] initWithCoordinate: newCoordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:1 timestamp:nil];
        CLLocation *oldLocation = [[CLLocation alloc] initWithCoordinate: oldCoordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:1 timestamp:nil];
        CLLocationDistance kilometers = [newLocation distanceFromLocation:oldLocation] / 914.4;
        int k = kilometers;
        mapAnnotation.distance = [NSString stringWithFormat:@"%d",k];
        oldLocation = nil;
        newLocation = nil;
        
        __weak typeof(emsMapEssence) *weakMapAnnotation = mapAnnotation;
        
        mapAnnotation.infoBlock = ^{
            
            if (dic[@"uId"]){
                emsProfileVC *reg = [[emsProfileVC alloc] initWithNibName:@"emsProfileVC" bundle:nil];
                
                reg.profileUserId = dic[@"uId"];
                
                [self presentViewController:reg animated:YES completion:^{
                    
                }];
            }
            
            if (dic[@"aId"]){
                
                [self presentViewController:[[ActivityDetailViewController alloc] initWithData:dic] animated:YES completion:^{
                    
                }];
            }
        };
        
        mapAnnotation.deleteBlock = ^(id<MKAnnotation> obj){
            
            [self.mapView removeAnnotation: obj];
            
            [self deleteUser:weakMapAnnotation];
            
        };
        
        mapAnnotation.followBlock = ^(id<MKAnnotation> obj){
            
            [self.mapView removeAnnotation: obj];
            
            [self followUser:weakMapAnnotation];
        };
        
        mapAnnotation.closeSelfOnMap  = ^(id<MKAnnotation> obj){
            
            [self.mapView deselectAnnotation:obj animated:YES ];
            
        };
        
        [self.essenceArrayFromDictionaryInterests  addObject:mapAnnotation];
    }
    
    
    [self.parseArray removeAllObjects];
    
    [self.parseArray addObjectsFromArray:self.essenceArrayFromDictionaryInterests];
    
    [self reloudTable:self.parseArray];
    
    [self performSelector:@selector(stopSubview) withObject:nil afterDelay:1];
    
}

/*!
 *  @discussion  Method updates rewards pins on map by clicks by "Rewards" button
 *  @return: an `emsMapEssence` objects as a NSObject
 *  @param :'latitude' and 'longitude' should be passed to get information  of particular rewards pins
 *  @warning: there is shout work locations classes
 */
-(IBAction)rewards{

    NSMutableArray *dictionaryArrayRewards = [[NSMutableArray alloc]initWithArray:[Server rewards:[[emsGlobalLocationServer sharedInstance] latitude]
                                                                                          andLong:[[emsGlobalLocationServer sharedInstance] longitude]
                                                                                          andStart: [NSString stringWithFormat: @"%ld", (long)self.totalNumberOfRewards]
                                                                                         andLimit: [NSString stringWithFormat: @"%d", 1000]]];
    
    for (NSDictionary *dic in dictionaryArrayRewards) {
        
        emsMapEssence *mapAnnotation = [[emsMapEssence alloc] init];
        if (dic[@"uId"]){
            mapAnnotation.essenceType = userEssence;
            mapAnnotation.essenceID = dic[@"uId"];
        }
        
        if (dic[@"aId"]){
            mapAnnotation.essenceType = activityEssence;
            mapAnnotation.essenceID = dic[@"activityOwnerId"];
            mapAnnotation.essenceActivityFollowID = dic[@"aId"];
        }
        
        mapAnnotation.title = dic[@"name"];
        mapAnnotation.subtitle = dic[@"interestsStr"];
        mapAnnotation.interestImageUrl = dic[@"primaryInterestsImg"];
        mapAnnotation.annotationImageUrl = dic[@"userImg"];
        
        double latitude = [dic[@"lat"] doubleValue];
        double longitude = [dic[@"lng"]doubleValue];
        
        mapAnnotation.coordinate =  CLLocationCoordinate2DMake(latitude,
                                                               longitude);
        
        CLLocationCoordinate2D newCoordinate = [mapAnnotation coordinate];
        CLLocationCoordinate2D oldCoordinate = [self.locationManager.location coordinate];
        CLLocation *newLocation = [[CLLocation alloc] initWithCoordinate: newCoordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:1 timestamp:nil];
        CLLocation *oldLocation = [[CLLocation alloc] initWithCoordinate: oldCoordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:1 timestamp:nil];
        CLLocationDistance kilometers = [newLocation distanceFromLocation:oldLocation] / 914.4;
        int k = kilometers;
        mapAnnotation.distance = [NSString stringWithFormat:@"%d",k];
        oldLocation = nil;
        newLocation = nil;
        
        __weak typeof(emsMapEssence) *weakMapAnnotation = mapAnnotation;
        
        mapAnnotation.infoBlock = ^{
            
            if (dic[@"uId"]){
                emsProfileVC *reg = [[emsProfileVC alloc] initWithNibName:@"emsProfileVC" bundle:nil];
                
                reg.profileUserId = dic[@"uId"];
                
                [self presentViewController:reg animated:YES completion:^{
                    
                }];
            }
            
            if (dic[@"aId"]){
                
                [self presentViewController:[[ActivityDetailViewController alloc] initWithData:dic] animated:YES completion:^{
                    
                }];
            }
        };
        mapAnnotation.deleteBlock = ^(id<MKAnnotation> obj){
            
            [self.mapView removeAnnotation: obj];
            
            [self deleteUser:weakMapAnnotation];
        };
        mapAnnotation.followBlock = ^(id<MKAnnotation> obj){
            
            [self.mapView removeAnnotation: obj];
            
            [self followUser:weakMapAnnotation];
        };
        mapAnnotation.closeSelfOnMap  = ^(id<MKAnnotation> obj){
            
            [self.mapView deselectAnnotation:obj animated:YES ];
            
        };
        
        [self.essenceArrayFromDictionaryRewards  addObject:mapAnnotation];
    }
    
    
    [self.parseArray removeAllObjects];
    
    [self.parseArray addObjectsFromArray:self.self.essenceArrayFromDictionaryRewards];
    
    [self reloudTable:self.parseArray];
    [self performSelector:@selector(stopSubview) withObject:nil afterDelay:1];
}



/*!
 *  @discussion Sets up Right Menu
 */

-(IBAction)showRightMenu{
    
    emsRightMenuVC *emsRightMenu = [ [emsRightMenuVC alloc] initWithDelegate:self];
    NSLog(@"emsLeftMenu %@",emsRightMenu.delegate);
}

#pragma Mark leftMenudelegate

/*!
 *  @discussion Sets up Left Menu
 */
-(IBAction)showLeftMenu{
    emsLeftMenuVC *emsLeftMenu =[[emsLeftMenuVC alloc]initWithDelegate:self ];
   
}


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
  *  @discussion Method Sets Popup
 */

-(void)updationLocationThread
{
    
    popup = [[ScadaddlePopup alloc] initWithFrame:self.view.frame withTitle:@"Loading location..." withProgress:YES andButtonsYesNo:NO forTarget:self andMessageType:-1];
    [self.view addSubview:popup];
    
}
-(void)startUpdatingLocation
{
    //[NSThread detachNewThreadSelector:@selector(updationLocationThread) toTarget:self withObject:nil];
    
}
/*
 *  @discussion Sets Popup Custom Progress bar with blured background and Scadaddle
 * Animation
 */
-(void)startUpdating
{

    popup = [[ScadaddlePopup alloc] initWithFrame:self.view.frame withTitle:@"Loading..." withProgress:YES andButtonsYesNo:NO forTarget:self andMessageType:-1];
    [self.view addSubview:popup];
    
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
 * Remove progress view from superView
 */
-(IBAction)dismissPopup
{
    [self dismissPopupAction];
    
}


/*!
 * Method called to clean class instances
  */
-(void)clearData{
    
    self.mapView.showsUserLocation = NO;
    self.mapView.delegate = nil;
    [self.mapView removeFromSuperview];
    self.mapView = nil;
    
    for (UIView *view in self.view.subviews) {
        [view removeFromSuperview];
    }
    [_parseArray removeAllObjects];
    [_parseArrayUsers removeAllObjects];
    [_dictionaryArray removeAllObjects];
    [_dictionaryArrayAll removeAllObjects];
    
    [_essenceArrayFromDictionaryAll removeAllObjects];
    [_essenceArrayFromDictionaryActivities removeAllObjects];
    [_essenceArrayFromDictionaryInterests removeAllObjects];
    [_essenceArrayFromDictionarySingle removeAllObjects];
    [_essenceArrayFromDictionaryRewards removeAllObjects];
    _locationManager = nil;
    [_annotationsArray removeAllObjects];
    
}


/*!
 * Called when left menu actions were pressed
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
 * Called when left menu actions were pressed
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
