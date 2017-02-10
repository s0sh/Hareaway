//
//  EnterPhoneNumberViewController.m
//  Verification
//
//  Created by christian jensen on 5/13/15.
//  Copyright (c) 2015 christian jensen. All rights reserved.
//

#import "EnterPhoneNumberViewController.h"
#import "VerifyCodeViewController.h"
#import <SinchVerification/SinchVerification.h>
#import "ABStoreManager.h"
#import "emsProfileVC.h"
@interface EnterPhoneNumberViewController ()
{
    id<SINVerification> _verification;
}
@end

@implementation EnterPhoneNumberViewController
@synthesize spinner, phoneNumber, status;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [phoneNumber becomeFirstResponder];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [phoneNumber resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

-(IBAction)back
{

    [self presentViewController:[[emsProfileVC alloc] init] animated:YES completion:^{
        
    }];

}
- (IBAction)requestCode:(id)sender
{
    //some simple validation
    status.text = @"";
    if ([phoneNumber.text isEqualToString:@""])
    {
        status.text = @"You must enter a phonenumber";
        return;
    }
    //Set the spinner to the whole screen to block further ui interaction.
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:spinner attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:spinner attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [spinner startAnimating];
    //start the verification process with the phonenumber in the field
    _verification = [SINVerification SMSVerificationWithApplicationKey:@"5ed9928a-36c4-4d3b-a012-a4cc1d05cb79" phoneNumber:phoneNumber.text];
    //set up a initiate the process
    [_verification initiateWithCompletionHandler:^(BOOL success, NSError *error) {
        [spinner stopAnimating];
        if (success) {
            [[ABStoreManager sharedManager] storePhoneNumber:phoneNumber.text];
            [self performSegueWithIdentifier:@"verifyCodeSeg" sender:nil];
        }
        else
        {
            status.text = [error description];
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    VerifyCodeViewController* vc = [segue destinationViewController];
    vc.verification = _verification;
}
@end
