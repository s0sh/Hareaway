
#import "DoubleSlider.h"

#define kMinHandleDistance          10.0
#define kBoundaryValueThreshold     0.01
#define kMovingAnimationDuration    0.3

//create the gradient
static const CGFloat colors [] = { 
	0.5, 0.5, 0.5, 1.0,
	1.0, 1.0, 1.0, 1.0
};

//define private methods
@interface DoubleSlider (PrivateMethods)
- (void)updateValues;
- (void)addToContext:(CGContextRef)context roundRect:(CGRect)rrect withRoundedCorner1:(BOOL)c1 corner2:(BOOL)c2 corner3:(BOOL)c3 corner4:(BOOL)c4 radius:(CGFloat)radius;
- (void)updateHandleImages;
@end


@implementation DoubleSlider

@synthesize minSelectedValue, maxSelectedValue;
@synthesize minHandle, maxHandle;

- (void) dealloc
{
	CGColorRelease(bgColor);
	self.minHandle = nil;
	self.maxHandle = nil;
	
}

#pragma mark Object initialization

- (id) initWithFrame:(CGRect)aFrame minValue:(float)aMinValue maxValue:(float)aMaxValue barHeight:(float)height
{
    self = [super initWithFrame:aFrame];
    if (self)
	{
		if (aMinValue < aMaxValue) {
			minValue = aMinValue;
			maxValue = aMaxValue;
		}
		else {
			minValue = aMaxValue;
			maxValue = aMinValue;
		}
        valueSpan = maxValue - minValue;
		sliderBarHeight = height;
        sliderBarWidth = self.frame.size.width / self.transform.a;  //calculate the actual bar width by dividing with the cos of the view's angle

        self.minHandle = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,30,30)];
        self.minHandle.image = [UIImage imageNamed:@"handle1"];
		self.minHandle.center = CGPointMake(minValue, sliderBarHeight * 0.5);
		[self addSubview:self.minHandle];
		
        self.maxHandle = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,30,30)];
        self.maxHandle.image = [UIImage imageNamed:@"handle1"];
		self.maxHandle.center = CGPointMake(maxValue, sliderBarHeight * 0.5);
		[self addSubview:self.maxHandle];
		
		bgColor = CGColorRetain([UIColor colorWithRed:120/255.f green:147/255.f blue:255/255.f alpha:1].CGColor);
		self.backgroundColor = [UIColor clearColor];
		
		//init
        latchMin = NO;
        latchMax = NO;
		//[self updateValues];
	}
	return self;
}

- (void) moveSlidersToPosition:(NSNumber *)leftSlider: (NSNumber *)rightSlider animated:(BOOL)animated

{
    CGFloat duration = animated ? kMovingAnimationDuration : 0.0;
    [UIView transitionWithView:self duration:duration options:UIViewAnimationOptionCurveLinear
                    animations:^(void){
                        self.minHandle.center = CGPointMake(sliderBarWidth * ((float)[leftSlider intValue] / 100), sliderBarHeight * 0.5);
                        self.maxHandle.center = CGPointMake(sliderBarWidth * ((float)[rightSlider intValue] / 100), sliderBarHeight * 0.5);
                        [self updateValues];
                        //force redraw
                        [self setNeedsDisplay];
                        //notify listeners
                        [self sendActionsForControlEvents:UIControlEventValueChanged];
                    }
                    completion:^(BOOL finished) {
                    }];
}
+ (id) doubleSlider
{
	return [[self alloc] initWithFrame:CGRectMake(10.,150., 300., 40.) minValue:0.0 maxValue:100.0 barHeight:7.0];
}

#pragma mark Touch tracking

