//
//  DSViewController.m
//  DreamShot
//
//  Created by Roman Bigun on 4/27/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "DSViewController.h"
#import "UIColor+expanded.h"
#import "emsMainScreenVC.h"
#import "emsDeviceDetector.h"
@interface DSViewController ()

@end

@implementation DSViewController

#define DREAMSHOT_DATA [NSDictionary dictionaryWithObjects:@[@"photo_1_profile",@"Scadaddle DreamShot Adventure / Episode 6",@"TODAY 12:00 AM / 27 April 2015",@"57",@"See the list of media liked by the authenticated user. Private media is returned as long as the authenticated user has permission to view that media. Liked media lists are only available for the currently authenticated user.",@"Who will be performing tonight?",@"Bottle Rock Nappa Valey",@"The AFC Fairgrounds",@"Boots And Hearts"] forKeys:@[@"imageName",@"title",@"date",@"likes",@"description",@"question",@"first_answer",@"second_answer",@"third_answer"]]

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dsData = DREAMSHOT_DATA;//DREAMSHOT_DATA comes from server. Predefined, just for tests
    [self initPage];
    // Do any additional setup after loading the view.
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
-(IBAction)close:(UIButton*)sender
{
       emsMainScreenVC *c = [[emsMainScreenVC alloc] initWithNibName:[self isIphone6plus]?@"emsMainScreenVC_6plus":@"emsMainScreenVC" bundle:[NSBundle mainBundle]];
        [self presentViewController:c animated:YES completion:^{
            
        }];
    

}
-(void)initPage
{

    self.dsMainImage.image = [UIImage imageNamed:self.dsData[@"imageName"]];
    self.dsTitle.text = self.dsData[@"title"];
    self.dsDescriptionLbl.text = self.dsData[@"description"];
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:self.dsData[@"date"]];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"0x1a4d81"] range:NSMakeRange(6,8)];
    [string addAttribute:NSFontAttributeName
                   value:[UIFont systemFontOfSize:11.0]
                   range:NSMakeRange(14, 16)];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(14,16)];
   
        
    [self.dateLbl setAttributedText:string];
    self.likesCount.text = self.dsData[@"likes"];
    self.dsQuestion.text = self.dsData[@"question"];
    self.a1.text = self.dsData[@"first_answer"];
    self.a2.text = self.dsData[@"second_answer"];
    self.a3.text = self.dsData[@"third_answer"];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)choose:(UIButton*)sender
{

    switch (sender.tag)
    {
        case 100:
        {
        
            self.selectedIndex = 0;
            [self.a1Btn setBackgroundImage:[UIImage imageNamed:@"chek_interests"] forState:UIControlStateNormal];
            [self.a2Btn setBackgroundImage:[UIImage imageNamed:@"non_chek_interests"] forState:UIControlStateNormal];
            [self.a3Btn setBackgroundImage:[UIImage imageNamed:@"non_chek_interests"] forState:UIControlStateNormal];
        
        }
        break;
        case 101:
        {
            self.selectedIndex = 1;
            [self.a1Btn setBackgroundImage:[UIImage imageNamed:@"non_chek_interests"] forState:UIControlStateNormal];
            [self.a2Btn setBackgroundImage:[UIImage imageNamed:@"chek_interests"] forState:UIControlStateNormal];
            [self.a3Btn setBackgroundImage:[UIImage imageNamed:@"non_chek_interests"] forState:UIControlStateNormal];
        
        }
            break;
        case 102:
        {
            self.selectedIndex = 2;
            [self.a1Btn setBackgroundImage:[UIImage imageNamed:@"non_chek_interests"] forState:UIControlStateNormal];
            [self.a2Btn setBackgroundImage:[UIImage imageNamed:@"non_chek_interests"] forState:UIControlStateNormal];
            [self.a3Btn setBackgroundImage:[UIImage imageNamed:@"chek_interests"] forState:UIControlStateNormal];
            
        }
        break;
        case 103:
        {
            
            //[Core sendVoteWithIndex:self.selectedIndex];
            
        }
            break;
        default:
            break;
    }
    

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
