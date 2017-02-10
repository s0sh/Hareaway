//
//  UIAlertView+showMessage.h
//  Scadaddle
//
//  Created by Roman Bigun on 8/15/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (showMessage)
+ (void)showAlertWithMessage:(NSString *)message;
+ (void)showAlertWithMessage_Block:(NSString *)message;
@end
