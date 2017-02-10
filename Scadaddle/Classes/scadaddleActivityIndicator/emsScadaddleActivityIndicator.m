//
//  emsScadaddleActivityIndicator.m
//  Scadaddle
//
//  Created by developer on 28/06/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsScadaddleActivityIndicator.h"


@interface emsScadaddleActivityIndicator ()

@property (nonatomic, assign) BOOL animating;
@property (nonatomic, strong) UIImageView *indicatorImageView;
@property (nonatomic, strong) UIImageView *backgroundImageView;

@end


@implementation emsScadaddleActivityIndicator
#pragma mark - Accessors

@synthesize animating = _animating;
@synthesize indicatorImage = _indicatorImage;
@synthesize backgroundImage = _backgroundImage;
@synthesize indicatorImageView = _indicatorImageView;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize hidesWhenStopped = _hidesWhenStopped;
@synthesize fullRotationDuration = _fullRotationDuration;
@synthesize progress = _progress;

@synthesize progressFooter = _progressFooter;
@synthesize minProgressUnit = _minProgressUnit;
@synthesize activityIndicatorViewStyle = _activityIndicatorViewStyle;

/*!
 * @discussion  Method sets background ImageView
 */

- (UIImageView *)backgroundImageView
{
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _backgroundImageView;
}
/*!
 * @discussion  Method sets indicator Image
 */

- (UIImageView *)indicatorImageView
{
    if (!_indicatorImageView) {
        _indicatorImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _indicatorImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _indicatorImageView;
}
/*!
 * @discussion  Method sets background Image
 */

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    self.backgroundImageView.image = _backgroundImage;
    [self setNeedsLayout];
}
/*!
 * @discussion  Method sets Indicator Image
 */
- (void)setIndicatorImage:(UIImage *)indicatorImage
{
    _indicatorImage = indicatorImage;
    self.indicatorImageView.image = _indicatorImage;
    [self setNeedsLayout];
}

/*!
 *  @discussion  Method sets ActivityI ndicator Style
 *  @param : style should be passed
 */

- (void)setActivityIndicatorViewStyle:(FishActivityIndicatorViewStyle)activityIndicatorViewStyle
{
    _activityIndicatorViewStyle = activityIndicatorViewStyle;
    
    NSString *backgroundImageName;
    NSString *indicatorImageName;
    switch (_activityIndicatorViewStyle) {
        case FishActivityIndicatorViewStyleNormal:
            backgroundImageName = @"bg_scad_progress_smol";//моя картинка
            indicatorImageName = @"spiner_scad_smol";
            break;
        case FishActivityIndicatorViewStyleleLarge:
            backgroundImageName = @"bg_scad_progress";
            indicatorImageName = @"spiner_scad_progress";
            break;
    }
    
    _backgroundImage = [UIImage imageNamed:backgroundImageName];
    _indicatorImage = [UIImage imageNamed:indicatorImageName];
    self.backgroundImageView.image = _backgroundImage;
    self.indicatorImageView.image = _indicatorImage;
    [self setNeedsLayout];
}
/*!
 * @discussion  Method sets  number of revolutions to activity indicator
 *  @param : progress should be passed
 */
- (BOOL)isAnimating
{
    return self.animating;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self _initialize];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self _initialize];
    }
    return self;
}
/*!
 * @discussion  Method sets all UI alaments
 */
- (void)_initialize
{
    self.userInteractionEnabled = NO;
    
    _animating = NO;
    _hidesWhenStopped = YES;
    _fullRotationDuration = 1.0f;
    
    [self addSubview:self.backgroundImageView];
    [self addSubview:self.indicatorImageView];
}
/*!
 *  @discussion  Method sets ActivityI ndicator Style
 *  @param : style should be passed
 */

- (id)initWithActivityIndicatorStyle:(FishActivityIndicatorViewStyle)style
{
    if ((self = [self initWithFrame:CGRectZero])) {
        self.activityIndicatorViewStyle = style;
        
        [self sizeToFit];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    CGSize backgroundImageSize = self.backgroundImageView.image.size;
    CGSize indicatorImageSize = self.indicatorImageView.image.size;
    
    // Center
    self.backgroundImageView.frame = CGRectMake(roundf((size.width - backgroundImageSize.width) / 2.0f), roundf((size.height - backgroundImageSize.height) / 2.0f), backgroundImageSize.width, backgroundImageSize.height);
    self.indicatorImageView.frame = CGRectMake(roundf((size.width - indicatorImageSize.width) / 2.0f), roundf((size.height - indicatorImageSize.height) / 2.0f), indicatorImageSize.width, indicatorImageSize.height);
}

/*!
 *  @discussion  Method sets frame to backgroundImageView and indicatorImageView
 */
- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize backgroundImageSize = self.backgroundImageView.image.size;
    CGSize indicatorImageSize = self.indicatorImageView.image.size;
    
    return CGSizeMake(fmaxf(backgroundImageSize.width, indicatorImageSize.width), fmaxf(backgroundImageSize.height, indicatorImageSize.height));
}




#pragma mark - Public
/*!
 *  @discussion  Method starts animating activity indicator
 */
- (void)startAnimating
{
    if (self.animating) return;


    self.animating = YES;
    self.hidden = NO;
    [self _rotateImageViewFrom:0.0f to:M_PI*2 duration:self.fullRotationDuration repeatCount:HUGE_VALF];
        
}

/*!
 *  @discussion  Method stops animating activity indicator
 */
- (void)stopAnimating
{
    if (!self.animating) return;
    
    self.animating = NO;
    [self.indicatorImageView.layer removeAllAnimations];
    if (self.hidesWhenStopped) {
        self.hidden = YES;
    }
}

/*!
 * @discussion  Method for activity indicator rotation
 */
- (void)_rotateImageViewFrom:(CGFloat)fromValue to:(CGFloat)toValue duration:(CFTimeInterval)duration repeatCount:(CGFloat)repeatCount
{
    
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:fromValue];
    rotationAnimation.toValue = [NSNumber numberWithFloat:toValue];
    rotationAnimation.RepeatCount = repeatCount;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeForwards;
    rotationAnimation.duration = 2.5;
    [self.indicatorImageView.layer addAnimation:rotationAnimation forKey:@"rotation"];
}

/*!
 * @discussion  Method sets  number of revolutions to activity indicator
 *  @param : progress should be passed
 */
- (void)setProgress:(CGFloat)progress
{
    
    if (progress==0)_progress = progress;
    
    if (_progress > progress ||progress<= -45 ) return;
    
    CGFloat fromValue = M_PI * 2 * _progress;
    CGFloat toValue = M_PI * 2 * progress;
    [self _rotateImageViewFrom:fromValue to:toValue duration:0.15f repeatCount:0];
    
    _progress = progress;
}

/*!
 * @discussion  Method sets  number of revolutions to footer activity indicator
 *  @param : progress should be passed
 */
- (void)setProgressFooter:(CGFloat)progress
{

    
    CGFloat fromValue = M_PI * 2 * _progressFooter;
    CGFloat toValue = M_PI * 2 * progress;
    [self _rotateImageViewFrom:fromValue to:toValue duration:0.15f repeatCount:0];
    
    _progressFooter = progress;
}



-(void)dealloc{
    NSArray *viewsToRemove = [self subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
}



@end
