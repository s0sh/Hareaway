//
//  emsEditProfileCell.h
//  Scadaddle
//
//  Created by developer on 08/07/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface emsEditProfileCell : UICollectionViewCell

@property (weak,nonatomic)IBOutlet UIImageView *userImage;
@property (weak,nonatomic)IBOutlet UIButton *deleteImageButton;
-(void)configureCellItemsWithData:(NSString *)stringUrl;
@end
