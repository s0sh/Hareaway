//
//  emsLogic.h
//  Scadaddle
//
//  Created by developer on 07/05/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ViewControllerType) {
    LoginVC= 0,
    egistrationVC,
    InterestsVC,
    MainScreenVC,
    ProfileVC,
    DSVC,

};

@interface emsLogic : NSObject

@property (nonatomic,assign) ViewControllerType viewControllersType;

+ (emsLogic *) sharedLogic;


-(void)myProfile:(UIViewController*)delegate :(ViewControllerType)viewControllerType inVCp:(UIViewController*)baseVC;

@end
