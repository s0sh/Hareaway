//
//  Activity.h
//  ActivityCreator
//
//  Created by Roman Bigun on 5/6/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Activity : NSObject<NSCoding>
@property (nonatomic, copy, readonly) NSString * activityUrl;
- (id)initWithUrl:(NSString *)activityUrl;
@end
