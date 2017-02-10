//
//  emsDeviceDetector.m
//  Scadaddle
//
//  Created by Roman Bigun on 5/1/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsDeviceDetector.h"

@implementation emsDeviceDetector

/*!
 * @discussion  pinpoint the form factor
 */

thisDeviceClass currentDeviceClass() {
    
    CGFloat greaterPixelDimension = (CGFloat) fmaxf(((float)[[UIScreen mainScreen]bounds].size.height),
                                                    ((float)[[UIScreen mainScreen]bounds].size.width));
    
    switch ((NSInteger)greaterPixelDimension) {
        case 480:
            return (( [[UIScreen mainScreen]scale] > 1.0) ? thisDeviceClass_iPhoneRetina : thisDeviceClass_iPhone );
            break;
        case 568:
            return thisDeviceClass_iPhone5;
            break;
        case 667:
            return thisDeviceClass_iPhone6;
            break;
        case 736:
            return thisDeviceClass_iPhone6plus;
            break;
        case 1024:
            return (( [[UIScreen mainScreen]scale] > 1.0) ? thisDeviceClass_iPadRetina : thisDeviceClass_iPad );
            break;
        default:
            return thisDeviceClass_unknown;
            break;
    }
}

@end
