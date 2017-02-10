//
//  ActivityScroll.m
//  Scadaddle
//
//  Created by developer on 12/05/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "ActivityScroll.h"
#import "emsActivity.h"
#import "ABStoreManager.h"
#import "ActivityGeneralViewController.h"
#import "emsDeviceManager.h"
#import "ActivityDetailViewController.h"

@interface ActivityScroll ()

@property (nonatomic, weak) IBOutlet UIView * holdenView;
@property (nonatomic, weak) IBOutlet UIButton *addNewActivityButton;
@property (nonatomic, weak) IBOutlet UILabel *holdenLbl1;
@property (nonatomic, weak) IBOutlet UILabel *holdenLbl2;
@property (nonatomic, weak) IBOutlet UILabel *holdenLbl3;

@property(nonatomic, weak)IBOutlet UIScrollView *activityScroll;
@property(retain,nonatomic)NSMutableArray *activityArray;
@property (nonatomic, weak) IBOutlet UILabel *activitiesLbl;
@property (nonatomic, weak) IBOutlet UIImageView * activitiesImage;

@end

#define VIEW_ACTIVITY 230
#define VIEW_DIMENSIONS_MY_A 320
#define VIEW_ACTIVITY_6 300
#define VIEW_DIMENSIONS_6 414

@implementation ActivityScroll

-(void)dealloc{
    [self removeFromSuperview];
    self.delegate = nil;
    NSLog(@"dealloc %@",self);
}
/*!
 * @discussion to download image by path and set image to appropriate image view
 * @param coverUrl absolute path to image
 * @param targetView set image here after download is complete
 * @param imageName we use it as a unique key to save image in cache
 */
-(void)downloadImage:(NSString *)coverUrl andIndicator:(UIActivityIndicatorView*)indicator addToImageView:(UIImageView*)targetView andImageName:(NSString*)imageName{
    UIImage *image = [UIImage new];
    NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:coverUrl]];
    image  = [UIImage imageWithData:imageData];
    [indicator stopAnimating];
    if (image == nil) {
        targetView.image = [UIImage imageNamed:@"placeholder"];
    }else{
        targetView.image = image;
        if(image)
            [[[ABStoreManager sharedManager] imageCache] setObject:image forKey:imageName];
    }
}

/*!
 * @discussion  check whether image with path @param path cached or not.
 * If cached. add image to target else returns NO to start download
 * @param target image view to add retrived from cache image
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
    
    imageView.image = [UIImage imageNamed:@"placeholder"];
    
    return NO;
}




- (id)initWithFrame:(CGRect)frame andData:(NSArray *)data andDelegate:(UIViewController *)delegeteVC
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.delegate = (UIViewController<ActivityScrollDelegate>*)delegeteVC;
        
        self.activityArray = [[NSMutableArray alloc] initWithArray:data];
        
        UINib *nib = [UINib nibWithNibName:@"ActivityScroll" bundle:nil];
        
        [self addSubview:[[nib instantiateWithOwner:self options:nil] objectAtIndex:0]];
        
        
        
    }
    return self;
}

-(void)moveInterests{
    
    [self setUpActivity];
    
}
-(void)didMoveToWindow{
    
}


/*!
 *
 * @discussion  Method sets main scroll all incoming data
 *
 */
