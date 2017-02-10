//
//  ConfirmedViewController.m
//  Verification
//
//  Created by christian jensen on 5/13/15.
//  Copyright (c) 2015 christian jensen. All rights reserved.
//

#import "ConfirmedViewController.h"
#import "emsMainScreenVC.h"
@interface ConfirmedViewController ()

@end

@implementation ConfirmedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self presentViewController:[[emsMainScreenVC alloc] init] animated:YES completion:^{
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)startOver:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
