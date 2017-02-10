//
//  emsRightMenuCell.h
//  Scadaddle
//
//  Created by developer on 14/04/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface emsRightMenuCell : UITableViewCell


@property (weak,nonatomic)IBOutlet UILabel* natificatorName;
@property (weak,nonatomic)IBOutlet UILabel* natificatorStatus;
@property (weak,nonatomic)IBOutlet UILabel* natificatorTime;
@property (weak,nonatomic)IBOutlet UILabel* messageText;
@property (weak,nonatomic)IBOutlet UIImageView *avatarImage;
@property (weak,nonatomic)IBOutlet UIImageView *interestImage;
@property (weak,nonatomic)IBOutlet UIButton *userButton;
@property (weak,nonatomic)IBOutlet UIImageView *clock;
@end
