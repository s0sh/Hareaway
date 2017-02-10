//
//  UIAlertView+showMessage.m
//
//
//  Created by Roman Bigun on 8/15/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "UIAlertView+showMessage.h"

@implementation UIAlertView (showMessage)
+ (void)showAlertWithMessage:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:nil
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}
+ (void)showAlertWithMessage_Block:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:nil
                                message:message
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:nil] show];
}
@end
