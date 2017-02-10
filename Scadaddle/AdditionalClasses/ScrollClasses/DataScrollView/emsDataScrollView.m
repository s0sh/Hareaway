
//  emsDataScrollView.m
//  Scadaddle
//
//  Created by developer on 12/05/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsDataScrollView.h"
#import "ABStoreManager.h"
#import "YTPlayerViewController.h"
@interface emsDataScrollView ()

@property (nonatomic, weak) IBOutlet UILabel *userName;
@property (nonatomic, weak) IBOutlet UIImageView * activitiesImage;

@property (nonatomic, weak) IBOutlet UILabel *followCount;


@property (nonatomic,retain)NSString *userNameString;
@property (nonatomic,retain) NSString * activitiesImageString;
@property (nonatomic,retain) NSString * followCountString;

@property(nonatomic, weak)IBOutlet UIScrollView *myDataScroll;

@end

#define VIEW_ACTIVITY 230
#define VIEW_DIMENSIONS_MY_A 320
#define VIEW_ACTIVITY_6 300
#define VIEW_DIMENSIONS_6 320

@implementation emsDataScrollView

-(void)dealloc{
    [self removeFromSuperview];
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
        {
            [[[ABStoreManager sharedManager] imageCache] setObject:image forKey:imageName];
        }
    }
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
    
    imageView.image = [UIImage imageNamed:@"placeholder"];
    
    return NO;
}

/*!
 *
 * @discussion  Method  sets  DataScroll frame and incomin data
 *
 */
- (id)initWithFrame:(CGRect)frame andData:(NSArray *)data andName:(NSString *)name andInterestImage:(NSString *)imsgeStr andFollowings:(NSString *)followCount andAge:(NSString *)age
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.userNameString = [NSString stringWithFormat:@"%@, %@", name,age];
        self.followCountString = followCount;
        self.activitiesImageString =imsgeStr;
        
        self.myDataArray = [[NSMutableArray alloc] initWithArray:data];
        UINib *nib = [UINib nibWithNibName:@"emsDataScrollView" bundle:nil];
        [self addSubview:[[nib instantiateWithOwner:self options:nil] objectAtIndex:0]];
        
    }
    return self;
}
-(void)didMoveToWindow{
    
    // [self setUpMyData];
}
/*!
 *
 * @discussion  Method  sets class data
 *
 */
-(void)moveInterests{
    
    [self setUpMyData];
}
/*!
 *
 * @discussion  Method  sets  array of images
 * @param data - array
 */
-(id)initWithData:(NSArray *)data{
    
    
    UINib *nib = [UINib nibWithNibName:@"emsDataScrollView" bundle:nil];
    self = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self setUpMyData:data];
    });
    
    return  self;
}

-(void)setUpMyData:(NSArray *)arr{
    
    self.myDataArray = [[NSMutableArray alloc] initWithArray:arr];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setUpScroll];
    });
    
}
/*!
 * setUpScroll
 * @discussion Method sets all UI elemeents
 */
-(void)setUpMyData{
    
    self.frame  =  CGRectMake(0, self.frame.origin.y - 200, self.frame.size.width, self.frame.size.height);
    
    [UIView animateWithDuration:.3 animations:^{
        
        self.frame =  CGRectMake(0, self.frame.origin.y + 200, self.frame.size.width, self.frame.size.height);
        
    } completion:^(BOOL finished) {
        
    }];
    
    [self setUpScroll];
    
}

/*!
 * setUpScroll
 * @discussion Method sets all UI elemeents
 */

