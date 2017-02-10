//
//  YTPlayerViewController.m
//  Scadaddle
//
//  Created by Roman Bigun on 9/11/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "YTPlayerViewController.h"

@interface YTPlayerViewController ()

@end

@implementation YTPlayerViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSAssert([[NSUserDefaults standardUserDefaults] objectForKey:@"currentYTVideoID"] != nil, @"Video ID not found!");
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"currentYTVideoID"]);
    [self.playerView loadWithVideoId:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"currentYTVideoID"]]];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)back
{
    self.playerView = nil;
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];

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
