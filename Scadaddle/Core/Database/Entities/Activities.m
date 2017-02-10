//
//  Activities.m
//  Scadaddle
//
//  Created by Roman Bigun on 3/31/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "Activities.h"
#import "dbconstants.h"

@implementation Activities

@synthesize objId,
userId,
locationId,
interestId,
places,
promoted,
status,
created,
title,
objDescription,
facebook,
twitter,
youtube,
reward,
image,
imagePath,
activityFiles,
activityFriends,
activityInterests,
activityTimes;

-(id)makeObjectForActivitiesFromDictionary:(NSDictionary*)data
{
    self.userId = [[NSString stringWithFormat:@"%@",[data objectForKey:kUserID]] intValue];
    self.objId = [[NSString stringWithFormat:@"%@",[data objectForKey:kId]] intValue];
    self.locationId = [[NSString stringWithFormat:@"%@",[data objectForKey:kLocationId]] intValue];
    self.interestId = [[NSString stringWithFormat:@"%@",[data objectForKey:kInterestId]] intValue];
    self.places = [[NSString stringWithFormat:@"%@",[data objectForKey:kPlaces]] intValue];
    self.promoted = [[NSString stringWithFormat:@"%@",[data objectForKey:kPromoted]] intValue];
    self.status = [[NSString stringWithFormat:@"%@",[data objectForKey:kCreated]] intValue];
    self.title = [data objectForKey:kTitle];
    self.objDescription = [data objectForKey:kDescription];
    self.facebook = [data objectForKey:kFacebook];
    self.twitter = [data objectForKey:kTwitter];
    self.youtube = [data objectForKey:kYoutube];
    self.reward = [data objectForKey:kReward];
    self.activityTimes = [data objectForKey:kActivityTimes];
    self.activityFriends = [data objectForKey:kActivityFriends];
    self.activityInterests = [data objectForKey:kActivityInterests];
    self.activityFiles = [data objectForKey:kActivityTimes];
  
    return self;
    
    
}


@end
