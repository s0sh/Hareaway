//
//  emsMenuCell.m
//  Scadaddle
//
//  Created by developer on 15/04/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsMenuCell.h"

@implementation emsMenuCell

- (void)awakeFromNib {
  
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
        
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"emsMenuCell" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
        
    }
    return self;
}


@end
