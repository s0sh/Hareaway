//
//  ScheduledViewController.m
//  ActivityCreator
//
//  Created by Roman Bigun on 5/7/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "ScheduledViewController.h"
#import "ScheduledItemTableViewCell.h"
#import "ABStoreManager.h"
#import "ABSchedulerViewController.h"
#import "SCLocationViewController.h"
@interface ScheduledViewController ()

@end

@implementation ScheduledViewController
{

    NSMutableArray *dataArray;
    BOOL timeSelected;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.itemsTable.delegate = self;
    self.itemsTable.dataSource = self;
    
    
}
/*!
 * @discussing
 * cleaning scheduler data
 * loads new one
 * reloads table
 */
-(void)reloadTable:(NSNotification *)notification
{
    
    [dataArray removeAllObjects];
    dataArray = [[NSMutableArray alloc] initWithArray:[[ABStoreManager sharedManager] editingActivityData][@"scheduler"]];
    [self.itemsTable reloadData];
    
}
-(void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:YES];
    if([[ABStoreManager sharedManager] editingMode]==YES)
    {
       
          dataArray = [[NSMutableArray alloc] initWithArray:[[ABStoreManager sharedManager] editingActivityData][@"scheduler"]];
    }
    else
    {
          dataArray = [[NSMutableArray alloc] initWithArray:[[ABStoreManager sharedManager] ongoingActivity][@"scheduler"]];
         
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable:) name:@"EMSReloadScheduledTable" object:nil];
    if(dataArray.count>0)
      [self.itemsTable reloadData];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*!
 * @discussing Saves data and move to LocationView to select
 * Activity location
 */
