//
//  BaseScroller.h
//  ActivityCreator
//
//  Created by Roman Bigun on 5/6/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>
#define VIEW_PADDING 0
#define VIEW_DIMENSIONS 60
#define VIEWS_OFFSET 60
@protocol BaseScrollerDelegate;

@interface BaseScroller : UIView


@property (weak) id<BaseScrollerDelegate> delegate;
- (void)reload;
@end

@protocol BaseScrollerDelegate <NSObject>
@required

- (NSInteger)numberOfViewsForHorizontalScroller:(BaseScroller *)scroller;
- (UIView *)horizontalScroller:(BaseScroller *)scroller viewAtIndex:(int)index;
- (void)horizontalScroller:(BaseScroller *)scroller clickedViewAtIndex:(int)index;
@optional
- (NSInteger)initialViewIndexForHorizontalScroller:(BaseScroller *)scroller;
@end