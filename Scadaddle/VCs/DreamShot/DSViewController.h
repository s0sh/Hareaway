//
//  DSViewController.h
//  DreamShot
//
//  Created by Roman Bigun on 4/27/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *likeImage;
@property (weak, nonatomic) IBOutlet UILabel *likesCount;
@property (weak, nonatomic) IBOutlet UILabel *dateLbl;
@property (weak, nonatomic) IBOutlet UILabel *dsQuestion;
@property (weak, nonatomic) IBOutlet UILabel *dsDescriptionLbl;
@property (weak, nonatomic) IBOutlet UILabel *a1;
@property (weak, nonatomic) IBOutlet UILabel *a2;
@property (weak, nonatomic) IBOutlet UILabel *a3;
@property (weak, nonatomic) IBOutlet UILabel *dsTitle;
@property (weak, nonatomic) IBOutlet UIImageView *dsMainImage;
@property (weak, nonatomic) IBOutlet UIButton *a1Btn;
@property (weak, nonatomic) IBOutlet UIButton *a2Btn;
@property (weak, nonatomic) IBOutlet UIButton *a3Btn;
@property (weak, nonatomic) IBOutlet UIButton *voteBtn;
@property (retain, nonatomic) NSDictionary *dsData;
@property int selectedIndex;

@end
