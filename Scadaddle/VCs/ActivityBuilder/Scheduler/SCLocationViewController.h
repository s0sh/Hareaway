//
//  SCLocationViewController.h
//  ActivityCreator
//
//  Created by Roman Bigun on 5/8/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
//#import "Flurry.h"
@interface SCLocationViewController : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate,UIGestureRecognizerDelegate>
{

    CLLocationManager *locationManager;
    CLLocation *curLocation;
    CLGeocoder *geocoder;
    __block CLPlacemark *placemark;
    BOOL isLocationChoosen;
    MKAnnotationView *pinView;
    __block NSString *title;
   
}
@property (weak, nonatomic) IBOutlet MKMapView *mapView;


@end
