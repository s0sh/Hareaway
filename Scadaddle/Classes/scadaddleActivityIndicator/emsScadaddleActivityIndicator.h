//
//  emsScadaddleActivityIndicator.h
//  Scadaddle
//
//  Created by developer on 28/06/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, FishActivityIndicatorViewStyle) {
    
    FishActivityIndicatorViewStyleleLarge,
    
    FishActivityIndicatorViewStyleNormal,
};

@interface emsScadaddleActivityIndicator : UIView

@property (nonatomic, strong) UIImage *backgroundImage UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIImage *indicatorImage UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) BOOL hidesWhenStopped;
@property (nonatomic, assign) CFTimeInterval fullRotationDuration UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) FishActivityIndicatorViewStyle activityIndicatorViewStyle;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) CGFloat progressFooter;

@property (nonatomic, assign) CGFloat minProgressUnit UI_APPEARANCE_SELECTOR;

/*!
 *  @discussion  Method sets ActivityI ndicator Style
 *  @param : style should be passed
 */

- (id)initWithActivityIndicatorStyle:(FishActivityIndicatorViewStyle)style;
/*!
 *  @discussion  Method starts animating activity indicator
 */
- (void)startAnimating;
/*!
 *  @discussion  Method stops animating activity indicator
 */
- (void)stopAnimating;
/*!
 * @discussion  Method checks if activity indicator is animating
 * @return 0/1
 */
- (BOOL)isAnimating;
/*!
 * @discussion  Method sets  number of revolutions to activity indicator
 *  @param : progress should be passed
 */
- (void)setProgress:(CGFloat)progress;


@end
