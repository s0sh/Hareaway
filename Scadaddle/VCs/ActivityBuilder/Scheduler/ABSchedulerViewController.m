//
//  ABSchedulerViewController.m
//  ActivityCreator
//
//  Created by Roman Bigun on 5/7/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "ABSchedulerViewController.h"
#import "ABStoreManager.h"
#import "ScheduledViewController.h"
#import "ScadaddlePopup.h"
@interface ABSchedulerViewController ()
@end
@implementation ABSchedulerViewController
{

    NSMutableArray *daysArray;
    SchedulerModeCustomDays customDayTag;
    ScadaddlePopup *popup;
}

NSString * const vSU = @"SU";
NSString * const vMO = @"MO";
NSString * const vTU = @"TU";
NSString * const vWE = @"WE";
NSString * const vTH = @"TH";
NSString * const vFR = @"FR";
NSString * const vSA = @"SA";

#define DAYS_ARRAY [NSArray arrayWithObjects:vSU,vMO,vTU,vWE,vTH,vFR,vSA,nil]

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.customDaysPlaceholder.alpha=0;
    self.hidingDatePickerView.alpha=0;
    self.mode = kModeOnce;
    [self.dayOfMonthPicker selectRow:0 inComponent:0 animated:YES];
    
    [[ABStoreManager sharedManager] addDateToScheduler:[NSString stringWithFormat:@"%i",1] forKey:@"dayOfMonth"];
    NSLog(@"Current scheduler %@",_data);
    if(_data.count>0){
        [self configureSchedulerAccordingToData];
        _backBtn.alpha=0;
    }else{
        [self.datePicker setMinimumDate: [NSDate date]];
        [self selectOnce];
    }
}
/*!
* @discussion View configuration according to type
* @types can be monthly/custom/everyday/once
* @see 'SchedulerMode' ENUM
*/
-(void)configureSchedulerAccordingToData
{
    int type =[[NSString stringWithFormat:@"%@",[_data objectForKey:vSchedulerType]] intValue];
    NSString *time = [NSString stringWithFormat:@"%@",[_data objectForKey:vScheduledTime]];
    self.mode = type;
    [self.datePicker setDate:[NSDate dateWithTimeIntervalSince1970:[time doubleValue]]];
    [self.timePicker setDate:[NSDate dateWithTimeIntervalSince1970:[time doubleValue]]];
    
    if(self.mode !=  kModeCustom)
    {
       if(self.mode == kModeOnce){
          self.hidingDatePickerView.alpha=0;
         [self selectOnce];
       }else{
          
            self.hidingDatePickerView.alpha=1;
           
            if(self.mode == kModeEveryday){
              [self.everydayBtn changeState:self.everydayBtn];
          }
          if(self.mode == kModeMonthly){
               [self.weekdaysBtn changeState:self.weekdaysBtn];
               self.dayOfMonthPicker.alpha = 1;
               self.hidingDatePickerView.alpha=1;
          }
          if(self.mode == kModeWeekend){
               [self.weekendBtn changeState:self.weekendBtn];
          }
           
       }
    }
    else
    {
        [self.customBtn changeState:self.customBtn];
        self.hidingDatePickerView.alpha=1;
        [self showDaysPlaceholder:YES];
   
        #pragma mark Select Days [Edit Mode]
        NSArray *btns = [self.customDaysPlaceholder subviews];
        for(UIView *v in btns){
            if([v isKindOfClass:[emsCheckButton class]]){
                    customDayTag = v.tag;
                for(int i=0;i<DAYS_ARRAY.count;i++)
                {
                    for(int j=0;j<[_data[@"customDays"] count];j++)
                    {
                        if([DAYS_ARRAY[customDayTag] isEqualToString:[_data objectForKey:@"customDays"][j]])
                        {
                        
                            [(emsCheckButton*)v changeState:(emsCheckButton*)v];
                            
                        
                        }
                    }
                    
                }
            }

        }
    
    }
    
    
}
/*!
 * @discussion init 'data' object
 * @param 'data' init with income data dictionary
 */
-(void)setData:(NSDictionary *)data
{
    _data = [[NSDictionary alloc] initWithDictionary:data];
}
/*!
 * @discussion magic lives here
 */
