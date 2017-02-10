//
//  ScheduledViewController.h
//  ActivityCreator
//
//  Created by Roman Bigun on 5/7/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduledViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(weak,nonatomic)IBOutlet UITableView *itemsTable;

@end
