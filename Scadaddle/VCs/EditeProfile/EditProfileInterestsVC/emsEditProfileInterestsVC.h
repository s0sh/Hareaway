//
//  emsEditProfileInterestsVC.h
//  Scadaddle
//
//  Created by developer on 06/10/15.
//  Copyright © 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, InterestTypeByEditInterests) {
    editSpectatorInterests=0,
    editActivityInterests
};

@interface emsEditProfileInterestsVC : UIViewController

@property (nonatomic, assign) InterestTypeByEditInterests interestType;
/**
 * @return return selected intrests
 */
-(id)initWithData:(NSArray *)selectInterests;

@end
