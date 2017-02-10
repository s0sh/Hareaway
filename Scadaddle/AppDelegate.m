//
//  AppDelegate.m
//  Scadaddle
//
//  Created by Roman Bigun on 3/25/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "AppDelegate.h"
////#import "emsLoginVC.h"
#import "Constants.h"
#import "SHConstants.h"
#import "ObjectHandler.h"
#import "emsDeviceDetector.h"
#import "UserDataManager.h"
#import "Stripe.h"
#import "emsGlobalLocationServer.h"
#import "PromotionViewController.h"
#import "emsMainScreenVC.h"
#import "emsRegistrationVC.h"
#import "ActivityDetailViewController.h"
#import "emsProfileVC.h"
#import "NotebookViewController.h"
#import "WelcomeViewController.h"
#import "emsReachabilityManager.h"
#import "FBWebLoginViewController.h"
#define APP_ID @"d310e27dfd04421a9ca87e8a32fd7c44"//Instagram
//#import "Flurry.h"

#define APP_FLURRY_KEY @"JPTP6HV6Z57GTQ9RKCDT"
#define FLURRY_API_ACCESS_KEY @"DGBGN7G9KCKZ2FVTMN5N"

@interface AppDelegate ()

@end

@implementation AppDelegate


/*!
 * @discussion  redirects user to an appropriate page 
 * after push notif has been recieved
 */
-(void)pushNotifHandlers:(NSNotification *)notification
{
    if([notification.name isEqualToString:@"UserProfileFromNotifications"])
    {
        
        
                                          
        emsProfileVC *reg = [[emsProfileVC alloc] initWithNibName:@"emsProfileVC" bundle:nil];
        reg.profileUserId = notification.userInfo[@"userId"];
        self.window.rootViewController = reg;
        [self.window makeKeyAndVisible];
        
    }
    if([notification.name isEqualToString:@"ActivityProfileFromNotifications"])
    {
    
        ActivityDetailViewController *reg = [[ActivityDetailViewController alloc] initWithData:@{@"aId":notification.userInfo[@"aId"]}];
        self.window.rootViewController = reg;
        [self.window makeKeyAndVisible];
       
    }
    if([notification.name isEqualToString:@"NotebookFromNotifications"])
    {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Notebook_6plus" bundle:nil];
        NotebookViewController *notebook = [storyboard instantiateViewControllerWithIdentifier:@"NotebookViewController"];
        self.window.rootViewController = notebook;
        [self.window makeKeyAndVisible];
        
    }
    
    
}
/*!
 * @discussion check if user exists at Scadaddle
 */
-(void)checkForProfile
{

    NSDictionary *profile = [NSDictionary dictionaryWithDictionary:[Server profile]];
    NSLog(@"profile\n%@",profile);
    if(profile){
        [[NSUserDefaults standardUserDefaults] setValue:profile[@"uId"] forKey:@"myid"];
        
    }//ens if
    else{
        if([Server refreshToken]){//Check if the user has registered
            profile = [NSDictionary dictionaryWithDictionary:[Server profile]];
            NSLog(@"profile\n%@",profile);
            
            if(profile){
                [[NSUserDefaults standardUserDefaults] setValue:profile[@"uId"] forKey:@"myid"];
            }//end if
        }//end if
    }//ens else

}
-(void)flurrySessionDidCreateWithInfo:(NSDictionary *)info
{

    NSLog(@"FLURRY \n%@",info);

}
/*!
 * @discussion add needed observers
 */
