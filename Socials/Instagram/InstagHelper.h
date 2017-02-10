//
//  InstagHelper.h
//  Scadaddle
//
//  Created by Roman Bigun on 4/8/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Instagram.h"
#import "ObjectHandler.h"
@interface InstagHelper : NSObject<IGSessionDelegate,IGRequestDelegate>
@property (strong, nonatomic) Instagram *instagram;
@property (strong, nonatomic) NSArray *data;
@property BOOL isInstagramLoggedIn;
-(void)instagramLogin;
-(NSArray*)getInstagramPosts;
+ (InstagHelper *)sharedInstance;
@end
