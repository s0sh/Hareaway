//
//  emsInterestsScroll.h
//  Scadaddle
//
//  Created by developer on 25/06/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InterestsScrollDelegate;

typedef NS_ENUM(NSUInteger, InterestsrEditingType) {
    spactatorEditingIterests = 0,
    activityEditingInterests
};

typedef NS_ENUM(NSUInteger, UsingTipe) {
    profileScrolls = 0,
    editProfileScrolls
};
@interface emsInterestsScroll : UIView

@property (nonatomic, assign) UsingTipe usingTipe;

@property (nonatomic, assign) InterestsrEditingType interestsrEditingType;

/*!
 *
 * @discussion  Method  sets  array of images and frame
 * @param data - data
 */
- (id)initWithFrame:(CGRect)frame andData:(NSArray *)data andAnimation:(NSString *)animatiom andUsingType:(UsingTipe )usingType;
/*!
 *
 * @discussion  Method  sets class data
 *
 */
-(void)moveInterests;

@property(nonatomic,weak)id <InterestsScrollDelegate> delegate;

@end




@protocol InterestsScrollDelegate <NSObject>

-(void)addSpectatorInterests;

-(void)addActivityInterests;


@end
