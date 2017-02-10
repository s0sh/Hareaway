 //
//  emsGlobalLocationServer.m
//  Scadaddle
//
//  Created by Roman Bigun on 6/12/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsGlobalLocationServer.h"
#import <UIKit/UIKit.h>
#import "emsAPIHelper.h"
@implementation emsGlobalLocationServer



+ (emsGlobalLocationServer *)sharedInstance
{
    
    static emsGlobalLocationServer * _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[emsGlobalLocationServer alloc] init];
        
    });
    
    return _sharedInstance;
}

-(id)init
{
    
    self = [super init];
    if(self)
    {
            locationManager = [[CLLocationManager alloc] init];
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            locationManager.distanceFilter = kCLLocationAccuracyHundredMeters;
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 &&
                [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse
                //[CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways
                )
            {
               
                [locationManager requestWhenInUseAuthorization];
               
            } else {
                [locationManager startUpdatingLocation]; //Will update location immediately
            }
      ////[Flurry setDelegate:self];
       curLocation = [[CLLocation alloc] init];
    }
    
    return self;
    
}
#pragma mark - CLLocationManagerDelegate
/*!
 * @discussion  Authorize user to have access to location service
 */
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
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
//Handle error
}
- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error{
    
}
/*!
 * @discussion  Flurry delegate method
 */
-(void)flurrySessionDidCreateWithInfo:(NSDictionary *)info
{
    
    NSLog(@"FLURRY[globalLocationManager] \n%@",info);
    
}
/*!
 * @discussion  updates current user location and send the data to the server
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"Global Location:\n%@",[locations lastObject]);
    curLocation = [locations lastObject];
    [Server updateLocations:[[NSString stringWithFormat:@"%f",curLocation.coordinate.latitude] copy] lng:[[NSString stringWithFormat:@"%f",curLocation.coordinate.longitude] copy]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Scadaddle_LocationUpdated_service"
                                                        object:self
                                                      userInfo:nil];
}
/*!
 * @discussion  to get current latitide
 */
-(NSString*)latitude
{
    NSLog(@"Lat:%@",[NSString stringWithFormat:@"%f",curLocation.coordinate.latitude]);
    return [[NSString stringWithFormat:@"%f",curLocation.coordinate.latitude] copy];

}
/*!
 * @discussion  to get current longitude
 */
-(NSString*)longitude
{
    NSLog(@"Long:%@",[NSString stringWithFormat:@"%f",curLocation.coordinate.longitude]);
    return [[NSString stringWithFormat:@"%f",curLocation.coordinate.longitude] copy];
    
}

@end
