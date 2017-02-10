//
//  emsMapEssentionAnnotation.m
//  Scadaddle
//
//  Created by developer on 14/05/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsMapEssentionAnnotation.h"
#import "emsMapEssence.h"
#import "emsMapEssenceView.h"

@interface emsMapEssentionAnnotation ()



@end


@implementation emsMapEssentionAnnotation


+ (instancetype)annotationWithThumbnail:(emsMapEssence *)thumbnail {
    return [[self alloc] initWithThumbnail:thumbnail];
}

- (id)initWithThumbnail:(emsMapEssence *)thumbnail {
    self = [super init];
    if (self) {
        _coordinate = thumbnail.coordinate;
        _thumbnail = thumbnail;
    }
    return self;
}



- (MKAnnotationView *)annotationViewInMap:(MKMapView *)mapView {
    if (!self.view) {
        self.view = (emsMapEssenceView *)[mapView dequeueReusableAnnotationViewWithIdentifier:0];
        if (!self.view) self.view = [[emsMapEssenceView alloc] initWithAnnotation:self];
    } else {
        self.view.annotation = self;
    }
    [self updateThumbnail:self.thumbnail animated:NO];
    return self.view;
}

- (void)updateThumbnail:(emsMapEssence *)thumbnail animated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.33f animations:^{
            _coordinate = thumbnail.coordinate; // use ivar to avoid triggering setter
        }];
    } else {
        _coordinate = thumbnail.coordinate; // use ivar to avoid triggering setter
    }
    
    [self.view updateWithThumbnail:thumbnail];
}



@end
