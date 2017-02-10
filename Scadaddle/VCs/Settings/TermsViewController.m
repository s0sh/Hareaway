//
//  TermsViewController.m
//  Scadaddle
//
//  Created by Roman Bigun on 6/20/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "TermsViewController.h"
#import "ABStoreManager.h"

@interface TermsViewController ()

@end

@implementation TermsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *url=[NSString stringWithFormat:@"http://scad.gotests.com/terms_and_conditions.html"];
    NSURL *nsurl=[NSURL URLWithString:url];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [self.webView loadRequest:nsrequest];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)close
{

    [self  dismissViewControllerAnimated:TRUE completion:^{
        
    }];

}

@end
