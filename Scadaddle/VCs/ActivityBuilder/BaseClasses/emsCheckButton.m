//
//  emsCheckButton.m
//  ActivityCreator
//
//  Created by Roman Bigun on 5/5/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsCheckButton.h"

@implementation emsCheckButton
@synthesize isChecked,uncheckAllExceptMe;

-(IBAction)changeState:(UIButton*)sender
{

    if(self.isChecked){
        if(sender.tag>=100){
          [self setBackgroundImage:[UIImage imageNamed:@"non_check"] forState:UIControlStateNormal];
        }
        else if(sender.tag>=0 && sender.tag<7){
          [self setBackgroundImage:[UIImage imageNamed:@"non_chek_icon_green_builder"] forState:UIControlStateNormal];
        }
        self.isChecked = NO;
        self.uncheckAllExceptMe = NO;
    }
    else{
        if(sender.tag>=100){
            [self setBackgroundImage:[UIImage imageNamed:@"check_btn"] forState:UIControlStateNormal];
        }
        else if(sender.tag>=0 && sender.tag<7){
            [self setBackgroundImage:[UIImage imageNamed:@"chek_icon_green_builder"] forState:UIControlStateNormal];
        }
        self.isChecked = YES;
        self.uncheckAllExceptMe = YES;
       
    }
    

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
