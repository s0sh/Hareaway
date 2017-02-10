//
//  FriendsViewController.h
//  Scadaddle
//
//  Created by Roman Bigun on 5/26/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendsTableViewCell.h"

@interface FriendsViewController : UIViewController<CellControllerDelegate,UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,retain)IBOutlet UITableView *table;
@property(nonatomic,weak)IBOutlet UIView *shtorka;
@property(nonatomic,weak)IBOutlet UIView *noFriends;
@property(nonatomic,weak)IBOutlet UIActivityIndicatorView *shtorkaIndicator;

@end

