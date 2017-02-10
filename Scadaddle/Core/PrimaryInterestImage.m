//
//  PrimaryInterestImage.m
//  Scadaddle
//
//  Created by Roman Bigun on 6/17/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "PrimaryInterestImage.h"
#import "emsAPIHelper.h"
#import "ABStoreManager.h"

@implementation PrimaryInterestImage

+ (PrimaryInterestImage *)sharedInstance
{
    
    static PrimaryInterestImage * _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[PrimaryInterestImage alloc] init];
        
    });
    return _sharedInstance;
}

-(id)init
{
    self = [super init];
    if(self)
    {
       
    }
    return self;
    
}
/*!
 * @return: Return main user interest image
 */
-(UIImage *)interestImage
{
    UIImage *image = [[[ABStoreManager sharedManager] imageCache] objectForKey:@"ScadaddleInterestImage"];
    if(!image)
    {
        NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_PATH,[Server primaryInterest]]]];
        image  = [UIImage imageWithData:imageData];
        if(image)
            [[[ABStoreManager sharedManager] imageCache] setObject:image forKey:@"ScadaddleInterestImage"];
    }
    return image;
    
}
@end
