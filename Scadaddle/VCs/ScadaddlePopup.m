//
//  ScadaddlePopup.m
//  Scadaddle
//
//  Created by Roman Bigun on 6/25/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "ScadaddlePopup.h"
#import "serverconstants.h"

@implementation ScadaddlePopup
{

    UILabel *info;
    UIActivityIndicatorView *indicator;
    UIView *infoView;
    UIImageView *infoBGImage;
    UIImageView *scadaddleLogo;
    UIButton *okBtn;
    

}

- (id)initWithFrame:(CGRect)frame withTitle:(NSString*)title withProgress:(BOOL)isProgress andButtonsYesNo:(BOOL)yesNo forTarget:(id)target andMessageType:(int)type
{

   
    self = [super init];
    if(self)
    {
        self.frame = CGRectMake(0, 0, 320, 568);
        self.backgroundColor = [UIColor clearColor];
        UIView *storka = [[UIView alloc] initWithFrame:self.frame];
        storka.backgroundColor = [UIColor blackColor];
        storka.alpha = 0.3f;
        [self addSubview:storka];
        
        
        
        if(type == SCADTipsInterestMessage)
        {
            infoView = [[UIView alloc] initWithFrame:CGRectMake(8,199 ,307 , 280)];
            info = [[UILabel alloc] initWithFrame:CGRectMake(8, 57, 291, 106)];
            okBtn = [[UIButton alloc] initWithFrame:CGRectMake(125, 200, 50, 50)];
            UIButton *addInterest = [[UIButton alloc] initWithFrame:CGRectMake(227, 325, 25, 25)];
            [addInterest setBackgroundImage:[UIImage imageNamed:@"add_icon"] forState:UIControlStateNormal];
            //[addInterest addTarget:target action:@selector(addInterest) forControlEvents:UIControlEventTouchUpInside];
            [addInterest setEnabled:NO];
            [self addSubview:addInterest];
            
        }
        else
        {
            okBtn = [[UIButton alloc] initWithFrame:CGRectMake(125, 150, 50, 50)];
            infoView = [[UIView alloc] initWithFrame:CGRectMake(8,199 ,307 , 230)];
            info = [[UILabel alloc] initWithFrame:CGRectMake(8, 47, 291, 106)];
        }
        
        infoView.backgroundColor = [UIColor clearColor];
        infoBGImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,infoView.frame.size.width,infoView.frame.size.height)];
        [infoBGImage setImage:[UIImage imageNamed:@"pop_up_bg"]];
        [infoView addSubview:infoBGImage];
        
        scadaddleLogo = [[UIImageView alloc] initWithFrame:CGRectMake(81, 5, 144, 43)];
        scadaddleLogo.image = [UIImage imageNamed:@"logo_settings_ios_5"];
        [infoView addSubview:scadaddleLogo];
        
        if(isProgress)
        {
        
            indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(135, 53, 37, 37)];
            indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
            [indicator startAnimating];
            [infoView addSubview:indicator];
        
        }
        
        
        info.text = title;
        [info setNumberOfLines:7];
        info.textColor = [UIColor grayColor];
        info.font = [UIFont fontWithName:@"MyriadPro-Cond" size:title.length>50?18:30];
        info.textAlignment = NSTextAlignmentCenter;
        [infoView addSubview:info];
        
        [okBtn setBackgroundImage:[UIImage imageNamed:@"ok_btn"] forState:UIControlStateNormal];
        if([target respondsToSelector:@selector(dismissPopup)])
        {
           [okBtn addTarget:target action:@selector(dismissPopup) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
           [okBtn addTarget:target action:@selector(dismissPopupAction) forControlEvents:UIControlEventTouchUpInside];
        }
        [infoView addSubview:okBtn];
        [self addSubview:infoView];
        infoView.alpha = 1;
        [self hideDisplayButton:YES];
        if(type == SCADTipsInterestMessage)
        {
           
            UIButton *addInterest = [[UIButton alloc] initWithFrame:CGRectMake(227, 335, 25, 25)];
            [addInterest setBackgroundImage:[UIImage imageNamed:@"add_icon"] forState:UIControlStateNormal];
            //[addInterest addTarget:target action:@selector(addInterest) forControlEvents:UIControlEventTouchUpInside];
            [addInterest setEnabled:NO];
            [self addSubview:addInterest];
            
        }
        
        
    }
    
    return self;
}
//
-(void)hideDisplayButton:(BOOL)hide
{

    if(hide)
    {
        okBtn.alpha=0;
        [indicator startAnimating];
    }
    else
    {
    
        okBtn.alpha=1;
        [indicator stopAnimating];
    
    }

}
-(void)updateTitleWithInfo:(NSString *)title
{

    info.text = title;
    

}
-(void)dismissPopup
{
   [self removeFromSuperview];
}
-(IBAction)dismissPopupAction
{
    [self dismissPopup];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