-(void)setUpScroll{
    
    CGFloat activityScrollIndex =-183;
    
    
    if (![self.activityArray count]) {
        
        self.addNewActivityButton.hidden  = NO;
        self.holdenView.hidden  = NO;
        self.holdenLbl1.hidden  = NO;
        self.holdenLbl2.hidden  = NO;
        self.holdenLbl3.hidden  = NO;
    }
    
    for (int i =0; i!=[self.activityArray count]+2;i++ ) {
        
        if (i == 0 || i == [self.activityArray count]+1) {
            
            activityScrollIndex = activityScrollIndex;
            
            self.activityScroll.contentSize = CGSizeMake(activityScrollIndex+10*i, 0);
            
            UIImageView *activityImage = [[UIImageView alloc] init];
            
            activityImage.frame = CGRectMake(activityScrollIndex, 0,  228,/*6 size, 230 for 5*/ 115);
            
            activityScrollIndex = activityScrollIndex+activityImage.frame.size.width;
            
            activityImage.image = [UIImage imageNamed:@"placeholder"];
            
            [self.activityScroll addSubview:activityImage];
            
        }else{
            
            NSDictionary *data =[self.activityArray objectAtIndex:i-1];
            
            activityScrollIndex = activityScrollIndex;
            
            UIImageView *activityImage = [[UIImageView alloc] init];
            
            activityImage.frame = CGRectMake(activityScrollIndex, 0,  230,/*6 size, 230 for 5*/ 115);
            
            UIButton *detailActivity = [[UIButton alloc] initWithFrame:activityImage.frame];
            detailActivity.tag = i-1;
            [detailActivity addTarget:self action:@selector(opendetailActivity:) forControlEvents:UIControlEventTouchUpInside];
            if(![self imageHandlerInterest:[NSString stringWithFormat:@"%@%@",SERVER_PATH,data[@"activityImg"]] andInterestView:activityImage])
            {
                
                [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,data[@"activityImg"]]
                       andIndicator:nil addToImageView:activityImage andImageName:[NSString stringWithFormat:@"%@%@",SERVER_PATH,data[@"activityImg"]]];
            }
            
            
            activityScrollIndex = activityScrollIndex+activityImage.frame.size.width;
            
            
            if(![self imageHandlerInterest:[NSString stringWithFormat:@"%@%@",SERVER_PATH,data[@"actPrimaryInterestsImg"]] andInterestView:self.activitiesImage])
            {
                
                [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,data[@"actPrimaryInterestsImg"]]
                       andIndicator:nil addToImageView:self.activitiesImage andImageName:[NSString stringWithFormat:@"%@%@",SERVER_PATH,data[@"actPrimaryInterestsImg"]]];
            }
            [self cornerIm:self.activitiesImage];
            [self.activityScroll addSubview:activityImage];
            [self.activityScroll addSubview:detailActivity];
            self.activitiesLbl.text =data[@"activityTitle"];
            
        }
        self.activityScroll.contentSize = CGSizeMake(activityScrollIndex+10*i, 0);
    }
    
}

/*!
 *
 * @discussion  Method sets fraim to scroll
 *
 */


-(void)setUpActivity{
    
    self.frame  =  CGRectMake(320, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    
    [UIView animateWithDuration:.3 animations:^{
        
        self.frame =  CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        
    } completion:^(BOOL finished) {
        
    }];
    
    [self setUpScroll];
}

-(void)setUpActivity:(NSArray *)arr{
    self.activityArray = [[NSMutableArray alloc] initWithArray:arr];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setUpScroll];
    });
}
/*!
 *  @discussion UIScrollView delegate
 */

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int xFinal = self.activityScroll.contentOffset.x;
    int viewIndex = xFinal / VIEW_ACTIVITY;
    if ( viewIndex == [self.activityArray count]) {
        viewIndex = (int)[self.activityArray count] -1 ;
    }
    xFinal = viewIndex * VIEW_ACTIVITY;
    [self.activityScroll setContentOffset:CGPointMake(xFinal, 0) animated:YES];
    [self setNameActivity:viewIndex];
}

/*!
 *  @discussion UIScrollView delegate
 */

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    int xFinal = self.activityScroll.contentOffset.x;
    int viewIndex = xFinal / VIEW_ACTIVITY;//VIEW_ACTIVITY for 4/5;
    xFinal = viewIndex * VIEW_ACTIVITY;
    [self.activityScroll setContentOffset:CGPointMake(xFinal, 0) animated:YES];
    [self setNameActivity:viewIndex];
}


/*!
 *  @discussion Method sets description for each activity
 */

