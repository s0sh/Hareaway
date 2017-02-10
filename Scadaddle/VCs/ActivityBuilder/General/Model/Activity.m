//
//  Activity.m
//  ActivityCreator
//
//  Created by Roman Bigun on 5/6/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "Activity.h"

@implementation Activity

- (id)initWithUrl:(NSString *)activityUrl
{
    self = [super init];
    if (self)
    {
        _activityUrl = activityUrl;
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
    [aCoder encodeObject:self.activityUrl forKey:@"activity_url"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _activityUrl = [aDecoder decodeObjectForKey:@"activity_url"];
       
    }
    return self;
}


@end
