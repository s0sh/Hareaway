//
//  ScadaddlePopup.h
//  Scadaddle
//
//  Created by Roman Bigun on 6/25/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScadaddlePopup : UIView
- (id)initWithFrame:(CGRect)frame withTitle:(NSString*)title withProgress:(BOOL)isProgress andButtonsYesNo:(BOOL)yesNo forTarget:(id)target andMessageType:(int)type;
-(void)hideDisplayButton:(BOOL)hide;
-(void)updateTitleWithInfo:(NSString *)title;
-(void)dismissPopup;
@end
