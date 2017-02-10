//
//  emsTagsScroll.m
//  Scadaddle
//
//  Created by developer on 12/05/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsTagsScroll.h"
#import "UILabel+UILabel_CustomLable.h"
#import "ABStoreManager.h"

@interface emsTagsScroll ()

@property(nonatomic, weak)IBOutlet UIScrollView *tegsScroll;
@property(retain,nonatomic)NSArray *tagsArray;
@property(retain,nonatomic)NSMutableArray *activityArray;
@end

@implementation emsTagsScroll

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
        
        if(image){
                [[[ABStoreManager sharedManager] imageCache] setObject:image forKey:imageName];
        }
        
    }
   // [indicator stopAnimating];
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

- (id)initWithFrame:(CGRect)frame andData:(NSArray *)data
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.activityArray = [[NSMutableArray alloc] initWithArray:data];
        
        UINib *nib = [UINib nibWithNibName:@"emsTagsScroll" bundle:nil];
        
        self = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
        
        [self setUpMyData];
    }
    return self;
}
/*!
 *
 * @discussion  Method  sets class data
 *
 */
-(void)setUpMyData{
    
    [self setUpScroll];
    
}

-(void)dealloc{
    [self removeFromSuperview];
    NSLog(@"dealloc %@",self);
}

-(id)initWithData:(NSArray *)data{
    
    
    UINib *nib = [UINib nibWithNibName:@"emsTagsScroll" bundle:nil];
    
    self = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
    
           [self setUpScroll];

    
    return  self;
}

-(void)awakeFromNib{
    
    
    UINib *nib = [UINib nibWithNibName:@"emsTagsScroll" bundle:nil];
    
    [self addSubview:[[nib instantiateWithOwner:self options:nil] objectAtIndex:0]];
    
   
       [self setUpScroll];
   
}

-(void)setUpTag{

    
}

-(void)setUpTag:(NSArray *)arr{
    
    
      //  [self setUpScroll];
   
}

/*!
 * setUpScroll
 * @discussion Method sets all UI elemeents
 */
-(void)setUpScroll{
    
    CGFloat x=0;
    
    for (int i =0; i<[self.activityArray count];i++ ) {
         NSDictionary *data =[self.activityArray objectAtIndex:i];
        x = x+47;
        
        self.tegsScroll.contentSize = CGSizeMake(x+10*i, 0);
        
            UIImageView *interestView= [[UIImageView alloc] init];
            UIImageView *interestCercle= [[UIImageView alloc] init];
            interestView.frame = CGRectMake(x, 0, 34, 34);
            interestCercle.frame = CGRectMake(x, 0, 34, 34);
            interestCercle.image =[UIImage imageNamed:@"circle_interests"];
        
        
        if(![self imageHandlerInterest:[NSString stringWithFormat:@"%@%@",SERVER_PATH,data[@"path1242x554"]] andInterestView:interestView])
        {
            
            [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,data[@"path1242x554"]]
                   andIndicator:nil addToImageView:interestView andImageName:[NSString stringWithFormat:@"%@%@",SERVER_PATH,data[@"path1242x554"]]];
        }
        


        
            interestView.backgroundColor = [UIColor whiteColor];
            interestView.image = [UIImage imageNamed:@"placeholder"];
        [self.tegsScroll addSubview:interestView];
        [self.tegsScroll addSubview:interestCercle];
        
        
    }
}



@end
