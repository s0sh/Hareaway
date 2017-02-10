//
//  ScheduledItemTableViewCell.m
//  ActivityCreator
//
//  Created by Roman Bigun on 5/7/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "ScheduledItemTableViewCell.h"
#import "ABStoreManager.h"

@implementation ScheduledItemTableViewCell
@synthesize onOffScheduledItem,index;

- (void)awakeFromNib {
    
  [onOffScheduledItem addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
/*!
 * @discussion Choose whether it should be switched off/on. It
 * removes old scheduler item, creates new one and inserts it to
 * a Scheduler object and updates Activity data with new Scheduler.
 * Then it notifies SchedullerController to reload table with new
 * data.
 */
- (void)setState:(id)sender
{
    BOOL state = [sender isOn];
    if(![[ABStoreManager sharedManager] editingMode])
    {
        
        NSMutableDictionary *tmp =[[[ABStoreManager sharedManager] ongoingActivity][@"scheduler"][index] mutableCopy];
        [tmp setObject:[NSNumber numberWithBool:state] forKey:@"enable"];
        [[[ABStoreManager sharedManager] ongoingActivity][@"scheduler"] removeObjectAtIndex:index];
        [[[ABStoreManager sharedManager] ongoingActivity][@"scheduler"] addObject:tmp];
        NSLog(@"%@",[[ABStoreManager sharedManager] ongoingActivity][@"scheduler"]);
    }
    else
    {
        NSMutableDictionary *tmp =[[[ABStoreManager sharedManager] editingActivityData][@"scheduler"][index] mutableCopy];
        [tmp setObject:[NSNumber numberWithBool:state] forKey:@"enable"];
        [[[ABStoreManager sharedManager] editingActivityData][@"scheduler"] removeObjectAtIndex:index];
        [[[ABStoreManager sharedManager] editingActivityData][@"scheduler"] addObject:tmp];
        NSLog(@"%@",[[ABStoreManager sharedManager] editingActivityData][@"scheduler"]);
           
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EMSReloadScheduledTable"
                                                        object:self
                                                      userInfo:nil];
    
    
}
-(void)hideSequencedModeLabel:(BOOL)hide
{

    self.sequencedMode.alpha = hide==YES?0:1;

}
-(void)hideDateLabel:(BOOL)hide
{
    
    self.dateLbl.alpha = hide==YES?0:1;
   
    
}
/*!
 * @discussion Places days on the cell in format e.g MO/TU/TH
 * @param days days to be displayed
 */
-(void)paintDays:(NSArray*)days
{
    for(int i=0;i<days.count;i++){
        NSArray *lbls = [self subviews];
        for(UIView *v in lbls){
            NSArray *inner = [v subviews];
            for(UILabel *lbl in inner){
                if([lbl isKindOfClass:[UILabel class]]){
                    if([[NSString stringWithFormat:@"%@",[days objectAtIndex:i]] isEqualToString:lbl.text]){
                      [lbl setTextColor:[UIColor colorWithRed:110.f/255.f green:224.f/255.f blue:173.f/255.f alpha:1]];
                   }
                }
            }
        
       }
    }
    
    
}
/*!
 * @discussion Change title text according to a schedulerMode
 * Looks like 'Monthly' or 'Daily' etc..
*/
-(void)setTitle:(NSString*)title
{

    self.sequencedMode.text = title;

}
/*!
 * @discussion Check whether current mode is Custom or others and
 * hides/displays days according to bool param ->
 * @param hide YES/NO - hide or display days placeholder
 */
-(void)hideDaysLabels:(BOOL)hide
{
    
    self.sunday.alpha = hide==YES?0:1;
    self.monday.alpha = hide==YES?0:1;
    self.tuesday.alpha = hide==YES?0:1;
    self.wenesday.alpha = hide==YES?0:1;
    self.thirthday.alpha = hide==YES?0:1;
    self.friday.alpha = hide==YES?0:1;
    self.saturday.alpha = hide==YES?0:1;

}
@end
