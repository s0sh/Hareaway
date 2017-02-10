//
//  DSCalendarViewController.h
//  DreamShot
//
//  Created by Roman Bigun on 4/27/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VRGCalendarView.h"

@interface DSCalendarViewController : UIViewController<VRGCalendarViewDelegate>
{VRGCalendarView *calendar;}
@end
