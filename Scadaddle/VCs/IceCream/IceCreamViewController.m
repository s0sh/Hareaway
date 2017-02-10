//
//  ViewController.m
//  emsIceCreamDay
//
//  Created by Roman Bigun on 4/29/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "IceCreamViewController.h"
#import "emsMainScreenVC.h"
#import "emsDeviceDetector.h"
@interface IceCreamViewController ()
@property(nonatomic,retain) IBOutlet UILabel *inner_title;
@property(nonatomic,retain) IBOutlet UILabel *about;
@property(nonatomic,retain) IBOutlet UILabel *group;
@property(nonatomic,retain) IBOutlet UILabel *length;
@property(nonatomic,retain) IBOutlet UIImageView *icecreamPromoPic;
@property(nonatomic,retain) IBOutlet UIButton *decleanPromo;
@property(nonatomic,retain) NSDictionary *icecreamData;
@end

@implementation IceCreamViewController

#define ICECREAM_DATA [NSDictionary dictionaryWithObjects:@[@"icecream",@"FREE ICE CREAM DAY",@"120 yd",@"See the list of media liked by the authenticated user. Private media is returned as long as the authenticated user has permission to view that media. Liked media lists are only available for the currently authenticated user.",@"See the list of media liked by the authenticated user. Private media is returned as long as the authenticated user has permission to view that media. Liked media lists are only available for the currently authenticated user."] forKeys:@[@"imageName",@"title",@"length",@"about",@"group"]]

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.icecreamData = ICECREAM_DATA;//should come from server
    self.inner_title.text = self.icecreamData[@"title"];
    self.about.text = self.icecreamData[@"about"];
    self.group.text = self.icecreamData[@"group"];
    self.length.text = self.icecreamData[@"length"];
    self.icecreamPromoPic.image = [UIImage imageNamed:self.icecreamData[@"imageName"]];
}
-(BOOL)isIphone6plus
{
    
    switch (currentDeviceClass()) {
        case thisDeviceClass_iPhone:
        {
            
            return NO;
            
        }
            break;
        case thisDeviceClass_iPhoneRetina:
        {
            
            return NO;
            
        }
            
            break;
        case thisDeviceClass_iPhone5:
        {
            
            return NO;
            
        }
            break;
        case thisDeviceClass_iPhone6:
            
            break;
        case thisDeviceClass_iPhone6plus:
        {
            return YES;
        }
            break;
            
        case thisDeviceClass_iPad:
            
            break;
        case thisDeviceClass_iPadRetina:
            
            break;
            
        case thisDeviceClass_unknown:
        default:
            
            break;
    }
    
    return NO;
    
    
    
}
-(IBAction)declean:(UIButton*)sender
{
        emsMainScreenVC *c = [[emsMainScreenVC alloc] init];
         [self presentViewController:c animated:YES completion:^{
             
         }];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
