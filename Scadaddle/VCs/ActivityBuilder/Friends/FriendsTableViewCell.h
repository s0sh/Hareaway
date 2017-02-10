//
//  FriendsTableViewCell.h
//  Scadaddle
//
//  Created by Roman Bigun on 6/15/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CellControllerDelegate;

@interface FriendsTableViewCell : UITableViewCell
@property(nonatomic,weak)IBOutlet UIImageView *avatar;
@property(nonatomic,weak)IBOutlet UILabel *name;
@property(nonatomic,weak)IBOutlet UIButton *selectBtn;
@property(nonatomic,retain) NSString *userId;
-(void)configureCellItemsUsingData:(NSDictionary*)data;
@property (nonatomic, weak) id<CellControllerDelegate> delegate;
@end
@protocol CellControllerDelegate <NSObject>

- (void)cellController:(UITableViewCell*)cellController
didPressButton:(NSString*)value userId:(NSString*)userId;
@end