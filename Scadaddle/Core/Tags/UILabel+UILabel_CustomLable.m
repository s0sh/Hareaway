//
//  UILabel+UILabel_CustomLable.m
//  ChatApplication
//
//  Created by developer on 25/06/14.
//  Copyright (c) 2014 developer. All rights reserved.
//

#import "UILabel+UILabel_CustomLable.h"

@implementation UILabel (UILabel_CustomLable)



- (void)setStyleLabel{
    
    self.font = [UIFont fontWithName:@"Roboto-Thin" size:18 ];
    self.backgroundColor = [UIColor clearColor];
    self.textAlignment = NSTextAlignmentCenter;
    self.textColor = [UIColor colorWithRed:95/255.f green:129/255.f blue:139/255.f alpha:1];
    
}

- (void)setStyleLabelCell{
    
    NSString *txt1=self.text;
    CGSize stringsize1 = [txt1 sizeWithFont:[UIFont systemFontOfSize:14]];
    [self setFrame:CGRectMake(self.frame.origin.x,self.frame.origin.y,stringsize1.width+20,self.frame.size.height)];
    
    [self setText:txt1];
    
    self.font = [UIFont fontWithName:@"Roboto-Thin" size:14];
    
    self.backgroundColor = [UIColor clearColor];
    self.textColor = [UIColor blackColor];
    self.adjustsFontSizeToFitWidth = YES;
    self.textAlignment = NSTextAlignmentLeft;
    self.textColor = [UIColor blackColor];
    
}


- (void)setStyleLabelNameCell{
    
    NSString *txt1=self.text;
    CGSize stringsize1 = [txt1 sizeWithFont:[UIFont systemFontOfSize:14]];
    [self setFrame:CGRectMake(self.frame.origin.x,self.frame.origin.y,stringsize1.width+20,self.frame.size.height)];
    
    [self setText:txt1];
    
    self.font = [UIFont fontWithName:@"Roboto-Thin" size:17];
    
    
    self.textColor = [UIColor blackColor];
    self.backgroundColor = [UIColor clearColor];
    self.textColor = [UIColor blackColor];
    self.adjustsFontSizeToFitWidth = YES;
    self.textAlignment = NSTextAlignmentLeft;
    self.textColor = [UIColor blackColor];
    
}


- (void)setStyleLabelForChatMassege{

    
    self.font = [UIFont fontWithName:@"Roboto-Thin" size:10];
   
    
   
    //self.backgroundColor = [UIColor clearColor];
   // self.adjustsFontSizeToFitWidth = YES;
    self.textAlignment = NSTextAlignmentLeft;
    self.textColor = [UIColor blackColor];
    
}

- (void)setStyleLabelForDate{
    
 
    self.font = [UIFont fontWithName:@"Roboto-Thin" size: 9];
    
    
    self.textColor = [UIColor blackColor];
    self.backgroundColor = [UIColor clearColor];
    self.textColor = [UIColor colorWithRed:95/255.f green:129/255.f blue:139/255.f alpha:0.7];
    self.adjustsFontSizeToFitWidth = YES;
    self.textAlignment = NSTextAlignmentLeft;
    self.textColor = [UIColor blackColor];
    
}



- (void)setStyleStatusLabel{
    
  //  self.text = @"Name of User";
    
    [[self layer] setBorderWidth:0.5f];
    [[self layer] setBorderColor:[UIColor colorWithRed:95/255.f green:129/255.f blue:139/255.f alpha:0.5f].CGColor];
    [[self layer] setCornerRadius:10.0f];
    
    self.font = [UIFont fontWithName:@"Roboto-Thin" size:14];
    
    self.backgroundColor = [UIColor whiteColor];
    
   // self.adjustsFontSizeToFitWidth = YES;
    self.textAlignment = NSTextAlignmentCenter;
    self.textColor = [UIColor colorWithRed:95/255.f green:129/255.f blue:139/255.f alpha:1];
    
    
}

- (void)setStyleLabelWhisBorder{
   
    
    NSString *txt1=self.text;
    CGSize stringsize1 = [txt1 sizeWithFont:[UIFont systemFontOfSize:14]];
    [self setFrame:CGRectMake(self.frame.origin.x,self.frame.origin.y,stringsize1.width+20,self.frame.size.height)];
    
    [self setText:[NSString stringWithFormat:@"#%@",txt1]];
   
    [[self layer] setCornerRadius:4.0f];
    self.font = [UIFont fontWithName:@"MyriadPro-Regular" size:12];
    self.textColor = [UIColor whiteColor];
    self.adjustsFontSizeToFitWidth = YES;
    self.textAlignment = NSTextAlignmentCenter;
    self.backgroundColor = [UIColor colorWithRed:40/255.f green:103/255.f blue:183/255.f alpha:1];
      self.layer.masksToBounds = YES;
}


- (void)setStyleLabelWhisBorderIpad{
    
    
    NSString *txt1=self.text;
    CGSize stringsize1 = [txt1 sizeWithFont:[UIFont systemFontOfSize:14]];
    [self setFrame:CGRectMake(self.frame.origin.x,self.frame.origin.y,stringsize1.width+20,self.frame.size.height)];
    
    [self setText:txt1];
    
    [[self layer] setBorderWidth:0.5f];
    [[self layer] setBorderColor:[UIColor colorWithRed:150/255.f green:232/255.f blue:231/255.f alpha:1].CGColor];
    [[self layer] setCornerRadius:10.0f];
    self.font = [UIFont fontWithName:@"Roboto-Thin" size:42];
    self.adjustsFontSizeToFitWidth = YES;
    self.textAlignment = NSTextAlignmentCenter;
    
    
}




- (void)adjustHeight {
    
    if (self.text == nil) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, 0);
        return;
    }
    
    CGSize aSize = self.bounds.size;
    CGSize tmpSize = CGRectInfinite.size;
    tmpSize.width = aSize.width;
    
    tmpSize = [self.text sizeWithFont:self.font constrainedToSize:tmpSize];
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, aSize.width+500, tmpSize.height+500);
}



@end
