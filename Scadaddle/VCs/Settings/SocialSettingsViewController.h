//
//  SocialSettingsViewController.h
//  Scadaddle
//
//  Created by Roman Bigun on 6/16/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Instagram.h"

@interface SocialSettingsViewController : UIViewController<IGSessionDelegate,IGRequestDelegate>
{

    

}
@property(nonatomic,retain)IBOutlet UIButton *gPlusBtn;
@property(nonatomic,retain)IBOutlet UIButton *twBtn;
@property(nonatomic,retain)IBOutlet UIButton *igBtn;
@property (strong, nonatomic) Instagram *instagram;
@property (strong, nonatomic) NSArray *data;
@property BOOL isInstagramLoggedIn;
-(void)instagramLogin;
-(NSArray*)getInstagramPosts;

@end
