//
//  Profile.m
//  Scadaddle
//
//  Created by Roman Bigun on 3/31/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "Profile.h"
#import "dbconstants.h"

@implementation Profiles

@synthesize objId,
created,
modeId,
locationId,
access,
login,
status,
lanStatus,
fbId,
email,
role,
name,
about,
timezone,
image,
imagePath,
userBusiness,
userFiles,
userInterests,
userReferences,
userSettings,
userBirthday,
accessToken;

-(id)makeObjectForProfileFromDictionary:(NSDictionary*)data
{
    
    self.objId = [[NSString stringWithFormat:@"%@",[data objectForKey:kId]] intValue];
    self.locationId = [[NSString stringWithFormat:@"%@",[data objectForKey:kLocationId]] intValue];
    self.created = [[NSString stringWithFormat:@"%@",[data objectForKey:kCreated]] intValue];
    self.modeId = [[NSString stringWithFormat:@"%@",[data objectForKey:kModeId]] intValue];
    self.access = [[NSString stringWithFormat:@"%@",[data objectForKey:kAccess]] intValue];
    self.login = [[NSString stringWithFormat:@"%@",[data objectForKey:kLogin]] intValue];
    self.status = [[NSString stringWithFormat:@"%@",[data objectForKey:kStatus]] intValue];
    self.lanStatus = [[NSString stringWithFormat:@"%@",[data objectForKey:kLanStatus]] intValue];
    self.fbId = [NSString stringWithFormat:@"%@",[data objectForKey:kFacebookId]];
    self.userBirthday = [NSString stringWithFormat:@"%@",[data objectForKey:kUserBirthday]];
    self.email = [NSString stringWithFormat:@"%@",[data objectForKey:kEmail]];
    self.role = [NSString stringWithFormat:@"%@",[data objectForKey:kRole]];
    self.name = [NSString stringWithFormat:@"%@",[data objectForKey:kName]];
    self.about = [NSString stringWithFormat:@"%@",[data objectForKey:kAbout]];
    self.timezone = [NSString stringWithFormat:@"%@",[data objectForKey:kTimezone]];
    self.userSettings = [data objectForKey:kSettings];
    self.userReferences = [data objectForKey:kReferences];
    self.userInterests = [data objectForKey:kUserInterests];
    self.userFiles = [data objectForKey:kUserFiles];
    self.userBusiness = [data objectForKey:kBusiness];
    self.userActivities = [data objectForKey:kActifities];
   
    
    return self;
    
    
}
@end
