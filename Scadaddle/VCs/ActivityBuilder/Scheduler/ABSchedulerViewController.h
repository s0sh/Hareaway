//
//  ABSchedulerViewController.h
//  ActivityCreator
//
//  Created by Roman Bigun on 5/7/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "emsCheckButton.h"
typedef NS_ENUM(NSInteger, SchedulerMode) {
    kModeOnce=100,
    kModeEveryday=101,
    kModeMonthly=102,
    kModeWeekend=103,
    kModeCustom=104,
    kModeUndefined
};
typedef NS_ENUM(NSInteger, SchedulerModeCustomDays) {
    kModeSU=0,
    kModeMN,
    kModeTU,
    kModeWE,
    kModeTH,
    kModeFR,
    kModeSA
};

@interface ABSchedulerViewController : UIViewController
@property (nonatomic, assign) SchedulerMode mode;
@property(weak,nonatomic)IBOutlet UIDatePicker *timePicker;
@property(weak,nonatomic)IBOutlet UIPickerView *dayOfMonthPicker;
@property(weak,nonatomic)IBOutlet UIDatePicker *datePicker;
@property(weak,nonatomic)IBOutlet UIButton *backBtn;
@property(weak,nonatomic)IBOutlet UIView *customDaysPlaceholder;
@property(weak,nonatomic)IBOutlet UIView *hidingDatePickerView;
@property(weak,nonatomic)IBOutlet emsCheckButton *onceBtn;
@property(weak,nonatomic)IBOutlet emsCheckButton *everydayBtn;
@property(weak,nonatomic)IBOutlet emsCheckButton *weekdaysBtn;
@property(weak,nonatomic)IBOutlet emsCheckButton *weekendBtn;
@property(weak,nonatomic)IBOutlet emsCheckButton *customBtn;
@property(strong,nonatomic)NSDictionary *data;
@end
