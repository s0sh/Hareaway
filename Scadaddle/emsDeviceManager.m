//
//  emsDeviceManager.m
//  Scadaddle
//
//  Created by Roman Bigun on 5/3/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsDeviceManager.h"

@implementation emsDeviceManager
/*!
 * @discussion  pinpoint if form factor is 6Plus
 */
+(BOOL)isIphone6plus
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


@end
