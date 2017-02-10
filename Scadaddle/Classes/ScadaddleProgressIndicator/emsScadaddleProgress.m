//
//  emsScadaddleProgress.m
//  Scadaddle
//
//  Created by developer on 28/06/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsScadaddleProgress.h"
#import <Accelerate/Accelerate.h>
#import "emsScadaddleActivityIndicator.h"
#import "UIImage+ImageEffects.h"

@interface emsScadaddleProgress ()
@property (nonatomic, strong) emsScadaddleActivityIndicator *activityIndicatorView;
@end


@implementation emsScadaddleProgress


- (id)initWithFrame:(CGRect)frame screenView:(UIView *)view andSize:(CGSize)size
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView* phIm  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        phIm.image = [[self getMainImageView:view andSize:size] applyLightEffect];
        [self addSubview:phIm];
        [self addSubview: self.activityIndicatorView];
        [self active];
        phIm = nil;
        self.activityIndicatorView = nil;
    }
    return self;
}

- (UIImage *) getMainImageView:(UIView *)view andSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}


- (emsScadaddleActivityIndicator *)activityIndicatorView
{
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[emsScadaddleActivityIndicator alloc] initWithActivityIndicatorStyle:FishActivityIndicatorViewStyleleLarge];
        _activityIndicatorView.hidesWhenStopped = NO;
        self.activityIndicatorView.center= self.center;
        ;
    }
    return _activityIndicatorView;
}


- (void)active
{
    if (self.activityIndicatorView.isAnimating) {
        [self.activityIndicatorView stopAnimating];
    } else {
        
        [self.activityIndicatorView startAnimating];
    }
    
}
-(void)dealloc{
    NSArray *viewsToRemove = [self subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
}





@end
