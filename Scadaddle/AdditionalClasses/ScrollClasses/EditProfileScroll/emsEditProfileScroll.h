//
//  emsEditProfileScroll.h
//  Scadaddle
//
//  Created by developer on 07/07/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditProfileScrollDelegate;

@interface emsEditProfileScroll : UIView
/*!
 *
 * @discussion  Method  sets  array of images and frame
 * @param data - data
 */
- (id)initWithFrame:(CGRect)frame andData:(NSArray *)data;
/*!
 *
 * @discussion  Method  sets  array of images and frame
 * @param data - data
 */
- (void)reloadData:(NSArray *)data;
@property(nonatomic,weak)id <EditProfileScrollDelegate> delegate;


@end





@protocol EditProfileScrollDelegate <NSObject>

-(void)selectrdImage:(NSString *)image andIndex:(int)imageIndex;

-(void)cancelDeletingActionandIndex:(int)imageIndex;


@end