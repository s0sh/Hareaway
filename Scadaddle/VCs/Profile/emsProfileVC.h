//
//  emsProfileVC.h
//  Scadaddle
//
//  Created by developer on 06/04/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface emsProfileVC : UIViewController
@property(nonatomic, strong)NSString *profileUserId;
/*!
 *
 *  @discussion method called to clean class instances
 *
*/
-(void)clearData;
@end
