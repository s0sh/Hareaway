//
//  emsInterestsScroll.m
//  Scadaddle
//
//  Created by developer on 25/06/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//
#import "emsInterestsScroll.h"
#import "ABStoreManager.h"


@interface emsInterestsScroll ()
@property(retain,nonatomic)NSMutableArray *activityArray;
@property(nonatomic, weak)IBOutlet UIView *interestsView;
@property(nonatomic, weak)IBOutlet UIScrollView *interestsScroll;
@property(nonatomic, weak)IBOutlet UIImageView *grayLine;
@property(nonatomic, weak)IBOutlet UIButton *addInterestsButton;
@property(retain,nonatomic)NSString *animationArrow;
@end


@implementation emsInterestsScroll

/*!
 * @discussion to download image by path and set image to appropriate image view
 * @param coverUrl absolute path to image
 * @param targetView set image here after download is complete
 * @param imageName we use it as a unique key to save image in cache
 */
-(void)downloadImage:(NSString *)coverUrl andIndicator:(UIActivityIndicatorView*)indicator addToImageView:(UIImageView*)targetView andImageName:(NSString*)imageName{
    __block UIImage *image = [UIImage new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:coverUrl]];
        image  = [UIImage imageWithData:imageData];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [indicator stopAnimating];
            if (image == nil) {
                
                targetView.image = [UIImage imageNamed:@"placeholder"];
                
            }else{
                
                targetView.image = image;
                if(image)
                    
                    [[[ABStoreManager sharedManager] imageCache] setObject:image forKey:imageName];
                
            }
        });
    });
}


/*!
 * @discussion  check whether image with path @param path cached or not.
 * If cached. add image to target else returns NO to start download
 * @param imageView image view to add retrived from cache image
 * @param path path to image
 */
-(BOOL)imageHandlerInterest:(NSString*)path andInterestView:(UIImageView *)imageView
{
    UIImage *image = [[[ABStoreManager sharedManager] imageCache] objectForKey:path];
    
    if(image)
    {
        imageView.image = image;
        
        return YES;
    }
    
    //  imageView.image = [UIImage imageNamed:@"placeholder"];
    
    return NO;
}

/*!
 *
 * @discussion  Method  sets  array of images and frame
 *
 */
- (id)initWithFrame:(CGRect)frame andData:(NSArray *)data andAnimation:(NSString *)animatiom andUsingType:(UsingTipe)usingTipe
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.usingTipe = usingTipe;
        
        self.animationArrow = animatiom;
        
        self.activityArray = [[NSMutableArray alloc] initWithArray:data];
        
        UINib *nib = [UINib nibWithNibName:@"InterestsScroll" bundle:nil];
        
        [self addSubview:[[nib instantiateWithOwner:self options:nil] objectAtIndex:0]];
        
    }
    return self;
}


/*!
 *
 * @discussion  Method  sets scroll frame
 *
 */
