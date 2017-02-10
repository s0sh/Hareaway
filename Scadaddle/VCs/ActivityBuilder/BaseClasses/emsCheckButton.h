//
//  emsCheckButton.h
//  ActivityCreator
//
//  Created by Roman Bigun on 5/5/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface emsCheckButton : UIButton
@property BOOL isChecked;
@property BOOL uncheckAllExceptMe;
-(IBAction)changeState:(UIButton*)sender;
@end
