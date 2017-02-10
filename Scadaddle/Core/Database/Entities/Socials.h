//
//  Socials.h
//  Scadaddle
//
//  Created by Roman Bigun on 4/3/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Socials : NSObject
@property(nonatomic,retain)NSDictionary *data;
@property int type;
-(id)makeObjectForFocialFromDictionary:(NSDictionary*)data andType:(int)type;
@end
