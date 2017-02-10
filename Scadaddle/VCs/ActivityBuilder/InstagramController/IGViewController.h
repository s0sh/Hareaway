//
//  IGViewController.h
//  Scadaddle
//
//  Created by Roman Bigun on 6/23/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@interface IGViewController : UIViewController<IGSessionDelegate>
@property (nonatomic, weak) IBOutlet UICollectionView *facebookAlbumsCollection;
@end