-(void)setNameActivity:(int)index{
    
    if (index < [self.activityArray count]) {
        
        NSDictionary *dic = [self.activityArray objectAtIndex:index];
        
        if (dic[@"actPrimaryInterestsImg"] && ![dic[@"actPrimaryInterestsImg"] isEqualToString:@""]) {
            
            if(![self imageHandlerInterest:[NSString stringWithFormat:@"%@%@",SERVER_PATH,dic[@"actPrimaryInterestsImg"]] andInterestView:self.activitiesImage])
            {
                
                [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,dic[@"actPrimaryInterestsImg"]]
                       andIndicator:nil addToImageView:self.activitiesImage andImageName:[NSString stringWithFormat:@"%@%@",SERVER_PATH,dic[@"actPrimaryInterestsImg"]]];
            }
            
        }
        [self cornerIm:self.activitiesImage];
        self.activitiesLbl.text = dic[@"activityTitle"];
        
    }
}


/*!
 *  @discussion Method moves leftward scroll left at 230 pixels
 */

-(IBAction)scrollLeft{
    if ([self.activityArray count]) {
        int xFinal = self.activityScroll.contentOffset.x  ;
        int viewIndex = xFinal / VIEW_ACTIVITY ;
        viewIndex = viewIndex-1;
        xFinal = viewIndex * VIEW_ACTIVITY;
        if (xFinal> -230) {
            [self.activityScroll setContentOffset:CGPointMake(xFinal, 0) animated:YES];
            if (viewIndex!=-1) {
                [self setNameActivity:viewIndex];
            }
        }
    }
}

/*!
 *  @discussion Method moves rightward scroll left at 230 pixels
 */

-(IBAction)scrollRihgt{
    if ([self.activityArray count]) {
        
        int xFinal = self.activityScroll.contentOffset.x  ;
        int viewIndex = xFinal / VIEW_ACTIVITY ;
        if (viewIndex < [self.activityArray count] - 1 && viewIndex!=-1) {
            viewIndex = viewIndex+1;
            xFinal = viewIndex * VIEW_ACTIVITY;
            [self.activityScroll setContentOffset:CGPointMake(xFinal, 0) animated:YES];
            [self setNameActivity:viewIndex];
        }
    }
}
/*!
 *  @discussion Method sets corner radius to images
 */
-(void)cornerIm:(UIImageView*)imageView{
    imageView .layer.cornerRadius =  imageView.bounds.size.width/2;
    imageView.layer.masksToBounds = YES;
}


#pragma Action

/*!
 *  @discussion Method presents ActivityDetailViewController
 */
-(void)opendetailActivity:(UIButton*)button{
    
    
    if (self.userActivityID!=nil) {
        
        NSDictionary *dic = [self.activityArray objectAtIndex:button.tag];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:[NSNumber numberWithUnsignedInteger:kPIActivityScreen] forKey:@"fromScreen"];
        [prefs setObject:self.userActivityID forKey:@"userActivityID"];
        [prefs synchronize];
        [self.delegate presentViewController:[[ActivityDetailViewController alloc] initWithData:dic] animated:YES completion:^{
            
        }];
        
    }else{
        
        NSDictionary *dic = [self.activityArray objectAtIndex:button.tag];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:[NSNumber numberWithUnsignedInteger:kPIProfileScreen] forKey:@"fromScreen"];
        [prefs synchronize];
        [self.delegate presentViewController:[[ActivityDetailViewController alloc] initWithData:dic] animated:YES completion:^{
            
        }];
        
    }
}
/*!
 *  @discussion Method presents ActivityGeneralViewController
 */

-(IBAction)addActions:(id)sender{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[emsDeviceManager isIphone6plus]?@"ActivityBuilder_6plus":@"ActivityBuilder_4" bundle:nil];
    ActivityGeneralViewController *dreamShot = [storyboard instantiateViewControllerWithIdentifier:@"ActivityGeneralViewController"];
    [self.delegate presentViewController:dreamShot animated:YES completion:^{
        
    }];
    
    
}





@end
