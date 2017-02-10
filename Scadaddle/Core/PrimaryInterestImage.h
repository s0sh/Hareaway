//
//  PrimaryInterestImage.h
//  Scadaddle
//
//  Created by Roman Bigun on 6/17/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PrimaryInterestImage : NSObject

+(PrimaryInterestImage *)sharedInstance;
/*!
 * @return: Primary Interest Image
 */
-(UIImage *)interestImage;
@end
