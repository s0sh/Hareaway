//
//  DSCalendarViewController.m
//  DreamShot
//
//  Created by Roman Bigun on 4/27/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "DSCalendarViewController.h"
#import "DSViewController.h"
@interface DSCalendarViewController ()

@end

@implementation DSCalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    calendar = [[VRGCalendarView alloc] init];
    calendar.delegate=self;
    [self.view addSubview:calendar];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)calendarView:(VRGCalendarView *)calendarView switchedToMonth:(int)month targetHeight:(float)targetHeight animated:(BOOL)animated {
    if (month==[[NSDate date] month])
    {
        NSArray *dates = [NSArray arrayWithObjects:[NSNumber numberWithInt:2],[NSNumber numberWithInt:5],[NSNumber numberWithInt:8],[NSNumber numberWithInt:17],[NSNumber numberWithInt:22],[NSNumber numberWithInt:30], nil];
        [calendarView markDates:dates];
    }
}

-(void)calendarView:(VRGCalendarView *)calendarView dateSelected:(NSDate *)date {
    NSLog(@"Selected date = %@",date);
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