-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:self];
    if ( CGRectContainsPoint(self.minHandle.frame, touchPoint) ) {
		latchMin = YES;
	}
	else if ( CGRectContainsPoint(self.maxHandle.frame, touchPoint) ) {
		latchMax = YES;
	}
    [self updateHandleImages];
    return YES;
}
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:self];
    if(touchPoint.x>55.f)
    {


	if ( latchMin || CGRectContainsPoint(self.minHandle.frame, touchPoint) ) {
		if (touchPoint.x < self.maxHandle.center.x - kMinHandleDistance && touchPoint.x > 0.0) {
			self.minHandle.center = CGPointMake(touchPoint.x, self.minHandle.center.y);
			[self updateValues];
		}
	}
	else if ( latchMax || CGRectContainsPoint(self.maxHandle.frame, touchPoint) ) {
		if (touchPoint.x > self.minHandle.center.x + kMinHandleDistance && touchPoint.x < sliderBarWidth) {
			self.maxHandle.center = CGPointMake(touchPoint.x, self.maxHandle.center.y);
			[self updateValues];
		}
	}
	// Send value changed alert
	[self sendActionsForControlEvents:UIControlEventValueChanged];
    
	//redraw
	[self setNeedsDisplay];
	return YES;
        
    }
    
    return NO;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    latchMin = NO;
    latchMax = NO;
    [self updateHandleImages];
}

#pragma mark Custom Drawing

- (void) drawRect:(CGRect)rect
{
	//FIX: optimise and save some reusable stuff
	
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
	
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClearRect(context, rect);
	
	CGRect rect1 = CGRectMake(0.0, 0.0, self.minHandle.center.x, sliderBarHeight);
	CGRect rect2 = CGRectMake(self.minHandle.center.x, 0.0, self.maxHandle.center.x - self.minHandle.center.x, sliderBarHeight);
	CGRect rect3 = CGRectMake(self.maxHandle.center.x, 0.0, sliderBarWidth - self.maxHandle.center.x, sliderBarHeight);
    	
    CGContextSaveGState(context);
	
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
	
	//add the right rect
	[self addToContext:context roundRect:rect3 withRoundedCorner1:NO corner2:YES corner3:YES corner4:NO radius:5.0f];
	//add the left rect
	[self addToContext:context roundRect:rect1 withRoundedCorner1:YES corner2:NO corner3:NO corner4:YES radius:5.0f];
	
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	
	CGGradientRelease(gradient), gradient = NULL;
	
	//draw middle rect
    CGContextRestoreGState(context);
	CGContextSetFillColorWithColor(context, bgColor);
	CGContextFillRect(context, rect2);
		
	[super drawRect:rect];
}

- (void)addToContext:(CGContextRef)context roundRect:(CGRect)rrect withRoundedCorner1:(BOOL)c1 corner2:(BOOL)c2 corner3:(BOOL)c3 corner4:(BOOL)c4 radius:(CGFloat)radius
{	
	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
	
	CGContextMoveToPoint(context, minx, midy);
	CGContextAddArcToPoint(context, minx, miny, midx, miny, c1 ? radius : 0.0f);
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, c2 ? radius : 0.0f);
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, c3 ? radius : 0.0f);
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, c4 ? radius : 0.0f);
}


#pragma mark Helper

- (void)updateHandleImages
{
    self.minHandle.highlighted = latchMin;
    self.maxHandle.highlighted = latchMax;
}

- (void)updateValues
{
    NSLog(@"Min Handle %f",self.minHandle.center.x);
    NSLog(@"Max Handle %f",self.maxHandle.center.x);
	self.minSelectedValue = minValue + self.minHandle.center.x / sliderBarWidth * valueSpan;
    //snap to min value
    if (self.minSelectedValue < minValue + kBoundaryValueThreshold * valueSpan)
        self.minSelectedValue = minValue;
        
    self.maxSelectedValue = minValue + self.maxHandle.center.x / sliderBarWidth * valueSpan;
    //snap to max value
    if (self.maxSelectedValue > maxValue - kBoundaryValueThreshold * valueSpan)
        self.maxSelectedValue = maxValue;
    
}

@end