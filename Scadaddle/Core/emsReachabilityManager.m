//
//  emsReachabilityManager.m
//  Scadaddle
//
//  Created by Roman Bigun on 10/7/15.
//  Copyright © 2015 Roman Bigun. All rights reserved.
//

#warning remove this class as Apple guys rejected app with Reachability class included

#import "emsReachabilityManager.h"


@implementation emsReachabilityManager

-(void)setupReachability
{
    
#pragma mark Reachability
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    _reach = [Reachability reachabilityForInternetConnection];
    [_reach startNotifier];
    
    if ([_reach currentReachabilityStatus] != NotReachable)
    {
        _isInternetConnected = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EMSReachableChanged"
                                                            object:self
                                                          userInfo:@{@"startus":@YES}];
        
    }
    else
    {
        _isInternetConnected = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EMSReachableChanged"
                                                            object:self
                                                          userInfo:@{@"startus":@NO}];
    }
    
    
}
-(BOOL)isInternetConnected
{
    
    return _isInternetConnected;
    
}
//Reachability delegate method
-(void)reachabilityChanged:(NSNotification *)notification
{
    Reachability *currentReachability = [notification object];
    
    if ([currentReachability currentReachabilityStatus] != NotReachable)
    {
        _isInternetConnected = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EMSReachableChanged"
                                                            object:self
                                                          userInfo:@{@"startus":@YES}];
    }
    else
    {
        _isInternetConnected = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EMSReachableChanged"
                                                            object:self
                                                          userInfo:@{@"startus":@NO}];
    }
}


-(id)init
{
    
    self = [super init];
    if(!self)
    {
        
        return nil;
        
        
    }
    
    [self setupReachability];
    return self;
    
}
+ (emsReachabilityManager *)sharedInstance
{
    
    static emsReachabilityManager * _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[emsReachabilityManager alloc] init];
        
    });
    
    return _sharedInstance;
}


@end
