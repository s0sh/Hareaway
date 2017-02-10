//
//  EnterPhoneNumberViewController.h
//  Verification
//
//  Created by christian jensen on 5/13/15.
//  Copyright (c) 2015 christian jensen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EnterPhoneNumberViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *status;
- (IBAction)requestCode:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end
