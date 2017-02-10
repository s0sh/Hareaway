//
//  emsGlobalLocationServer.h
//  Scadaddle
//
//  Created by Roman Bigun on 6/12/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
//#import "Flurry.h"

@interface emsGlobalLocationServer : NSObject<CLLocationManagerDelegate>
{

    CLLocationManager *locationManager;
    CLLocation *curLocation;
    
}
+ (emsGlobalLocationServer *)sharedInstance;
/*!
 * @discussion  to get current latitide
 */
-(NSString*)latitude;
/*!
 * @discussion  to get current longitude
 */
-(NSString*)longitude;
@end
