//
//  emsDataScrollView.h
//  Scadaddle
//
//  Created by developer on 12/05/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>




@protocol DataScrollDelegate;

@interface emsDataScrollView : UIScrollView

@property(nonatomic,weak)UIViewController <DataScrollDelegate>* delegate;

/*!
 *
 * @discussion  Method  sets  array of images
 * @param data - array
 */
-(id)initWithData:(NSArray *)data;
/*!
 *
 * @discussion  Method  sets  DataScroll frame and incomin data
 *
 */
- (id)initWithFrame:(CGRect)frame andData:(NSArray *)data andName:(NSString *)name andInterestImage:(NSString *)imsgeStr andFollowings:(NSString *)followCount andAge:(NSString *)age;
/*!
 *
 * @discussion  Method  sets class data
 *
 */
-(void)moveInterests;
@property(retain,nonatomic)NSMutableArray *myDataArray;

@end

@protocol DataScrollDelegate <NSObject>

@end