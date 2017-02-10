//
//  emsNotificationButton.m
//  Scadaddle
//
//  Created by Roman Bigun on 10/30/15.
//  Copyright © 2015 Roman Bigun. All rights reserved.
//

#import "emsNotificationButton.h"
#import "emsAPIHelper.h"
@implementation emsNotificationButton
{

    UIImageView *badge;
    UILabel *counter;
    
}
/*!
 * @discussion Notifications count changed. Send its count to all loaded instances.
 */
-(void)checkNotifications
{
    //Should be send in the main thread as it changes UI state
    dispatch_async(dispatch_get_main_queue(),^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EMSNotificationCountChanged"
                                                            object:self
                                                          userInfo:@{@"notifCounter":[NSString stringWithFormat:@"%lu",(unsigned long)[Server notifications:@"/all"].count]}];
        
    });
    
    
}
/*!
 * @discussion Display badge if there is more than 0 notifications in the stack
 */
-(void)showBadge:(BOOL)show
{

    badge.alpha = show;
    counter.alpha = show;
    

}
- (void)awakeFromNib {
    
    badge = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-25, self.frame.size.height-25, 25, 25)];
    [badge setImage:[UIImage imageNamed:@"green_circle"]];
    [self addSubview:badge];
    
    counter = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-25, self.frame.size.height-22, 25, 20)];
    counter.textColor = [UIColor whiteColor];
    counter.font = [UIFont boldSystemFontOfSize:12];
    counter.textAlignment = NSTextAlignmentCenter;
    counter.text = @"";
    [self addSubview:counter];
    [self showBadge:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationUpdates:) name:@"EMSNotificationCountChanged" object:nil];
    [self checkNotifications];
    
    
}
/*!
 * @discussion  observer for EMSNotificationCountChanged name
 * Recieves object with notifCounter param inside
 */
-(void)notificationUpdates:(NSNotification *)notification
{
    if([notification.name isEqualToString:@"EMSNotificationCountChanged"])
    {
       counter.text = [NSString stringWithFormat:@"%@",notification.userInfo[@"notifCounter"]];
       int count = [[NSString stringWithFormat:@"%@",notification.userInfo[@"notifCounter"]] intValue];
       count>0?[self showBadge:YES]:[self showBadge:NO];
        
    }
    
    
}
-(void)dealloc
{

    [[NSNotificationCenter defaultCenter] removeObserver:self];

}
@end