-(void)addObservers
{

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotifHandlers:) name:@"UserProfileFromNotifications" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotifHandlers:) name:@"NotebookFromNotifications" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotifHandlers:) name:@"ActivityProfileFromNotifications" object:nil];

}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
   
   self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    [self addObservers];
    [UserDataManager sharedManager];
    [FBProfilePictureView class];
    [emsGlobalLocationServer sharedInstance];
    [Stripe setDefaultPublishableKey:StripePublishableKey];
    self.instagram = [[Instagram alloc] initWithClientId:APP_ID
                                                delegate:nil];
    [[Twitter sharedInstance] startWithConsumerKey:@"kGb4ZYZZCFu2vG9zD9CrL3s9N" consumerSecret:@"pmojdkc1wQpoPIBfu9nHXgfTDtsCU2sK1EUvO4tTI2BzkV48ZA"];
    [Fabric with:@[[Twitter sharedInstance]]];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%i",0] forKey:@"defaultInterestSelected"];//REG KEY
    //WELCOME PAGE
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blueColor];
    pageControl.backgroundColor = [UIColor clearColor];

    //Notifications handler
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert |UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    if (launchOptions != nil){
        NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (dictionary != nil)
        {
            [self addMessageFromRemoteNotification:dictionary updateUI:NO];
        }
        
    }
    [self loginIphone];//It is something like an Entry point. It starts every time application loading
    [self.window makeKeyAndVisible];
    
   
    
    return YES;
}

#pragma mark PUSH NOTIFICATIONS DELEGATES
- (void)applicationDidBecomeActive:(UIApplication *)application
{
     //Clear badges
    //application.applicationIconBadgeNumber = 0;
    [Server postUserOnline:YES];
    
}
- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    
    [self addMessageFromRemoteNotification:userInfo updateUI:YES];
    
    
}
/*!
 * @dicussing: This method allows application to waik up and go to needed view according to type of push notiication
 * When new notification comes, NC notify all observers about
 * it[Notification counter also changes in Right Menu Badge]
 * @TODO: Uncoment it if needed.
 * @WARNING: now it is in test mode
 */
- (void)addMessageFromRemoteNotification:(NSDictionary*)userInfo updateUI:(BOOL)updateUI
{
    NSString *alertValue = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
    if (updateUI)
    {
 
            NSDictionary *profile = [NSDictionary dictionaryWithDictionary:[Server profile]];
            NSLog(@"profile\n%@",profile);
            if(profile.count==0)
            {
                [Server refreshToken];
                
            }
            

[[NSNotificationCenter defaultCenter] postNotificationName:@"EMSNotificationCountChanged" object:self
                                      userInfo:@{@"notifCounter":[[userInfo valueForKey:@"aps"] valueForKey:@"badge"]}];
        
            
        
  }
        
    
}
/*!
 * @discussion  to register user device for push notifications 
 * and bind this token with current user by send data to the 
 * Scadaddle server
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    const char *data = [deviceToken bytes];
    NSMutableString *token = [NSMutableString string];
    
    for (int i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    NSLog(@"Did Register for Remote Notifications with Device Token (%@)", token);
    [[UserDataManager sharedManager] saveDeviceToken:token];
    [Server updateDeviceTokenForPushNotifications:token];
}
/*!
 * @discussion  :(((
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Did Fail to Register for Remote Notifications");
    
    NSLog(@"%@, %@", error, error.localizedDescription);
   
    
}
/*!
 * @discussion  restore states of Notebook and Activity pages
 */
