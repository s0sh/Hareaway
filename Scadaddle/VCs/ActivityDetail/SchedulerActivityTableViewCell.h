//
//  SchedulerActivityTableViewCell.h
//  Scadaddle
//
//  Created by Roman Bigun on 7/23/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SchedulerActivityTableViewCell : UITableViewCell
{

}
@property(nonatomic,weak)IBOutlet UILabel *schedulerTypeLbl;
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLbl;
/*!
 * @discussion  Load all data to a cell controlls
 * @param data cell data
 */
-(void)configureCellItemsWithData:(NSDictionary*)data;
@end
