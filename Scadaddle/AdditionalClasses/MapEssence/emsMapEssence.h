//
//  emsMapEssence.h
//  Scadaddle
//
//  Created by developer on 14/05/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@import MapKit;
typedef void (^FollowBlock)(id<MKAnnotation> bl);
typedef void (^CloseSelfOnMap)(id<MKAnnotation> bl);
typedef void (^DeleteBlock)(id<MKAnnotation> bl);
typedef void (^InfoBlock)();
typedef NS_ENUM(NSUInteger, MapEssenceType) {
    activityEssence= 0,
    singleEssence,
   interestEssence,
    rewardEssence,
    userEssence
};
@interface emsMapEssence : NSObject
@property (nonatomic, assign) MapEssenceType essenceType;
@property (nonatomic, strong) NSNumber *anID;
@property (nonatomic, copy) UIImage *image;
@property (nonatomic, strong) UIImage *interestImage;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *essenceID;
@property (nonatomic, copy) NSString *distance;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) FollowBlock followBlock;
@property (nonatomic, copy) DeleteBlock deleteBlock;
@property (nonatomic, copy) CloseSelfOnMap closeSelfOnMap;
@property (nonatomic, copy) InfoBlock infoBlock;
@property (nonatomic, copy) NSString *essenceActivityFollowID;
@property (nonatomic, copy) NSString *interestImageUrl;
@property (nonatomic, copy) NSString *annotationImageUrl;
@end
