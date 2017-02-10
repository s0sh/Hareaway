//
//  emsLoginVC.m
//  Scadaddle
//
//  Created by developer on 30/03/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsLoginVC.h"
#import "emsRegistrationVC.h"
#import "Constants.h"
#import "User.h"
#import "Notification.h"
#import "emsMainScreenVC.h"
#import "emsProfileVC.h"
#import "DSViewController.h"
#import "emsDeviceManager.h"
#import "SocialsManager.h"
#import "UserDataManager.h"
#import "WelcomeViewController.h"
#import "emsRegistrationVC.h"
#import "emsGlobalLocationServer.h"
#import <FacebookSDK/FacebookSDK.h>
#define FB_APP_ID @""

#define PERMISSIONS [NSArray arrayWithObjects:@"email",@"manage_pages",@"user_birthday",@"user_likes",@"user_location",@"user_events",@"user_friends",@"user_photos",@"publish_actions",@"manage_notifications",nil]

@interface emsLoginVC (){

 IBOutlet UIView *leftMenu;
 IBOutlet UIView *RcontentView;
 IBOutlet UIView *rightMenu;
 IBOutlet UIView *contentView;
 FBLoginView *loginView;
}

@property (nonatomic, weak) IBOutlet UIImageView *bgView;
@property (nonatomic, weak) IBOutlet UIImageView *bgViewR;

@end

@implementation emsLoginVC



-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [emsGlobalLocationServer sharedInstance];//Updates location data
    if([[FBSession activeSession] isOpen])
    {
        
        NSLog(@"User is logged in with permission:\n");
        
        NSLog(@"%@",[[FBSession activeSession] permissions]);
        
        loginView = [[FBLoginView alloc] initWithReadPermissions:PERMISSIONS];
        loginView.delegate = self;
        loginView.frame = CGRectOffset(loginView.frame,(self.view.center.x - (loginView.frame.size.width / 2)),5);
        loginView.center = self.view.center;
        [self.view addSubview:loginView];
        
        
    }
    else
    {
        loginView = [[FBLoginView alloc] initWithReadPermissions:PERMISSIONS];
        loginView.delegate = self;
        loginView.frame = CGRectOffset(loginView.frame,(self.view.center.x - (loginView.frame.size.width / 2)),5);
        loginView.center = self.view.center;
        [self.view addSubview:loginView];
        
    }
    
    
}
#pragma mark FACEBOOK DELEGATE METHODS
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView1 user:(id<FBGraphUser>)user1
{
    
        [[NSUserDefaults standardUserDefaults] setObject:user1 forKey:@"local_user_info"];
        [[NSUserDefaults standardUserDefaults] setObject:[FBSession activeSession].accessTokenData.accessToken forKey:@"FBToken"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"local_user_info"]);
        [self fbLoginToServer];
    
}

// Implement the loginViewShowingLoggedInUser: delegate method to modify your app's UI for a logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    
}

// Implement the loginViewShowingLoggedOutUser: delegate method to modify your app's UI for a logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
   
    
}

// You need to override loginView:handleError in order to handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures since that happen outside of the app.
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
     //Load native login buttons
     
     @note Switched off in the SocialManager
     
     [sm googlePlusButton:self];
     [sm instagramLogin];
     [sm facebookLoginInsertToView:self];
     [sm twitterButton:self];
     
     */
   
}
/*!
 @discussion Opens when user is not registered. First Time Opening
 **/
-(void)openWelcomePage
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Welcome" bundle:nil];
    WelcomeViewController *notebook = [storyboard instantiateViewControllerWithIdentifier:@"Welcome"];
    [self presentViewController:notebook animated:YES completion:^{
        
    }];
    
}
/*!
 @discussion Get Facebook user data and use it for preregister
 @note Server use this information to create preregistered user 
 'Gost' and generate guest serverToken for this user
 **/
-(void)fbLoginToServer
{
    NSDictionary *local = [[NSUserDefaults standardUserDefaults] objectForKey:@"local_user_info"];
    [Server loginToServerWithFacebookToken:[FBSession activeSession].accessTokenData.accessToken andUserID:local[@"id"]];
    [self manageLoading];
}

-(void)manageLoading
{

    [loginView removeFromSuperview];
    [Server refreshToken];
    NSDictionary *profile = [NSDictionary dictionaryWithDictionary:[Server profile]];
    NSLog(@"profile\n%@",profile);
    
    if([[NSString stringWithFormat:@"%@",profile[@"is_register"]] intValue]==0){
        [self openWelcomePage];//still guest
    }
    else{
        //user registered
        [[NSUserDefaults standardUserDefaults] setValue:profile[@"uId"] forKey:@"myid"];
        if([Server refreshToken])
        {
            //Redirect the user to SocialRadar
            [self presentViewController:[[emsMainScreenVC alloc] init] animated:YES completion:^{
                
            }];
            
            
        }
        
    }


}
- (void)startLocating:(NSNotification *)notification {
    
    if([[notification name] isEqualToString:@"facebookLoginSuccessful"])
    {
        [loginView removeFromSuperview];
        
        [Server refreshToken];
        NSDictionary *profile = [NSDictionary dictionaryWithDictionary:[Server profile]];
        NSLog(@"profile\n%@",profile);
        
        if([[NSString stringWithFormat:@"%@",profile[@"is_register"]] intValue]==0){
            [self openWelcomePage];//guest
        }
        else
        {
            //user registered
            [[NSUserDefaults standardUserDefaults] setValue:profile[@"uId"] forKey:@"myid"];
            if([Server refreshToken])
            {
                
                [self presentViewController:[[emsMainScreenVC alloc] init] animated:YES completion:^{
                    
                }];
                
                
            }
        
        }
        
        
        
        
    }
  
    
}
-(void)dealloc{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
