//
//  TWHelper.h
//  Scadaddle
//
//  Created by Roman Bigun on 4/8/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>
#import "SocialsStoreCoordinator.h"




@interface TWHelper : NSObject
+(void)insertTwitterLoginButtonIntoViewController:(UIViewController*)controller;
-(void)twitterProcess:(UIView*)target;
@end
