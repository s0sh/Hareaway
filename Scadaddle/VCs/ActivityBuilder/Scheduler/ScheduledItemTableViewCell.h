//
//  ScheduledItemTableViewCell.h
//  ActivityCreator
//
//  Created by Roman Bigun on 5/7/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduledItemTableViewCell : UITableViewCell
@property(weak,nonatomic)IBOutlet UILabel *dateLbl;
@property(weak,nonatomic)IBOutlet UILabel *timeLbl;
@property(weak,nonatomic)IBOutlet UILabel *sunday;
@property(weak,nonatomic)IBOutlet UILabel *monday;
@property(weak,nonatomic)IBOutlet UILabel *tuesday;
@property(weak,nonatomic)IBOutlet UILabel *wenesday;
@property(weak,nonatomic)IBOutlet UILabel *thirthday;
@property(weak,nonatomic)IBOutlet UILabel *friday;
@property(weak,nonatomic)IBOutlet UIButton *editTimeBtn;
@property(weak,nonatomic)IBOutlet UILabel *saturday;
@property(weak,nonatomic)IBOutlet UILabel *sequencedMode;
@property int type;
@property int index;
@property(weak,nonatomic)IBOutlet UISwitch *onOffScheduledItem;
-(void)hideDaysLabels:(BOOL)hide;
-(void)hideSequencedModeLabel:(BOOL)hide;
-(void)hideDateLabel:(BOOL)hide;
-(void)paintDays:(NSArray*)days;
-(void)setTitle:(NSString*)title;

@end
