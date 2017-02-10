//
//  VerifyCodeViewController.m
//  Verification
//
//  Created by christian jensen on 5/13/15.
//  Copyright (c) 2015 christian jensen. All rights reserved.
//

#import "VerifyCodeViewController.h"
#import <SinchVerification/SinchVerification.h>
#import "emsMainScreenVC.h"
#import "emsAPIHelper.h"
#import "ABStoreManager.h"
@interface VerifyCodeViewController ()

@end

@implementation VerifyCodeViewController
@synthesize verification, code, status
;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [code becomeFirstResponder];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [code resignFirstResponder];
}

/*
 #pragma mark - Navigation
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
-(void)moveToMainScreen
{

    [self presentViewController:[[emsMainScreenVC alloc] init] animated:YES completion:^{
        
    }];

    

}
- (IBAction)verifyCode:(id)sender {
    
    if ([code.text isEqualToString:@""])
    {
        status.text = @"You must enter a code";
    }
    
    [_spinner startAnimating];
    [self.verification
     verifyCode:code.text
     completionHandler:^(BOOL success, NSError* error) {
         if (success) {
             [_spinner stopAnimating];
             status.textColor = [UIColor greenColor];
             status.text = @"SUCCESS!";
             [code resignFirstResponder];
             if([Server phoneVerifyed:[[ABStoreManager sharedManager] phoneNumber]])
             {
                 status.text = @"Success!Server data updated!";
             }
             [self performSelector:@selector(moveToMainScreen) withObject:nil afterDelay:1];
             
         } else {
            [_spinner stopAnimating];
             status.textColor = [UIColor redColor];
             status.text = @"WRONG CODE!";
         }
     }];
}
@end
