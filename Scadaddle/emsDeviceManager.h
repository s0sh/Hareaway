//
//  emsDeviceManager.h
//  Scadaddle
//
//  Created by Roman Bigun on 5/3/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "emsDeviceDetector.h"
@interface emsDeviceManager : NSObject
/*!
 * @discussion  pinpoint if form factor is 6Plus
 */
+(BOOL)isIphone6plus;
@end
