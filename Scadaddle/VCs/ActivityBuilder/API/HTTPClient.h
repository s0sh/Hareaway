//
//  HTTPClient.h
//  ActivityCreator
//
//  Created by Roman Bigun on 5/6/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//  @discussion  Class uses for download images when Activity is being created
//  @type KVO

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HTTPClient : NSObject
+ (HTTPClient *)sharedInstance;
@end
