//
//  emsActivityCell.m
//  Scadaddle
//
//  Created by developer on 23/05/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsActivityCell.h"

@implementation emsActivityCell

- (void)awakeFromNib {
    self.alfaImage.layer.cornerRadius = 4;
    self.alfaImage.layer.masksToBounds = YES;
    self.interestImage.layer.cornerRadius = self.interestImage.frame.size.height/2;
    self.interestImage.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

   
}



























@end
