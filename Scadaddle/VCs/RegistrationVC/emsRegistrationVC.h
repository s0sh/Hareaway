//
//  emsRegistrationVC.h
//  Scadaddle
//
//  Created by developer on 30/03/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "emsAPIHelper.h"
//#import "Flurry.h"
@interface emsRegistrationVC : UIViewController<UIPickerViewDataSource,UIAlertViewDelegate,UIPickerViewDelegate,UITextFieldDelegate,UITextViewDelegate,UIPickerViewDataSource>
@property(nonatomic,weak)IBOutlet UIView *cropperBackground;
@property(nonatomic,weak)IBOutlet UIView *cropperTop;
@property(nonatomic,weak)IBOutlet UIView *dofPickerBGView;
@property(nonatomic,weak)IBOutlet UIView *buttonsBgView;
@property(nonatomic,weak)IBOutlet UIView *cropperBottom;
@property(nonatomic,weak)IBOutlet UIButton *cropperDone;
@property(nonatomic,weak)IBOutlet UIButton *cropperCancel;
@property(nonatomic,weak)IBOutlet UIImageView *scadLabel;
@property(nonatomic,weak)IBOutlet UILabel *captionLabel;
@property(nonatomic,weak)IBOutlet UILabel *counterLabel;
@property(nonatomic,weak)IBOutlet UIImageView *cropperPhotoFrame;
@property(nonatomic,weak)IBOutlet UIDatePicker *dofPicker;

@end
