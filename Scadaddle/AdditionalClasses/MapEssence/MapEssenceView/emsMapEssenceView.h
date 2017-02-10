//
//  emsMapEssenceView.h
//  Scadaddle
//
//  Created by developer on 14/05/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <MapKit/MapKit.h>

//extern NSString * const kJPSThumbnailAnnotationViewReuseID;

static CGFloat const  MapEssenceViewStandardWidth     = 155.0f;
static CGFloat const  MapEssenceViewStandardHeight    = 44.0f;
static CGFloat const  MapEssenceViewExpandOffset      = 170.0f;
static CGFloat const  MapEssenceViewVerticalOffset    = 34.0f;
static CGFloat const  MapEssenceViewAnimationDuration = 0.25f;


typedef NS_ENUM(NSInteger, MapEssenceViewState) {
    MapEssenceViewStateCollapsed,
    MapEssenceViewStateExpanded,
    MapEssenceViewStateAnimating,
};


@protocol MapEssenceViewProtocol <NSObject>

- (void)didSelectAnnotationViewInMap:(MKMapView *)mapView ;
- (void)didDeselectAnnotationViewInMap:(MKMapView *)mapView;

@end



@interface emsMapEssenceView : MKAnnotationView<MapEssenceViewProtocol>
- (id)initWithAnnotation:(id<MKAnnotation>)annotation;
- (void)updateWithThumbnail:(id)mapEssence ;
@end