-(void)setUpScroll{
    
    self.userName.text =  self.userNameString;
    
    self.followCount.text = self.followCountString;
    
    if (self.activitiesImageString && ![self.activitiesImageString isEqualToString:@""]) {
        
        if(![self imageHandlerInterest:[NSString stringWithFormat:@"%@%@",SERVER_PATH,self.activitiesImageString] andInterestView:self.activitiesImage])
        {
            
            [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,self.activitiesImageString]
                   andIndicator:nil addToImageView:self.activitiesImage andImageName:[NSString stringWithFormat:@"%@%@",SERVER_PATH,self.activitiesImageString]];
            
        }
    }
    
    
    [self cornerIm:self.activitiesImage];
    
    CGFloat myDataScrollIndex = 1;
    
    for (int i =0; i<[self.myDataArray count];i++ ) {
        
        NSDictionary *data =[self.myDataArray objectAtIndex:i];
        
        myDataScrollIndex = myDataScrollIndex;
        
        self.myDataScroll.contentSize = CGSizeMake((myDataScrollIndex+10*i) +354, 0);
        
        UIImageView *activityImage = [[UIImageView alloc] init];
        
        activityImage.frame = CGRectMake(myDataScrollIndex, 0, 320, 160);
        
        
        UIButton *videoBtn = [[UIButton alloc] initWithFrame:CGRectMake(myDataScrollIndex+144,52, 44, 44)];
        
        videoBtn.center = activityImage.center;
        
        if (data[@"path1242x554"] && ![data[@"path1242x554"] isEqualToString:@""]) {
            
            
            if(![self imageHandlerInterest:[NSString stringWithFormat:@"%@%@",SERVER_PATH,data[@"path1242x554"]] andInterestView:activityImage])
            {
                
                [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,data[@"path1242x554"]]
                       andIndicator:nil addToImageView:activityImage andImageName:[NSString stringWithFormat:@"%@%@",SERVER_PATH,data[@"path1242x554"]]];
            }
        }
        myDataScrollIndex = myDataScrollIndex+activityImage.frame.size.width;
        
        activityImage.layer.cornerRadius = 2;
        activityImage.clipsToBounds = YES;
        
        
        [self.myDataScroll addSubview:activityImage];
        if ([data[@"type"] isEqualToString:@"video"]) {
            
            [videoBtn setBackgroundImage:[UIImage imageNamed:@"play_icon"] forState:UIControlStateNormal];
            videoBtn.tag = i;
            [videoBtn addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
            [self.myDataScroll addSubview:videoBtn];
        }
    }
}

/*!
 *  @discussion UIScrollView delegate
 */

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    int xFinal = self.myDataScroll.contentOffset.x +110 ;
    int viewIndex = xFinal / VIEW_DIMENSIONS_6;//VIEW_DIMENSIONS_MY_A for 4/5 ;
    xFinal = viewIndex *  VIEW_DIMENSIONS_6;//VIEW_DIMENSIONS_MY_A for 4/5 ;
    [self.myDataScroll setContentOffset:CGPointMake(xFinal, 0) animated:YES];
    
}

/*!
 *  @discussion UIScrollView delegate
 */

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    int xFinal = self.myDataScroll.contentOffset.x +110 ;
    int viewIndex = xFinal / VIEW_DIMENSIONS_6;//VIEW_DIMENSIONS_MY_A for 4/5 ;
    xFinal = viewIndex *  VIEW_DIMENSIONS_6;//VIEW_DIMENSIONS_MY_A for 4/5 ;
    [self.myDataScroll setContentOffset:CGPointMake(xFinal, 0) animated:YES];
}

/*!
 *  @discussion Method sets corner radius to images
 */
-(void)cornerIm:(UIImageView*)imageView{
    imageView .layer.cornerRadius =  imageView.bounds.size.width/2;
    imageView.layer.masksToBounds = YES;
}
/*!
 * playVideo
 * @discussion  Method  plays Video
 */

-(IBAction)playVideo:(UIButton*)sender
{
    NSString *test = self.myDataArray[sender.tag][@"link"];
    NSArray *stringComponents = [test componentsSeparatedByString:@"="];
    NSString *res = [stringComponents objectAtIndex:1];
    
    [[NSUserDefaults standardUserDefaults] setValue:res forKey:@"currentYTVideoID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ActivityBuilder_4" bundle:nil];
    YTPlayerViewController *notebook = [storyboard instantiateViewControllerWithIdentifier:@"YTPlayer"];
    [self.delegate presentViewController:notebook animated:YES completion:^{
        
    }];
    
}


@end