-(void)setUpActivity{
    
    
    if ([self.animationArrow isEqualToString:@"r"]) {
        
        self.frame  =  CGRectMake(320, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        
        [UIView animateWithDuration:.3 animations:^{
            
            self.frame =  CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
            
        } completion:^(BOOL finished) {
            
            if (self.usingTipe == profileScrolls) {
                [self doSelfPofile];
            }else{
                [self doSelfEditPofile];
            }
            
        }];
        
    }
    if ([self.animationArrow isEqualToString:@"l"]) {
        
        self.frame  =  CGRectMake(-320, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        
        [UIView animateWithDuration:.3 animations:^{
            
            self.frame =  CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
            
        } completion:^(BOOL finished) {
            
            if (self.usingTipe == profileScrolls) {
                [self doSelfPofile];
            }else{
                [self doSelfEditPofile];
            }
        }];
        
    }
    
    
    
}



-(void)didMoveToWindow{
    
    //[self setUpActivity];
}
-(void)moveInterests{
    [self setUpActivity];
}


/*!
 *
 * @discussion  Method  sets all scroll components(For profile)
 *
 */

-(void)doSelfPofile{
    
    
    CGFloat myDataScrollIndex = 1;
    CGFloat x=0;
    CGFloat y =0;
    
    
    for (int i =0; i<[self.activityArray count];i++ ) {
        
        
        NSDictionary *data =[self.activityArray objectAtIndex:i];
        x = x+60;
        y = x+64;
        myDataScrollIndex = myDataScrollIndex;
        self.interestsScroll.contentSize = CGSizeMake((64*i)+70 , 0);
        CGRect scrollFrame;
        scrollFrame.origin = self.interestsScroll.frame.origin;
        
        if ( y >320) {
            y =320;
            [self.interestsScroll setContentOffset:CGPointMake(+14,0) animated:YES];
        }
        scrollFrame.size = CGSizeMake( y, self.interestsScroll.frame.size.height);
        self.interestsScroll.frame = scrollFrame;
        self.interestsScroll.center = self.interestsView.center;
        
        
        UIImageView *activityImage = [[UIImageView alloc] init];
        activityImage.frame = CGRectMake(x -20, 2, 44, 44);
        
        if (i !=0) {
            
            UIImageView *grayLine= [[UIImageView alloc] init];
            
            grayLine.frame = CGRectMake(x-36 , 22, 17, 4);
            
            grayLine.backgroundColor = [UIColor lightGrayColor];
            
            [self.interestsScroll addSubview:grayLine];
            
        }
        
        if ([self.activityArray count] == 1) {
            [self.interestsScroll setContentOffset:CGPointMake(7,0) animated:YES];
        }
        if (data[@"img"] && ![data[@"img"] isEqualToString:@""]) {
            
            activityImage.image = [UIImage imageNamed:@"placeholder"];
            
            if(![self imageHandlerInterest:[NSString stringWithFormat:@"%@%@",SERVER_PATH,data[@"img"]] andInterestView:activityImage])
            {
                
                [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,data[@"img"]]
                       andIndicator:nil addToImageView:activityImage andImageName:[NSString stringWithFormat:@"%@%@",SERVER_PATH,data[@"img"]]];
            }
            
        }
        myDataScrollIndex = myDataScrollIndex+activityImage.frame.size.width;
        
        [self cornerIm:activityImage];
        [self.interestsScroll addSubview:activityImage];
        
    }
    
}

/*!
 *
 * @discussion  Method  sets all scroll components(For Edit Pofile)
 *
 */

-(void)doSelfEditPofile{
    
    self.addInterestsButton.hidden = NO;
    CGFloat myDataScrollIndex = 1;
    CGFloat x=0;
    CGFloat y =0;
    
    
    for (int i =0; i<[self.activityArray count];i++ ) {
        
        
        NSDictionary *data =[self.activityArray objectAtIndex:i];
        x = x+52;
        y = x+58;
        myDataScrollIndex = myDataScrollIndex;
        self.interestsScroll.contentSize = CGSizeMake((58*i)+ 70 , 0);
        CGRect scrollFrame;
        scrollFrame.origin = self.interestsScroll.frame.origin;
        
        if ( y >290) {
            y  = 290;
            
        }
        
        scrollFrame.size = CGSizeMake( y, self.interestsScroll.frame.size.height);
        
        self.interestsScroll.frame = scrollFrame;
        
        if ([self.activityArray count]< 5){
            self.interestsScroll.center = self.interestsView.center;
        }
        
        UIImageView *activityImage = [[UIImageView alloc] init];
        activityImage.frame = CGRectMake(x -20, 2, 44, 44);
        
        if (i !=0) {
            
            UIImageView *grayLine= [[UIImageView alloc] init];
            
            grayLine.frame = CGRectMake(x-29 , 22, 11, 4);
            
            grayLine.backgroundColor = [UIColor lightGrayColor];
            
            [self.interestsScroll addSubview:grayLine];
            
        }
        
        if ([self.activityArray count] == 1) {
            
        }
        if (data[@"img"] && ![data[@"img"] isEqualToString:@""]) {
            
            if(![self imageHandlerInterest:[NSString stringWithFormat:@"%@%@",SERVER_PATH,data[@"img"]] andInterestView:activityImage])
            {
                
                [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,data[@"img"]]
                       andIndicator:nil addToImageView:activityImage andImageName:[NSString stringWithFormat:@"%@%@",SERVER_PATH,data[@"img"]]];
            }
            
        }
        myDataScrollIndex = myDataScrollIndex+activityImage.frame.size.width;
        
        [self cornerIm:activityImage];
        [self.interestsScroll addSubview:activityImage];
        
    }
    
    if ([self.activityArray count] > 4){
        
        [self.interestsScroll setContentOffset:CGPointMake(22,0) animated:YES];
        
    }
}

/*!
 *  @discussion Method sets corner radius to images
 */
-(void)cornerIm:(UIImageView*)imageView{
    
    imageView .layer.cornerRadius =  imageView.bounds.size.width/2;
    UIColor *color = [UIColor colorWithRed:139/255.0 green:185/255.0 blue:172/255.0 alpha:1];
    [imageView.layer setBorderColor:color.CGColor];
    [imageView.layer setBorderWidth:1.0];
    imageView.layer.masksToBounds = YES;
}



/*!
 *  @discussion  InterestsrEditingType  delegates
 */
-(IBAction)addInterestsAction{
    
    if (self.interestsrEditingType==spactatorEditingIterests) {
        
        if([self.delegate respondsToSelector:@selector(addSpectatorInterests)]) {
            
            [self.delegate addSpectatorInterests];
        }
        
    }
    if (self.interestsrEditingType==activityEditingInterests) {
        
        if([self.delegate respondsToSelector:@selector(addActivityInterests)]) {
            
            [self.delegate addActivityInterests];
        }
    }
}

-(void)dealloc{
    
    
    
}

@end
