//
//  FBAlbumCollectionViewCell.m
//  Scadaddle
//
//  Created by Roman Bigun on 6/20/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "YoutubeAlbumCollectionViewCell.h"
#import "ABStoreManager.h"
@implementation YoutubeAlbumCollectionViewCell

@synthesize isChecked,itemId,itemLink,itemPath,itemTitle,item;
- (void)awakeFromNib {
    self.itemId = [[NSString alloc] init];
    self.item = [NSDictionary new];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
        
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"YoutubeAlbumCollectionViewCell" owner:self options:nil];
        
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
-(IBAction)check
{
    
    if(isChecked){
        isChecked = NO;
        [self.checkBtn setBackgroundImage:[UIImage imageNamed:@"non_check"] forState:UIControlStateNormal];
        [[ABStoreManager sharedManager] removeSocialByPath:itemPath];
                
    }else{
        isChecked = YES;
        [self.checkBtn setBackgroundImage:[UIImage imageNamed:@"check_btn"] forState:UIControlStateNormal];
        [[ABStoreManager sharedManager] addSocialImagePath:itemPath];
        [[ABStoreManager sharedManager] addYoutubeToActivity:item];
        
    }
    
    
}

@end
