//
//  emsInterestsView.m
//  Scadaddle
//
//  Created by developer on 06/04/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsInterestsView.h"
#import "User.h"
#import "ABStoreManager.h"
#import "emsProfileVC.h"
@implementation emsInterestsView


- (void)dealloc
{
    if ([self.superview.subviews containsObject:self]) {
        [self removeFromSuperview];
    }
     resultBlock = nil;
     userBlock = nil;
     cellBackBlock = nil;
     currentUser = nil;
     interestImage = nil;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.frame =CGRectMake(0,0, 230, 65);
    }
    return self;
}


/*!
 *  @discussion  Method sets view  this users
 *  @param :user as User should be passed
 *  @see :MainScreenVC
 */

- (id)initWithWord:(NSString *)initWord andUser:(User *)user andImage:(UIImage*)image andUrl:(NSString *)url  result:(void (^)(BOOL bl))blo cellBlock:(void (^)(BOOL bl))cellBlock userBlock:(void (^)(User *))userBlo {
    //- for mainscreen
        self = [super init];
    if (self) {
        resultBlock = [blo copy];
        cellBackBlock =[cellBlock copy];
        userBlock = [userBlo copy];
        currentUser =user ;
        interestImage = [[UIImageView alloc] init];
        
        interestURL = [[NSString alloc] init];
        
        interestURL = url;

        
        if ([initWord isEqualToString:@"Profile"]) {//кастыль(временый)
            [self initSubviewsProfile];
        }else{
            [self initSubviewsMail];
        }

    }
    return self;



}


/*!
 *  @discussion  Method sets view  this users
 *  @param :user as User should be passed
 *  @see :ProfileVC
 */

-(id)initWithWord:(NSString *)initWord result:(void (^)(BOOL))blo cellBlock:(void (^)(BOOL))cellBlock{

    return nil;

}
/*!
 *  @discussion  Method sets view  this users
 *  @param :user as User should be passed
 *  @see :ProfileVC
 */


- (id)initWithWord:(NSString *)initWord result:(void (^)(BOOL bl))blo 
{
    self = [super init];
    if (self) {
        resultBlock = [blo copy];


    }
    return self;
}


/*!
 *
 * @discussion Method sets all UI elemeents
 */
