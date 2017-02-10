//
//  emsRightMenuVC.h
//  Scadaddle
//
//  Created by developer on 14/04/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol rightMenuDelegate;
@class User,Notification;

typedef NS_ENUM(NSInteger, NotificationTabs)
{
    all,
    tv,
    s_system,
    chat,
    notebook

};


@interface emsRightMenuVC : UIViewController
{

    int currentType;

}

@property (nonatomic, weak)IBOutlet UIImageView *bg;
@property (nonatomic, weak) UIViewController <rightMenuDelegate>* delegate;
-(id)initWithDelegate:(UIViewController *)delegateVC;
@end
@protocol rightMenuDelegate <NSObject>
-(void)userSelected:(User*)user;
@required
-(IBAction)showLeftMenu;
-(void)notificationSelected:(Notification*)notification ;
@end