-(NSString *)stringForIntegerKey:(SchedulerModeCustomDays)key
{
    
    __strong NSString **pointer = (NSString**)&vSU;
    pointer += key;
    return *pointer;
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    daysArray = [[NSMutableArray alloc] init];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark -
#pragma mark UIPicker delegates
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 30;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row
          forComponent:(NSInteger)component reusingView:(UIView *)view
{
    if (!view)
    {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(35, 3, 245, 24)];
        label.backgroundColor = [UIColor clearColor];
        UIFont *font = [UIFont fontWithName:@"MyriadPro-Cond" size:21];
        label.font = font;
        label.tag = 1;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [NSString stringWithFormat:@"%i",(int)row+1];
        [view addSubview:label];
        
    }
    
    
    
    return view;
}
- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    [[ABStoreManager sharedManager] addDateToScheduler:[NSString stringWithFormat:@"%i",(int)row+1] forKey:@"dayOfMonth"];
}
/*!
* @discussion Rearrange views according to button pressed. Each
* button has its own Tag with relates to the SchedulerMode
*/
-(IBAction)schedulerMode:(emsCheckButton*)sender
{
    if(![sender isChecked]/*Prevent deselect selected mode*/)
    {
        [sender changeState:sender];
        self.mode = sender.tag;
        [self deselectModeButtonsExcept:sender];
        if(self.mode == kModeMonthly)
        {
            self.dayOfMonthPicker.alpha = 1;
            self.hidingDatePickerView.alpha=1;
        
        }
        else if(self.mode == kModeOnce)
        {
            self.hidingDatePickerView.alpha=0;
            self.dayOfMonthPicker.alpha = 0;
        }
        else if (self.mode != kModeMonthly)
        {
            self.hidingDatePickerView.alpha=1;
            self.dayOfMonthPicker.alpha = 0;
            
        }
    }
}
-(IBAction)chooseDays:(emsCheckButton*)sender
{
    [sender changeState:sender];
}
-(void)selectOnce
{
    NSArray *btns = [self.view subviews];
    for(UIButton *cView in btns){
        if([cView isKindOfClass:[emsCheckButton class]]){
            if(cView.tag==kModeOnce){
                if(![(emsCheckButton *)cView isChecked]){
                    [(emsCheckButton*)cView changeState:cView];
                }
                
            }
            
        }
    }

}
/*!
 * @discussion set buttons state as unselected but pressed one
 */
-(void)deselectModeButtonsExcept:(emsCheckButton*)btn
{

    NSArray *btns = [self.view subviews];
    for(UIButton *cView in btns){
       if([cView isKindOfClass:[emsCheckButton class]]){
           if(cView.tag!=btn.tag && [(emsCheckButton*)cView isChecked]){
              
                  [(emsCheckButton*)cView changeState:btn];
           }
           
       }
    }
    if(btn.tag==kModeCustom){
        [self showDaysPlaceholder:YES];
        self.mode = kModeCustom;
        if(![btn isChecked]){
           [btn changeState:btn];
        }
            
    }
    else if(btn.tag>=100){
        [self showDaysPlaceholder:NO];
        self.mode = btn.tag;
    }

}
/*!
 * @discussion to display or not custom days. it displays only if user selects scheduler mode 'Custom'
 */
-(void)showDaysPlaceholder:(BOOL)show
{
    if(show){
        [UIView animateWithDuration:0.1 animations:^{
             self.customDaysPlaceholder.alpha=1;
        } completion:^(BOOL finished) {
           
        }];
    }else{
        [UIView animateWithDuration:0.1 animations:^{
            self.customDaysPlaceholder.alpha=0;
        } completion:^(BOOL finished) {
            
        }];
    }
    
}
/*!
* @returns formatted string from date
*/
-(NSString *)stringFromPicker:(UIDatePicker*)picker
{

    NSDate *myDate = picker.date;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
   
    if(picker == self.timePicker)
        [dateFormat setDateFormat:@"hh:mm a"];
    else if(picker == self.datePicker)
        [dateFormat setDateFormat:@"MM/dd/yyyy"];
    return  [dateFormat stringFromDate:myDate];

}
/*!
 * @return Unix timestamp from selected date
 */
