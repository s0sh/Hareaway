//
//  SettingsViewController.h
//  Scadaddle
//
//  Created by Roman Bigun on 6/15/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RangeSlider.h"
#import "DoubleSlider.h"
#define SLIDER_VIEW_TAG     1234
@interface SettingsViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource,UIAlertViewDelegate>
{


    BOOL isNotificationsSelected;
    UILabel *leftLabel;
    UILabel *rightLabel;

    
}
@property(nonatomic,retain)IBOutlet UILabel *reportLabel;
@property(nonatomic,retain)IBOutlet UILabel *showWhoomLbl;
@property(nonatomic,retain)IBOutlet UILabel *radiusLbl;
@property(nonatomic,retain)IBOutlet UIButton *notifBtn;
@property(nonatomic,retain)IBOutlet UIPickerView *picker;
@property(nonatomic,weak)IBOutlet UIView *shtorka;
@property(nonatomic,weak)IBOutlet UIActivityIndicatorView *shtorkaIndicator;
/*!
 * @discussion  When user use slider with his finger this method calls and
 * react accordingly
 * @param slider DoubleSlider object which contains its position as well
 */
- (void)valueChangedForDoubleSlider:(DoubleSlider *)slider;
@end
