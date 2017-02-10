//
//  emsTagsScroll.h
//  Scadaddle
//
//  Created by developer on 12/05/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface emsTagsScroll : UIScrollView
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
- (id)initWithFrame:(CGRect)frame andData:(NSArray *)data;

@end
