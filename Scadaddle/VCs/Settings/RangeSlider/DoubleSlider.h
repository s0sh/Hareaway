#import <UIKit/UIKit.h>

@interface DoubleSlider : UIControl {
	float minSelectedValue;
	float maxSelectedValue;
	float minValue;
	float maxValue;
    float valueSpan;
    BOOL latchMin;
    BOOL latchMax;
	
	UIImageView *minHandle;
	UIImageView *maxHandle;
	
	float sliderBarHeight;
    float sliderBarWidth;
	
	CGColorRef bgColor;
}

@property float minSelectedValue;
@property float maxSelectedValue;

@property (nonatomic, retain) UIImageView *minHandle;
@property (nonatomic, retain) UIImageView *maxHandle;

- (id) initWithFrame:(CGRect)aFrame minValue:(float)minValue maxValue:(float)maxValue barHeight:(float)height;
+ (id) doubleSlider;
- (void) moveSlidersToPosition:(NSNumber *)leftSlider:(NSNumber *)rightSlider animated:(BOOL)animated;

@end

