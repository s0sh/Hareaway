//
//  Socials.m
//  Scadaddle
//
//  Created by Roman Bigun on 4/3/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "Socials.h"


@implementation Socials

@synthesize type = _type;
@synthesize data = _data;

-(id)makeObjectForFocialFromDictionary:(NSDictionary*)sData andType:(int)sType
{

    self.type = sType;
    self.data = sData;

    return self;
}
@end
