//
//  emsServerErrorHandler.h
//  Scadaddle
//
//  Created by Roman Bigun on 7/30/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface emsServerErrorHandler : NSObject
+ (emsServerErrorHandler *)sharedInstance;
/*!
 * @return: Success 1/0
 * @params 'respond' data returned in respond
 * @todo use it in emsApiHelper for request
 */
-(BOOL)checkSuccessfull:(NSDictionary*)respond;
@end
