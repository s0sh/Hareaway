//
//  emsServerErrorHandler.m
//  Scadaddle
//
//  Created by Roman Bigun on 7/30/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsServerErrorHandler.h"


@implementation emsServerErrorHandler

+ (emsServerErrorHandler *)sharedInstance
{
    
    static emsServerErrorHandler * _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[emsServerErrorHandler alloc] init];
        
    });
    
    return _sharedInstance;
}
-(BOOL)checkSuccessfull:(NSDictionary*)respond
{

    if([respond[@"saccess"] integerValue]==1)
    {
        return YES;
    }
    
    return NO;

}
@end
