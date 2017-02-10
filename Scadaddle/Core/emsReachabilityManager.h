//
//  emsReachabilityManager.h
//  Scadaddle
//
//  Created by Roman Bigun on 10/7/15.
//  Copyright © 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
@interface emsReachabilityManager : NSObject
{


}
@property (strong, nonatomic) Reachability *reach;
@property (assign, nonatomic) BOOL isInternetConnected;
+(emsReachabilityManager*)sharedInstance;

@end
