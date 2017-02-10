//
//  emsInterestsView.m
//  Scadaddle
//
//  Created by developer on 06/04/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsInterestsView.h"

@implementation emsInterestsView

#define selfRect CGRectMake(0, 0, 320, isIphone5?470:370)
#define wordLabelRect CGRectMake(0, isIphone5?30:-22, 320, 78)

#define imgIconRect CGRectMake(140, isIphone5?83:32, 24, 24)

#define textFuildFrame CGRectMake(20, isIphone5?120:60, 280, 30)

#define btnNextRect CGRectMake(20, isIphone5?176:96, 130, 44)
#define btnCheckRect CGRectMake(170, isIphone5?176:96, 130, 44)



//- (void)dealloc
////{
////    [mainTF release];
////    [checkBtn release];
////    [wordLabel release];
////    
////    Block_release(resultBlock);
////    resultBlock = nil;
////    
////    Block_release(showWord);
////    showWord = nil;
////    
////    Block_release(localSpeach);
////    localSpeach = nil;
////    
////    localWord = nil;
//    [super dealloc];
//}

- (void)dealloc
{
    if ([self.superview.subviews containsObject:self]) {
        [self removeFromSuperview];
    }

     resultBlock = nil;
     cellBackBlock = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.frame =CGRectMake(0,0, 230, 65);
    }
    return self;
}




-(id)initWithWord:(NSString *)initWord result:(void (^)(BOOL))blo cellBlock:(void (^)(BOOL))cellBlock{

//- for mainscreen
    
    self = [super init];
    if (self) {
        resultBlock = [blo copy];
        cellBackBlock =[cellBlock copy];
        [self initSubviews];
    }
    return self;

}

- (id)initWithWord:(NSString *)initWord result:(void (^)(BOOL bl))blo 
{
    self = [super init];
    if (self) {
        resultBlock = [blo copy];

        [self initSubviews];
    }
    return self;
}

- (void)initSubviews{
    
    UIImageView *h_line  = [[UIImageView alloc] initWithFrame:CGRectMake(102,-10, 5, 110)];
    h_line.image = [UIImage imageNamed:@"grey_line_h"];
    //[self addSubview:h_line];
    
    
    UIImageView *bg  = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 232, 67)];
    bg.image = [UIImage imageNamed:@"connect_bg"];
    [self addSubview:bg];
   
    UIImageView *sercle = [[UIImageView alloc] initWithFrame:CGRectMake(40, -2, 70, 70)];
    sercle.image = [UIImage imageNamed:@"photo_circle"];
    [self addSubview:sercle];
    
    avatarImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 62, 62)];
    avatarImage.center = sercle.center;
    avatarImage.backgroundColor =[UIColor blackColor];
    avatarImage.image = [UIImage imageNamed:@"photo_2_profile"];
    [self cornerIm:avatarImage];
    [self addSubview:avatarImage];
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(122,10, 75, 14)];
    nameLabel.text = @"PAUL JONES";
    nameLabel.font = [UIFont fontWithName:@"MyriadPro-Cond" size:14];
    nameLabel.textColor = [UIColor blackColor];
    [self addSubview:nameLabel];
    
    inrerestsLabelLabel = [[UILabel alloc] initWithFrame:CGRectMake(122,32, 90, 34)];
    inrerestsLabelLabel.numberOfLines = 3;
    inrerestsLabelLabel.text = @"Cycling Motorcycling,Rink";
    inrerestsLabelLabel.font = [UIFont fontWithName:@"MyriadPro-Cond" size:12];
    inrerestsLabelLabel.textColor = [UIColor blackColor];
    [self addSubview:inrerestsLabelLabel];

    
    UIButton *nextBtn = [[UIButton alloc] initWithFrame: CGRectMake(0, 25, 18, 18)];
    [nextBtn addTarget:self action:@selector(nextR) forControlEvents:UIControlEventTouchUpInside];
    [nextBtn setImage:[UIImage imageNamed:@"arrow_left_main"] forState:UIControlStateNormal];
    [self addSubview:nextBtn];

    
    UIButton *nextBtnR = [[UIButton alloc] initWithFrame: CGRectMake(213, 25, 18, 18)];
    [nextBtnR setImage:[UIImage imageNamed:@"arrow_right_main"] forState:UIControlStateNormal];
    [nextBtnR addTarget:self action:@selector(nextAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nextBtnR];
    
    
    
    UIButton *cellBtn = [[UIButton alloc] initWithFrame: CGRectMake(0, -2, 30, 30)];
    [cellBtn setImage:[UIImage imageNamed:@"cicling_icon_main"] forState:UIControlStateNormal];
    [cellBtn addTarget:self action:@selector(cellAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cellBtn];



}

- (void)nextAction{
   
    resultBlock(NO);
}


- (void)nextR{
    
    resultBlock(YES);
}


- (void)cellAction{
    
    cellBackBlock(YES);
}



-(void)cornerIm:(UIImageView*)imageView{
    imageView .layer.cornerRadius = imageView.frame.size.height/2;
    imageView.layer.masksToBounds = YES;
}

@end
