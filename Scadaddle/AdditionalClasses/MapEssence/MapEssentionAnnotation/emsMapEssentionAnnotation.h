//
//  emsMapEssentionAnnotation.h
//  Scadaddle
//
//  Created by developer on 14/05/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//



@import Foundation;
@import MapKit;

@class emsMapEssenceView;
@class emsMapEssence;
@protocol JPSThumbnailAnnotationProtocol <NSObject>

- (MKAnnotationView *)annotationViewInMap:(MKMapView *)mapView;

@end


@interface emsMapEssentionAnnotation : NSObject <MKAnnotation, JPSThumbnailAnnotationProtocol>

@property (nonatomic, readwrite) emsMapEssenceView *view;
@property (nonatomic, readonly) emsMapEssence *thumbnail;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;


+ (instancetype)annotationWithThumbnail:(id)thumbnail;
- (id)initWithThumbnail:(id)thumbnail;
- (void)updateThumbnail:(id)thumbnail animated:(BOOL)animated;

@end
