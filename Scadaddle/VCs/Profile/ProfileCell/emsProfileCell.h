//
//  emsProfileCell.h
//  Scadaddle
//
//  Created by developer on 06/04/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface emsProfileCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *cellInterestView;
@property (nonatomic, weak) IBOutlet UIImageView *line;
-(void)configureCellItemsWithData:(NSString*)data;
@end
