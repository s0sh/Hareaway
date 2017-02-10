//
//  SCLocationViewController.m
//  ActivityCreator
//
//  Created by Roman Bigun on 5/8/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "SCLocationViewController.h"
#import "ABStoreManager.h"
#import "emsInterestsVC.h"
#import "emsInterestsBuilderVC.h"
#import "ScadaddlePopup.h"
@import AddressBookUI;

@interface SCLocationViewController ()
{

    ScadaddlePopup *popup;

}
@end

@implementation SCLocationViewController

/*!
 * @discussion Make rounded corners for images
 */
-(void)cornerImage:(UIImageView*)imageView{
    
    imageView .layer.cornerRadius = 8;
    imageView .layer.borderWidth = 1.0f;
    imageView .layer.borderColor = [UIColor colorWithRed:95/255.f green:129/255.f blue:139/255.f alpha:0.5f].CGColor;
    imageView .layer.shadowColor = [UIColor blackColor].CGColor;
    imageView.layer.masksToBounds = YES;
    
}
/*!
 * @discussion Make rounded corners for the map
 */
-(void)cornerMap:(MKMapView*)imageView{
    
    imageView .layer.cornerRadius = 4;
    imageView .layer.borderWidth = 1.0f;
    imageView .layer.borderColor = [UIColor colorWithRed:95/255.f green:129/255.f blue:139/255.f alpha:0.5f].CGColor;
    imageView .layer.shadowColor = [UIColor blackColor].CGColor;
    imageView.layer.masksToBounds = YES;
    
}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        // Try to dequeue an existing pin view first.
        pinView = (MKAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
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
 * @discussion Init location manager
 */
-(void)initLocator
{
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse
        //[CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways
        ) {
        // Will open an confirm dialog to get user's approval
        [locationManager requestWhenInUseAuthorization];
        //[_locationManager requestAlwaysAuthorization];
    } else {
        [locationManager startUpdatingLocation]; //Will update location immediately
    }
    
}
#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager*)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined: {
            NSLog(@"User still thinking..");
        } break;
        case kCLAuthorizationStatusDenied: {
            NSLog(@"User hates you");
        } break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways: {
            [locationManager startUpdatingLocation]; //Will update location immediately
        } break;
        default:
            break;
    }
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if(![[ABStoreManager sharedManager] editingMode])
    {
    //View Area
    double miles=12.0;
    double scalingFactor= ABS( cos(2 * M_PI * manager.location.coordinate.latitude /360.0) );
    MKCoordinateSpan span;
    span.latitudeDelta=miles/69.0;
    span.longitudeDelta=miles/(scalingFactor*69.0);
    MKCoordinateRegion region;
    region.span=span;
    region.center=manager.location.coordinate;
    _mapView.showsUserLocation = YES;
    [_mapView setRegion:region animated:YES];
    [locationManager stopUpdatingLocation];
    }
}
/*!
 * @discussion If location has already been set this method setup
 * map according to saved data and put on pin to a location
 */
-(void)setSavedLocation
{
   
    if([[ABStoreManager sharedManager] editingMode])
    {
        
        NSDictionary *tmp = [[ABStoreManager sharedManager] editingActivityData];
        NSLog(@"%@",tmp);
        
        [[ABStoreManager sharedManager] setCoordinates:[NSString stringWithFormat:@"%@",tmp[@"lat"]]
                                          andLongitude:[NSString stringWithFormat:@"%@",tmp[@"lng"]]];
        
    }
    
    CLLocation *curLocation1 = [[CLLocation alloc] initWithLatitude:
                                [[[ABStoreManager sharedManager] latitude] doubleValue]
                                                                 longitude:[[[ABStoreManager sharedManager] longitude] doubleValue]];
                                
                                
    CLLocationCoordinate2D coord = {.latitude = curLocation1.coordinate.latitude,.longitude = curLocation1.coordinate.longitude};
    MKCoordinateSpan span = {.latitudeDelta =  3.2, .longitudeDelta =  3.2};
    span = MKCoordinateSpanMake(0, 360/pow(2, 13)*self.mapView.frame.size.width/256);
    MKCoordinateRegion region = {coord, span};
    if(region.center.latitude!=0 && region.center.longitude!=0)
    {
       [self.mapView setRegion:region];
        
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        self.mapView.userLocation.coordinate = coord;
        [self.mapView addAnnotation:point];
        point.coordinate = coord;
        [point setTitle:[self streetName]];
        [point setSubtitle:@"Marked"];
    }
    else
    {
    
        [_mapView showsUserLocation];
    
    }

}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    _mapView.mapType = MKMapTypeHybrid;
    _mapView.delegate = self;
    [self setSavedLocation];//if user has already set location
    title = [[NSString alloc] init];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLLocationAccuracyHundredMeters;
    UITapGestureRecognizer *lpgr = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.delegate = self;
    [self.mapView addGestureRecognizer:lpgr];
    isLocationChoosen = NO;
    ////[Flurry setDelegate:self];
}
/*!
 * @discussion After each tap on the map it saves location and
 * places pin there. This method removes all pins before put a
 * new one
 */