-(IBAction)saveActivity:(id)sender
{

    NSArray *tmp = nil;
    timeSelected = NO;
    if(![[ABStoreManager sharedManager] editingMode])
    {
       tmp = [NSArray arrayWithArray:[[ABStoreManager sharedManager] ongoingActivity][@"scheduler"]];
        
    }
    else
    {
    
        tmp = [NSArray arrayWithArray:[[ABStoreManager sharedManager] editingActivityData][@"scheduler"]];
    
    }
    for(int i=0;i<tmp.count;i++)
    {
    
        if([tmp[i][@"enable"] integerValue]==1)
        {
            timeSelected = YES;
          
        }
    
    }
    if(timeSelected)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ActivityBuilder_4" bundle:nil];
        SCLocationViewController *scheduler = [storyboard instantiateViewControllerWithIdentifier:@"SCLocationViewController"];
        [self presentViewController:scheduler animated:NO completion:^{
            
        }];
    }
    else
    {
    
        [[[UIAlertView alloc] initWithTitle:@"Scheduler" message:@"Please, select at least one date!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
    
    }
    
}
#pragma --
#pragma mark TableView delegates
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 82;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  [[ABStoreManager sharedManager] editingMode]?
    [[[ABStoreManager sharedManager] editingActivityData][@"scheduler"] count]:
    [[[ABStoreManager sharedManager] ongoingActivity][@"scheduler"]count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    NSString *cellIdentifier = [NSString stringWithFormat:@"cell%d",indexPath.row];
    ScheduledItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScheduledItemTableViewCell"];
    
    if (cell == nil){
        NSLog(@"indexPath.row %ld",(long)indexPath.row);
    }
    
    if (!cell) {
        
        NSArray* xibCell = [[NSBundle mainBundle] loadNibNamed:@"ScheduledItemTableViewCell" owner:self options:nil];
        cell = [xibCell objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        /////Stored data
        NSDictionary *tmpData = [NSDictionary dictionaryWithDictionary:[[ABStoreManager sharedManager] editingMode]?
                                 [[ABStoreManager sharedManager] editingActivityData][@"scheduler"][indexPath.row]:
                                 [[ABStoreManager sharedManager] ongoingActivity][@"scheduler"][indexPath.row]];
        
        int type =[[NSString stringWithFormat:@"%@",[tmpData objectForKey:vSchedulerType]] intValue];
        NSString *typeStr =[[ABStoreManager sharedManager]  translateTypeIntoString:type];
        [cell setTitle:typeStr];
        cell.timeLbl.font = [UIFont fontWithName:@"MyriadPro-Cond" size:25];
        cell.index = [[NSString stringWithFormat:@"%li",(long)indexPath.row] intValue];
        
        if([tmpData[@"enable"] integerValue]==1)
        {
           timeSelected  = YES;
        }
       
        NSString *time = [NSString stringWithFormat:@"%@",[tmpData objectForKey:vScheduledTime]];
        NSString *date = [NSString stringWithFormat:@"%@",[tmpData objectForKey:vScheduledDate]];
        NSLog(@"%@",date);
        if([typeStr isEqualToString:@"Custom"]){
            
            cell.timeLbl.attributedText = [self attributedTimeText:[self strTime:time]];
            [cell.onOffScheduledItem setOn:[tmpData[@"enable"] integerValue]];
            [cell hideDaysLabels:NO];
            [cell hideDateLabel:YES];
            [cell paintDays:[tmpData objectForKey:vDaysArray]];
            [cell hideSequencedModeLabel:NO];
            
        }
        else if([typeStr isEqualToString:@"Once"])
        {
            cell.timeLbl.attributedText = [self attributedTimeWithDayOfWeek_custom:[self strTimeWithDay:time andDate:time]];
            cell.dateLbl.text = [self strDate:time];
            [cell.onOffScheduledItem setOn:[tmpData[@"enable"] integerValue]];
            [cell hideDaysLabels:YES];
            [cell hideSequencedModeLabel:NO];
            [cell hideDateLabel:NO];
                    
        }
        else if([typeStr isEqualToString:@"Weekends"] || [typeStr isEqualToString:@"Everyday"])
        {
        
            cell.timeLbl.attributedText = [self attributedTimeText:[self strTime:time]];
            [cell.onOffScheduledItem setOn:[tmpData[@"enable"] integerValue]];
            [cell hideDaysLabels:YES];
            [cell hideSequencedModeLabel:NO];
            [cell hideDateLabel:YES];
            
        }
        else if([typeStr isEqualToString:@"Monthly"])
        {
        
            cell.timeLbl.attributedText = [self attributedTimeText:[self strTime:time]];
            [cell.onOffScheduledItem setOn:[tmpData[@"enable"] integerValue]];
            [cell hideDaysLabels:YES];
            [cell hideSequencedModeLabel:NO];
            [cell hideDateLabel:YES];
            NSString *newTitle = [typeStr stringByAppendingString:[NSString stringWithFormat:@", each %@ day",tmpData[@"dayOfMonth"]]];
            [cell setTitle:newTitle];
        
        }
        
        cell.editTimeBtn.tag = indexPath.row;
        [cell.editTimeBtn addTarget:self action:@selector(editTime:) forControlEvents:UIControlEventTouchUpInside];
  
    }
    return cell;
    
}
-(IBAction)backAndDeleteData{
  
}
#pragma -
#pragma mark Date/Time workers
-(IBAction)editTime:(UIButton*)sender
{

    if([[ABStoreManager sharedManager] editingMode]==YES)
    {

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ActivityBuilder_4" bundle:nil];
        ABSchedulerViewController *scheduler = [storyboard instantiateViewControllerWithIdentifier:@"ABSchedulerViewController"];
        [[[ABStoreManager sharedManager] editingActivityData][@"scheduler"] removeObjectAtIndex:sender.tag];
        [scheduler setData:[dataArray objectAtIndex:sender.tag]];
        
        [self presentViewController:scheduler animated:NO completion:^{
            
        }];
        
    }

}
/**
 * @discussion to get day from unix time
 * @param timeObj unix time
 * @return day
 */

-(NSString*)getDayFromData:(NSString*)timeObj
{
    
    double unixTimeStamp =[timeObj doubleValue];
    NSTimeInterval _interval=unixTimeStamp;
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:_interval];
    
    NSDateFormatter *formatter= [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en/US"];
    [formatter setLocale:locale];
    [formatter setDateFormat:@"dd"];
    NSString *res = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
    return res;
    
}
/**
 * @discussion to get time from unix time
 * @param timeObj unix time
 * @return time
 */
-(NSString*)strTime:(NSString*)timeObj
{
    
    double unixTimeStamp =[timeObj doubleValue];
    NSTimeInterval _interval=unixTimeStamp;
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:_interval];
    
    NSDateFormatter *formatter= [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en/US"];
    [formatter setLocale:locale];
    [formatter setDateFormat:@"hh:mm a"];
    NSString *res = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
    return res;
    
}
/**
 * @discussion to get formatted day/time from unix time
 * @param timeObj unix time
 * @return date
 */
-(NSString*)strTimeWithDay:(NSString*)timeObj andDate:(NSString *)dateStr
{
    
    double unixTimeStamp =[timeObj doubleValue];
    NSTimeInterval _interval=unixTimeStamp;
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:_interval];
    
    double unixTimeStamp1 =[dateStr doubleValue];
    NSTimeInterval _interval1=unixTimeStamp1;
    NSDate *date1 = [[NSDate alloc] initWithTimeIntervalSince1970:_interval1];
    
    NSDateFormatter *formatter= [[NSDateFormatter alloc] init];
    NSDateFormatter *formatterDate= [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en/US"];
    [formatter setLocale:locale];
    [formatterDate setDateFormat:@"MM-dd-yyyy"];
    [formatterDate setLocale:locale];
    [formatterDate setDateStyle:NSDateFormatterMediumStyle];
    [formatter setDateFormat:@"hh:mm a"];
    NSString *res = [NSString stringWithFormat:@"%@ %@",[self dayOfWeek:[formatterDate stringFromDate:date]],[formatter stringFromDate:date]];
    return res;
    
}
/**
 * @discussion to get date from unix time
 * @param timeObj unix time
 * @return day
 */
-(NSString*)strDate:(NSString*)timeObj
{
    
    double unixTimeStamp =[timeObj doubleValue];
    NSTimeInterval _interval=unixTimeStamp;
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:_interval];
    NSDateFormatter *formatter= [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en/US"];
    [formatter setLocale:locale];
    [formatter setDateFormat:@"MM-dd-yyyy"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    return [formatter stringFromDate:date];
    
}
/**
 * @discussion to get day of week from date
 * @param newDate pass this param to this 
 * method to know what exactly day of week it relates to
 * @return day of week
 */
-(NSString*)dayOfWeek:(NSString*)newDate
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en/US"]];
    NSDate *capturedStartDate = [dateFormatter dateFromString:newDate];
    
    NSDateFormatter *nowDateFormatter = [[NSDateFormatter alloc] init];
    NSArray *daysOfWeek = @[@"",@"SU",@"MO",@"TU",@"WE",@"TH",@"FR",@"SA"];
    [nowDateFormatter setDateFormat:@"e"];
    NSInteger weekdayNumber = (NSInteger)[[nowDateFormatter stringFromDate:capturedStartDate] integerValue];
    NSLog(@"Day of Week: %@",[daysOfWeek objectAtIndex:weekdayNumber]);
    
    return [daysOfWeek objectAtIndex:weekdayNumber];
    
}
-(NSAttributedString *)attributedTimeText:(NSString*)text
{
    
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:text];
    [string addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"MyriadPro-Cond" size:21] range:NSMakeRange(6,2)];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0,8)];
    
    return string;
}
-(NSAttributedString *)attributedTimeWithDayOfWeek_custom:(NSString*)text
{
    
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:text];
    [string addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"MyriadPro-Cond" size:25] range:NSMakeRange(0,8)];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0,3)];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(3,8)];
    [string addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"MyriadPro-Cond" size:18] range:NSMakeRange(9,2)];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(9,2)];
    
    return string;
}

-(void)dealloc
{

    [[NSNotificationCenter defaultCenter] removeObserver:self];

}
@end
