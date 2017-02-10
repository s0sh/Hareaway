//
//  emsActivityCell.h
//  Scadaddle
//
//  Created by developer on 23/05/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface emsActivityCell : UITableViewCell

@property (weak,nonatomic)IBOutlet UIImageView *alfaImage;
@property (weak,nonatomic)IBOutlet UIImageView *activityImage;
@property (weak,nonatomic)IBOutlet UIImageView *interestImage;
@property (weak,nonatomic)IBOutlet UIImageView *gradientCircle;
@property (weak,nonatomic)IBOutlet UILabel *activityTitle;
@property (weak,nonatomic)IBOutlet UILabel *activityDateLbl;
@property (weak,nonatomic)IBOutlet UILabel *activityDescription;
@property (weak,nonatomic)IBOutlet UILabel *activityDistance;
@property (weak,nonatomic)IBOutlet UIButton *infoBtn;
@property (weak,nonatomic)IBOutlet UIButton *deleteBtn;
@property (weak,nonatomic)IBOutlet UIButton *editBtn;
@end