- (void)removeAllPinsButUserLocation
{
    id userLocation = [self.mapView userLocation];
    NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[self.mapView annotations]];
    if ( userLocation != nil ) {
        [pins removeObject:userLocation]; // avoid removing user location off the map
    }
    
    [self.mapView removeAnnotations:pins];
    
    pins = nil;
}
/*!
 * @discussion Put pins and stores its location
 */
- (void)handleLongPress:(UITapGestureRecognizer *)gestureRecognizer
{
      
    
    [self removeAllPinsButUserLocation];
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    self.mapView.userLocation.coordinate = touchMapCoordinate;
    point.coordinate = touchMapCoordinate;
    
    curLocation = [[CLLocation alloc] initWithLatitude:touchMapCoordinate.latitude longitude:touchMapCoordinate.longitude];
    [[ABStoreManager sharedManager] setCoordinates:[NSString stringWithFormat:@"%f",point.coordinate.latitude]
                                    andLongitude:[NSString stringWithFormat:@"%f",point.coordinate.longitude]];
    
    [point setTitle:[self streetName]];
    [point setSubtitle:@"Marked"];
    [self.mapView addAnnotation:point];
    
    isLocationChoosen = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*!
 * @discussion Returns address in readable format
 */
-(NSString*)streetName
{
    geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:curLocation completionHandler:^(NSArray *placemarks, NSError *error)
    {
       // NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        
        if (error == nil && [placemarks count] > 0)
        {
            placemark = [placemarks lastObject];
            
            
            title =  [[NSString alloc] init];
            title = ABCreateStringWithAddressDictionary(placemark.addressDictionary, YES);
            
            
            
        }
        
    }];
    return title;
}
-(void)popupThread
{

    [NSThread detachNewThreadSelector:@selector(startUpdating) toTarget:self withObject:nil];

}
/*!
 * @discussion User tap 'Ingterests' button.
 * Check if location selected
 * Stores it to ABStoreManager for future use
 * Goes to emsInterestsBuilderVC
 */
-(IBAction)checkLocationAndGo
{
    
    CLLocation *curLocation1 = [[CLLocation alloc] initWithLatitude:
                                [[[ABStoreManager sharedManager] latitude] doubleValue] longitude:[[[ABStoreManager sharedManager] latitude] doubleValue]];
    
    
    CLLocationCoordinate2D coord = {.latitude = curLocation1.coordinate.latitude,.longitude = curLocation1.coordinate.longitude};
    MKCoordinateSpan span = {.latitudeDelta =  0.2, .longitudeDelta =  0.2};
    MKCoordinateRegion region = {coord, span};
    
    if (isLocationChoosen || (region.center.latitude!=0 && region.center.longitude!=0)) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%i",1] forKey:@"defaultInterestSelected"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ActivityBuilder_4" bundle:nil];
        emsInterestsBuilderVC *notebook = [storyboard instantiateViewControllerWithIdentifier:@"InterestsBuilderVC"];
        [self presentViewController:notebook animated:YES completion:^{
            
            [self dismissPopup];
            
        }];
        
    }
    else
    {
        [self messagePopupWithTitle:@"Please, select activity location" hideOkButton:NO];
    
    }
    

}

#pragma mark -Popups

-(void)startUpdating
{
    
    popup = [[ScadaddlePopup alloc] initWithFrame:self.view.frame withTitle:@"Saving..." withProgress:YES andButtonsYesNo:NO forTarget:self andMessageType:-1];
    [self.view addSubview:popup];
    
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
 * @param title1 desired message to display on popup
 * @param duration time while disappearing
 * @param exit YES/NO YES to dismiss this controller
 */

-(void)dismissPopupActionWithTitle:(NSString*)title1 andDuration:(double)duration andExit:(BOOL)exit
{
    
    [popup updateTitleWithInfo:title1];
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
-(IBAction)dismissPopup
{
    
    [self dismissPopupActionWithTitle:@"" andDuration:0 andExit:NO];
    
    
}
@end