-(NSString*)generateUnixTimeFromPicker:(UIDatePicker*)picker
{
    double unixTime = (time_t) [picker.date timeIntervalSince1970];
    NSLog(@"Date %f",unixTime);
    return [NSString stringWithFormat:@"%f",unixTime];
}
- (NSString *) timeStamp {
    return [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
}
/*!
 * @return Unix timestamp from selected date in string for Server
 */
-(NSString*)unixDateForONCEMode
{
    NSString * tm = [self stringFromPicker:self.timePicker];
    NSString * dt = [self stringFromPicker:self.datePicker];
    NSMutableString *res = [NSMutableString new];
    [res appendFormat:@"%@ %@",dt,tm];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy hh:mm a"];
    NSDate * date = [dateFormat dateFromString:res];
    double unixTime = (time_t) [date timeIntervalSince1970];
    NSLog(@"Date %f",unixTime);
    return [NSString stringWithFormat:@"%f",unixTime];

}
/*!
* @discussing
* Collects Scheduler data and inserts it to a Scheduler object.
* This object is inserted to an Activity that is currently being
* created.
*/
-(IBAction)saveData:(UIButton*)sender
{
   if(self.mode==kModeUndefined)
   {
      
       [self messagePopupWithTitle:@"Please, schedule a date of Event/Activity!" hideOkButton:NO];
       return;
   }
   else
   {
        [[ABStoreManager sharedManager] addDateToScheduler:[NSNumber numberWithInt:self.mode] forKey:vSchedulerType];
        if(self.mode == kModeCustom)
        {
        NSArray *btns = [self.customDaysPlaceholder subviews];
        for(UIView *v in btns){
            if([v isKindOfClass:[emsCheckButton class]]){
                if([(emsCheckButton*)v isChecked]){
                    customDayTag = v.tag;
                    [daysArray addObject:
                    DAYS_ARRAY[customDayTag]];
                }
            }
               
        }
        if(daysArray.count==0 && self.mode == kModeCustom){
            [self messagePopupWithTitle:@"Please, choose days!" hideOkButton:NO];
            return;
        }else{
                [[ABStoreManager sharedManager] addDateToScheduler:[self generateUnixTimeFromPicker:self.timePicker] forKey:vScheduledTime];
                [[ABStoreManager sharedManager] addDateToScheduler:daysArray forKey:vDaysArray];
        }
    }
    else if(self.mode == kModeOnce){
       
            [[ABStoreManager sharedManager] addDateToScheduler:[self unixDateForONCEMode] forKey:vScheduledTime];
            [[ABStoreManager sharedManager] addDateToScheduler:[self unixDateForONCEMode] forKey:vScheduledDate];
        
    }
    else  if(self.mode == kModeWeekend || self.mode == kModeEveryday || self.mode == kModeMonthly){
           [[ABStoreManager sharedManager] addDateToScheduler:[self generateUnixTimeFromPicker:self.timePicker] forKey:vScheduledTime];
    }
       
    [[ABStoreManager sharedManager] addDateToScheduler:@"1" forKey:@"enable"];//Needed for server. It uses it in return.
    [[ABStoreManager sharedManager] saveScheduledData];
    [[ABStoreManager sharedManager] saveThisActivity];
     NSLog(@"%@",[ABStoreManager sharedManager].ongoingActivity);
       
       UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ActivityBuilder_4" bundle:nil];
       ScheduledViewController *notebook = [storyboard instantiateViewControllerWithIdentifier:@"ScheduledEvents"];
       [self presentViewController:notebook animated:YES completion:^{
           
       }];
       
       
   }
   
    
}
#pragma mark -Popups
/*!
 * @discussion to opens custom Popup with title
 * @param title desired message to display on popup
 * @param show YES/NO YES to display OK button
 */
-(void)messagePopupWithTitle:(NSString*)title hideOkButton:(BOOL)show
{
    
    popup = [[ScadaddlePopup alloc] initWithFrame:self.view.frame withTitle:title withProgress:NO andButtonsYesNo:NO forTarget:self andMessageType:-1];
    [popup hideDisplayButton:show];
    [self.view addSubview:popup];
    
}
/*!
 * @discussion to dismiss popup [slowly disappears]
 * @param title desired message to display on popup
 * @param duration time while disappearing
 * @param exit YES/NO YES to dismiss this controller
 */

-(void)dismissPopupActionWithTitle:(NSString*)title andDuration:(double)duration andExit:(BOOL)exit
{
    
    [popup updateTitleWithInfo:title];
    [UIView animateWithDuration:duration animations:^{
        
        popup.alpha=0.9;
    } completion:^(BOOL finished) {
        
        [popup removeFromSuperview];
        if(exit)
        {
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
        
    }];
    
    
}
-(IBAction)dismissPopup
{
    [self dismissPopupActionWithTitle:@"" andDuration:0 andExit:NO];
}

@end
