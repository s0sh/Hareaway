//
//  emsMoodesCell.h
//  Scadaddle
//
//  Created by developer on 15/04/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface emsMoodesCell : UICollectionViewCell

@property(weak)IBOutlet UIImageView *interestsImage;
@property(weak)IBOutlet UILabel *interestsName;
@property(weak)IBOutlet UIButton *selectInterest;
@property(nonatomic,retain)NSIndexPath *indexpath;
@property(nonatomic,retain) NSString *itemID;
@property int tag1;
@end