- (void)applicationWillResignActive:(UIApplication *)application {
    
    [[NSUserDefaults standardUserDefaults] setValue:@"activity_own" forKey:@"activity"];
    [[NSUserDefaults standardUserDefaults] setValue:@"all" forKey:@"notebook"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    [Server postUserOnline:NO];
}
/*!
 * @discussion  restore states of Notebook and Activity pages
 */
- (void)applicationWillEnterForeground:(UIApplication *)application {
    application.applicationIconBadgeNumber = 0;
   
    [[NSUserDefaults standardUserDefaults] setValue:@"activity_own" forKey:@"activity"];
    [[NSUserDefaults standardUserDefaults] setValue:@"all" forKey:@"notebook"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
/*!
 * @discussion  store states of Notebook and Activity pages
 */
- (void)applicationWillTerminate:(UIApplication *)application {
  
   
    [[NSUserDefaults standardUserDefaults] setValue:@"activity_own" forKey:@"activity"];
    [[NSUserDefaults standardUserDefaults] setValue:@"all" forKey:@"notebook"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}
- (NSDictionary *)parametersDictionaryFromQueryString:(NSString *)queryString {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    NSArray *queryComponents = [queryString componentsSeparatedByString:@"&"];
    
    for(NSString *s in queryComponents) {
        NSArray *pair = [s componentsSeparatedByString:@"="];
        if([pair count] != 2) continue;
        
        NSString *key = pair[0];
        NSString *value = pair[1];
        
        md[key] = value;
    }
    
    return md;
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    [GPPSignIn sharedInstance].clientID = @"2941382890-95uclk7q9quk58rm1vq13pav4omb049f.apps.googleusercontent.com";
    if([GPPURLHandler handleURL:url
              sourceApplication:sourceApplication
                     annotation:annotation]){
        return YES;
    }
    if([FBAppCall handleOpenURL:url sourceApplication:sourceApplication]){
        return YES;
    }
    if([self.instagram handleOpenURL:url]){
        return [self.instagram handleOpenURL:url];
        
    }
    
    if ([[url scheme] isEqualToString:@"myapp"] == NO)
        return NO;
    
    NSDictionary *d = [self parametersDictionaryFromQueryString:[url query]];
    NSString *token = d[@"oauth_token"];
    NSString *verifier = d[@"oauth_verifier"];
    PromotionViewController *vc = (PromotionViewController *)[[self window] rootViewController];
    [vc setOAuthToken:token oauthVerifier:verifier];
    
    return YES;
}

// YOU NEED TO CAPTURE igAPPID:// schema
-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self.instagram handleOpenURL:url];
}
//Test function. It is not used in the APP
-(NSString*)fbAva
{

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:@"http://graph.facebook.com/121626371218107/picture?type=large"]];
    
    NSError *error = nil;
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error) {
        
    }
    NSURL *url = response.URL;
    
    return [url absoluteString];
    
}
-(void)loginIphone{
    
        //Trying to get user profile from the server
        NSDictionary *profile = [NSDictionary dictionaryWithDictionary:[Server profile]];
        [[NSUserDefaults standardUserDefaults] setValue:profile[@"uId"] forKey:@"myid"];
        //Check whether we can update token. If yes - user has already been registered
        if(![Server refreshToken]){
            //Fire Login View
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FBWebLogin" bundle:nil];
            FBWebLoginViewController *notebook = [storyboard instantiateViewControllerWithIdentifier:@"FBWebLogin"];
            self.window.rootViewController = notebook;
            return;
        }
        if([[NSString stringWithFormat:@"%@",profile[@"is_register"]] intValue]==1){
            //User registered but just to be confidence with token validity we refreshes it
            [Server refreshToken];
            //Fire SocialRadar [emsMainScreenVC controller]
            self.navController = [[UINavigationController alloc] initWithRootViewController:[[emsMainScreenVC alloc] init]];
            [self.navController setNavigationBarHidden:YES];
            self.window.rootViewController = self.navController;
            return;
            
        }
        else{
            //There could be a situation that seems like user didnt registered to the Sacadaddle
            //E.g user uses two devices. After login on device 1, server token on device to rejects
            //So need to check whether we can refresh token
            [Server refreshToken];
            profile = [NSDictionary dictionaryWithDictionary:[Server profile]];
            [[NSUserDefaults standardUserDefaults] setValue:profile[@"uId"] forKey:@"myid"];
            //Check is user registered
            if([[NSString stringWithFormat:@"%@",profile[@"is_register"]] intValue]==1){//user registered
                self.window.rootViewController = [[emsMainScreenVC alloc] init];
                return;
                
            }else{//Not registered. Fire WelcomePage
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Welcome" bundle:nil];
                WelcomeViewController *notebook = [storyboard instantiateViewControllerWithIdentifier:@"Welcome"];
                self.window.rootViewController = notebook;
                
            }
            
        }
    
    
    return;
    
    
}




#pragma mark Ipad

-(void)loginIpad{
    
      
}


@end
