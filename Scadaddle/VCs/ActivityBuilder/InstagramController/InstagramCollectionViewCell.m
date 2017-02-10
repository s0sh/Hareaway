//
//  FBAlbumCollectionViewCell.m
//  Scadaddle
//
//  Created by Roman Bigun on 6/20/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "FBAlbumCollectionViewCell.h"

@implementation FBAlbumCollectionViewCell

- (void)awakeFromNib {
    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
        
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"FBAlbumCollectionViewCell" owner:self options:nil];
        
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