- (void)initSubviewsMail{
    
    UIImageView *h_line  = [[UIImageView alloc] initWithFrame:CGRectMake(12,-8, 5, 70)];
    h_line.image = [UIImage imageNamed:@"grey_line_h"];
    [self addSubview:h_line];
    
    UIImageView *h_line_r  = [[UIImageView alloc] initWithFrame:CGRectMake(214,-8, 5, 70)];
    h_line_r.image = [UIImage imageNamed:@"grey_line_h"];
    [self addSubview:h_line_r];
    
    
    UIImageView *bg  = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 232, 67)];
    bg.image = [UIImage imageNamed:@"connect_bg"];
    [self addSubview:bg];

    UIImageView *sercle = [[UIImageView alloc] initWithFrame:CGRectMake(40, -2, 70, 70)];
    sercle.image = [UIImage imageNamed:@"photo_circle"];
    [self addSubview:sercle];
    
    avatarImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 62, 62)];
    avatarImage.center = sercle.center;
  
    
    [self configureCellItemsWithData];
    [self cornerIm:avatarImage];
    [self addSubview:avatarImage];
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(122,10,100, 20)];
    nameLabel.text = currentUser.name;
    nameLabel.font = [UIFont fontWithName:@"MyriadPro-Cond" size:14];
    nameLabel.textColor = [UIColor blackColor];
    [self addSubview:nameLabel];
    
    inrerestsLabelLabel = [[UILabel alloc] initWithFrame:CGRectMake(122,24, 90, 34)];
    inrerestsLabelLabel.numberOfLines = 3;
    inrerestsLabelLabel.text =  currentUser.activities;
    inrerestsLabelLabel.font = [UIFont fontWithName:@"MyriadPro-Cond" size:12];
    inrerestsLabelLabel.textColor = [UIColor blackColor];
    [self addSubview:inrerestsLabelLabel];

    
    UIButton*  nextBtn = [[UIButton alloc] initWithFrame: CGRectMake(-32, 4,84, 84)];
    nextBtn.tag =876;
    [nextBtn addTarget:self action:@selector(nextR) forControlEvents:UIControlEventTouchUpInside];
    [nextBtn setImage:[UIImage imageNamed:@"arrow_left_main"] forState:UIControlStateNormal];
   
    [self addSubview:nextBtn];

    
    UIButton*  nextBtnR = [[UIButton alloc] initWithFrame: CGRectMake(180, 4,84, 84)];
    nextBtnR.tag =1234;
    [nextBtnR setImage:[UIImage imageNamed:@"arrow_right_main"] forState:UIControlStateNormal];
    [nextBtnR addTarget:self action:@selector(nextAction) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:nextBtnR];
    
    cellBtnImage = [[UIImageView alloc] initWithFrame: CGRectMake(-4, -4, 40, 40)];
    cellBtnImage.backgroundColor = [UIColor whiteColor];
  
    [self configureInterestView ];
    [self cornerIm:cellBtnImage];
    [self addSubview:cellBtnImage];
    
    
    UIImageView *cellBtnImageCercle = [[UIImageView alloc] initWithFrame: CGRectMake(-4, -4, 40, 40)];
    cellBtnImageCercle.image = [UIImage imageNamed:@"circle_interests"];
    
    [self addSubview:cellBtnImageCercle];
    
    UIButton *cellBtn = [[UIButton alloc] initWithFrame: CGRectMake(-4, -4, 40, 40)];
    [cellBtn setImage:interestImage.image forState:UIControlStateNormal];
    [cellBtn addTarget:self action:@selector(cellAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cellBtn];

    
    UIButton* goToprofile = [[UIButton alloc] initWithFrame: CGRectMake(51, 5,50, 50)];
    [goToprofile addTarget:self action:@selector(goToProfileAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:goToprofile];

}
/*!
 *
 * @discussion Method sets all UI elemeents
*  @see :ProfileVC
 */

- (void)initSubviewsProfile{
    
    UIImageView *h_line  = [[UIImageView alloc] initWithFrame:CGRectMake(105,-10, 5, 40)];
    h_line.image = [UIImage imageNamed:@"grey_line_h"];
    [self addSubview:h_line];
    
    
    UIImageView *bg  = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 232, 67)];
    bg.image = [UIImage imageNamed:@"connect_bg"];
    [self addSubview:bg];
    
    UIImageView *sercle = [[UIImageView alloc] initWithFrame:CGRectMake(41, -3, 72, 72)];
    sercle.image = [UIImage imageNamed:@"photo_circle"];
    [self addSubview:sercle];
    
    avatarImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 62, 62)];
    avatarImage.center = sercle.center;
    
    
    [self configureCellItemsWithData];
    [self cornerIm:avatarImage];
    [self addSubview:avatarImage];
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(122,10, 100, 14)];
    nameLabel.text = currentUser.name;
    nameLabel.font = [UIFont fontWithName:@"MyriadPro-Cond" size:14];
    nameLabel.textColor = [UIColor blackColor];
    [self addSubview:nameLabel];
    
    inrerestsLabelLabel = [[UILabel alloc] initWithFrame:CGRectMake(122,24, 90, 34)];
    inrerestsLabelLabel.numberOfLines = 3;
    inrerestsLabelLabel.text =  currentUser.activities;
    inrerestsLabelLabel.font = [UIFont fontWithName:@"MyriadPro-Cond" size:12];
    inrerestsLabelLabel.textColor = [UIColor blackColor];
    [self addSubview:inrerestsLabelLabel];
    
    
    UIButton* nextBtnLeft = [[UIButton alloc] initWithFrame: CGRectMake(-32, -8,84, 84)];
    nextBtnLeft.tag =876;
    [nextBtnLeft addTarget:self action:@selector(nextR) forControlEvents:UIControlEventTouchUpInside];
    [nextBtnLeft setImage:[UIImage imageNamed:@"arrow_left_main"] forState:UIControlStateNormal];
    [self addSubview:nextBtnLeft];
    
    
    UIButton* nextBtnR = [[UIButton alloc] initWithFrame: CGRectMake(180, -8,84, 84)];
    nextBtnR.tag =1234;
    [nextBtnR setImage:[UIImage imageNamed:@"arrow_right_main"] forState:UIControlStateNormal];
    [nextBtnR addTarget:self action:@selector(nextAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nextBtnR];
    
    
    UIButton* goToprofile = [[UIButton alloc] initWithFrame: CGRectMake(51, 5,50, 50)];
    [goToprofile addTarget:self action:@selector(goToProfileAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:goToprofile];
    
}
/*!
 *
 *  @discussion Method presents emsProfileVC this current user
 */
-(void)goToProfileAction{

    userBlock(currentUser);
}
/*!
 *  @discussion  Method leafs view this users to the left
 */
- (void)nextAction{
   
    resultBlock(NO);
}
/*!
 *  @discussion  Method leafs view this users to the right
 */
- (void)nextR{
    
    resultBlock(YES);
}
/*!
 *  @discussion  Method hides view from superview
 */
- (void)cellAction{
    
    cellBackBlock(YES);
}
/*!
 *  @discussion Method sets corner radius to images
 */
-(void)cornerIm:(UIImageView*)imageView{
    imageView .layer.cornerRadius = imageView.frame.size.height/2;
    imageView.layer.masksToBounds = YES;
}
/*!
 *  @discussion Method downloads Image from server
 */
-(void)configureInterestView
{
    
    
    
    if(![self imageHandlerInterest:[NSString stringWithFormat:@"%@%@",SERVER_PATH,interestURL]])
    {
        
        [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,interestURL]
               andIndicator:nil addToImageView:cellBtnImage andImageName:[NSString stringWithFormat:@"%@%@",SERVER_PATH,interestURL]];
    }

}

/*!
 *  @discussion Method downloads Image from server
 */

-(void)configureCellItemsWithData
{


        if(![self imageHandler:[NSString stringWithFormat:@"%@%@",SERVER_PATH,currentUser.image]])
        {
           
            [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,currentUser.image]
                   andIndicator:nil addToImageView:avatarImage andImageName:[NSString stringWithFormat:@"%@%@",SERVER_PATH,currentUser.image]];
        }
 

}

/*!
 * @discussion  check whether image with path @param path cached or not.
 * If cached. add image to target else returns NO to start download
 * @param imageView image view to add retrived from cache image
 * @param path path to image
 */
-(BOOL)imageHandlerInterest:(NSString*)path
{
    
    
    UIImage *image = [[[ABStoreManager sharedManager] imageCache] objectForKey:path];
    if(image)
    {
        cellBtnImage.image = image;
        
        return YES;
    }
    
    cellBtnImage.image = [UIImage imageNamed:@"placeholder"];
    
    return NO;
}
/*!
 * @discussion  check whether image with path @param path cached or not.
 * If cached. add image to target else returns NO to start download
 * @param path path to image
 */
-(BOOL)imageHandler:(NSString*)path
{
    
    
    UIImage *image = [[[ABStoreManager sharedManager] imageCache] objectForKey:path];
    if(image)
    {
        avatarImage.image = image;
        
        return YES;
    }
    
    avatarImage.image = [UIImage imageNamed:@"placeholder"];
    
    return NO;
}
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


@end
