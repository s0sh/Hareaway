//
//  emsChatVC.h
//  Fishy
//
//  Created by developer on 21/01/15.
//  Copyright (c) 2015 ErmineSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface emsChatVC : UIViewController




/*
 * @return: User object dictionary
*/
- (id)initDictionary:(NSDictionary *)dictionary;

/*
 *  @discussion Method called to clean class instances
 */
-(void)clearData;
@end
