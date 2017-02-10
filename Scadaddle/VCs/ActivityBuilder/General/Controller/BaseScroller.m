//
//  BaseScroller.m
//  ActivityCreator
//
//  Created by Roman Bigun on 5/6/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "BaseScroller.h"

@interface BaseScroller () <UIScrollViewDelegate>
@end

@implementation BaseScroller
{
    UIScrollView * scroller;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        scroller = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        scroller.delegate = self;
        [self addSubview:scroller];
        UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollerTapped:)];
        [scroller addGestureRecognizer:tapRecognizer];
    }
    return self;
}
- (void)scrollerTapped:(UITapGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:gesture.view];

//     I don't use enumerator 'cos I dont want to enumerate all aubviews
//     I need only to enumerate subviews added by me


    for (int index = 0; index < [self.delegate numberOfViewsForHorizontalScroller:self]; index++)
    {
        UIView * view = scroller.subviews[index];
        if (CGRectContainsPoint(view.frame, location))
        {
            [self.delegate horizontalScroller:self clickedViewAtIndex:index];
            CGPoint offset = CGPointMake(view.frame.origin.x - self.frame.size.width/2 + view.frame.size.width/2, 0);
            [scroller setContentOffset:offset animated:YES];
            break;
        }
    }
}
- (void)reload
{
    // load nothing if there is no delegate:
    if (self.delegate == nil) return;
    
    //remove all subviews:
    [scroller.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
        [obj removeFromSuperview];
    }];
    
    //xValue - start point for all views in the scroller:
    CGFloat xValue = 0;
    for (int i = 0; i < [self.delegate numberOfViewsForHorizontalScroller:self]; i++)
    {
        // 4 - add view in needed position:
        
        UIView * view = [self.delegate horizontalScroller:self viewAtIndex:i];
        view.frame = CGRectMake(xValue, VIEW_PADDING, VIEW_DIMENSIONS, VIEW_DIMENSIONS);
        [scroller addSubview:view];
        xValue += VIEW_DIMENSIONS + VIEW_PADDING;
        xValue += 3;
    }
    [scroller setContentSize:CGSizeMake(xValue + VIEWS_OFFSET, self.frame.size.height)];
    
    // if initialView is defined, move it in the center of scroller:
    if ([self.delegate respondsToSelector:@selector(initialViewIndexForHorizontalScroller:)])
    {
        int initialView = [self.delegate initialViewIndexForHorizontalScroller:self];
        CGPoint offset = CGPointMake(initialView * (VIEW_DIMENSIONS + (2 * VIEW_PADDING)), 0);
        [scroller setContentOffset:offset animated:YES];
    }
}
- (void)didMoveToSuperview
{
    [self reload];
}

- (void)centerCurrentView
{
    int xFinal = scroller.contentOffset.x + (VIEWS_OFFSET / 2) + VIEW_PADDING;
    int viewIndex = xFinal / (VIEW_DIMENSIONS + (2 * VIEW_PADDING));
    xFinal = viewIndex * (VIEW_DIMENSIONS + (2 * VIEW_PADDING));
    [scroller setContentOffset:CGPointMake(xFinal, 0) animated:YES];
    [self.delegate horizontalScroller:self clickedViewAtIndex:viewIndex];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self centerCurrentView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self centerCurrentView];
}

@end
