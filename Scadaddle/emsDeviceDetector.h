//
//  emsDeviceDetector.h
//  Scadaddle
//
//  Created by Roman Bigun on 5/1/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, thisDeviceClass) {
    
    thisDeviceClass_iPhone,
    thisDeviceClass_iPhoneRetina,
    thisDeviceClass_iPhone5,
    thisDeviceClass_iPhone6,
    thisDeviceClass_iPhone6plus,
    thisDeviceClass_iPad,
    thisDeviceClass_iPadRetina,
    thisDeviceClass_unknown
};
/*!
 * @discussion  pinpoint the form factor
 */
thisDeviceClass currentDeviceClass();
@interface emsDeviceDetector : NSObject

@end
