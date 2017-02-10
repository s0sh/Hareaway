//
//  emsLogic.m
//  Scadaddle
//
//  Created by developer on 07/05/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsLogic.h"
//#import "emsLoginVC.h"
#import "emsRegistrationVC.h"
#import "emsInterestsVC.h"
#import "emsProfileVC.h"
#import "emsMainScreenVC.h"
#import "DSViewController.h"

static emsLogic *logicClass = nil;

@implementation emsLogic


+ (emsLogic *) sharedLogic {
    
    
    if(logicClass == nil) {
        
        logicClass = [[emsLogic alloc] init];
    }
    
    return logicClass;
}

-(void)myProfile:(UIViewController*)delegate :(ViewControllerType)viewControllerType inVCp:(UIViewController*)baseVC{
    

    switch (viewControllerType) {
        case LoginVC:
            [baseVC presentViewController:delegate animated:YES completion:^{
                
            }];
              break;
        case egistrationVC:
            [baseVC presentViewController:delegate animated:YES completion:^{
                
            }];

            break;
        case DSVC:
            [baseVC presentViewController:delegate animated:YES completion:^{
                
            }];

            break;
        case InterestsVC:
            [baseVC presentViewController:delegate animated:YES completion:^{
                
            }];

            break;
        case MainScreenVC:
            [baseVC presentViewController:delegate animated:YES completion:^{
                
            }];

            break;
        case ProfileVC:
            [baseVC presentViewController:delegate animated:YES completion:^{
                
            }];

            break;
            
        default:
            break;
    }



}

@end
