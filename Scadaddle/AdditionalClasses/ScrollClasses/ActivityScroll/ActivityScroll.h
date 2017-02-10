//
//  ActivityScroll.h
//  Scadaddle
//
//  Created by developer on 12/05/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ActivityScrollDelegate;

@interface ActivityScroll : UIView



/*!
 *
 * @discussion  Method  sets  array of images and frame
 * @param data - array
 */

-(id)initWithFrame:(CGRect)frame andData:(NSArray *)data andDelegate:(UIViewController*)delegeteVC;
/*!
 *
 * @discussion  Method  sets class data
 *
 */
-(void)moveInterests;

@property(nonatomic,weak)UIViewController <ActivityScrollDelegate>* delegate;
@property(nonatomic,strong) NSString *userActivityID;
@end


@protocol ActivityScrollDelegate <NSObject>

@end