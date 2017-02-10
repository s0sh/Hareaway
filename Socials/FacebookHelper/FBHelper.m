//
//  FBHelper.m
//  Scadaddle
//
//  Created by Roman Bigun on 4/7/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "FBHelper.h"
#import "SocialsStoreCoordinator.h"

#define FB_APP_ID @"1630390213860644"

#define PERMISSIONS [NSArray arrayWithObjects:@"email",@"manage_pages",@"user_birthday",@"user_likes",@"user_location",@"user_events",@"user_friends",@"user_photos",@"publish_actions",@"manage_notifications",nil]

@implementation FBHelper



@synthesize userID;
-(id)init
{
    
    self = [super init];
    if(!self)
    {
        
        return nil;
   
        
    }
    _accountStore = [[ACAccountStore alloc] init];
    self.user = [NSDictionary dictionaryWithDictionary:[[SocialsStoreCoordinator socialDataForType:kSocialTypeFacebook] objectForKey:@"data"]];
    return  self;
    
}
+ (FBHelper *)sharedInstance
{
    
    static FBHelper * _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[FBHelper alloc] init];
        
    });
    
    return _sharedInstance;
}
-(void)facebookInit
{
    
    [FBProfilePictureView class];
    
}
-(NSString *)FBuserToken
{

    return [FBSession activeSession].accessTokenData.accessToken;

}

-(void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:  (NSError *)error
{
    NSLog(@"FB session state :\n %lu",session.state);
}
-(void)logout
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/me/permissions"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *requestFields = @"";
    requestFields = [requestFields stringByAppendingFormat:@"access_token=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"FBToken"]];
    requestFields = [requestFields stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *requestData = [requestFields dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestData;
    request.HTTPMethod = @"DELETE";
    request.timeoutInterval = kPfxNetworkDelay;
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *responseData1 = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString* responseString = [[NSString alloc] initWithData:responseData1 encoding:NSUTF8StringEncoding];
    
    if (error == nil && response.statusCode == 200)
    {
        
    }

}
- (void)fbDidLogout {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:nil forKey:@"facebook-accessToken"];
    [prefs setObject:nil forKey:@"facebook-expirationDate"];
    [prefs synchronize];
}
-(void)clearFBCookies
{

    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* facebookCookies = [cookies cookiesForURL:
                                [NSURL URLWithString:@"http://m.facebook.com"]];
    for (NSHTTPCookie* cookie in facebookCookies) {
        [cookies deleteCookie:cookie];
    }

}
-(void)fasebookLogout
{
    
   [self logout];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:nil forKey:@"facebook-accessToken"];
    [prefs setObject:nil forKey:@"facebook-expirationDate"];
    [prefs synchronize];
    
    
    [FBSession.activeSession closeAndClearTokenInformation];
    [FBSession.activeSession close];
    [FBSession setActiveSession:nil];
    [self clearFBCookies];
    
    [self.profilePictureView setProfileID:nil];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"FBToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    ACAccountType *accountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSArray *iOSAccounts = [_accountStore accountsWithAccountType:accountType];
    
    if([iOSAccounts count] == 1)
    {
        ACAccount *account = [iOSAccounts lastObject];
        [_accountStore removeAccount:account withCompletionHandler:^(BOOL success, NSError *error) {
            
            if (success) {
                NSLog(@"Account was removed!");
            }
            else {

            }
        }];
    }
   
    
    
   
}
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    
    [self.profilePictureView setProfileID:nil];
}
-(void)facebookLoginWithoutAddingButton
{

}
-(BOOL)FBLogin:(UIViewController*)viewController
{
  
   
   if([[FBSession activeSession] isOpen])
   {
   
       NSLog(@"User is logged in with permission:\n");
       NSLog(@"%@",[[FBSession activeSession] permissions]);
       
       self.user = [SocialsStoreCoordinator socialDataForType:kSocialTypeFacebook][@"data"];
       NSLog(@"And token:\n%@",_session.accessTokenData.accessToken);
       _loginView = [[FBLoginView alloc] initWithReadPermissions:PERMISSIONS];
       _loginView.delegate = self;
       _loginView.frame = CGRectOffset(_loginView.frame,(viewController.view.center.x - (_loginView.frame.size.width / 2)),5);
       _loginView.center = viewController.view.center;
       [viewController.view addSubview:_loginView];
       
       return YES;
      
   }
    else
    {
       
        _loginView = [[FBLoginView alloc] initWithReadPermissions:PERMISSIONS];
        _loginView.delegate = self;
        _loginView.frame = CGRectOffset(_loginView.frame,(viewController.view.center.x - (_loginView.frame.size.width / 2)),5);
        _loginView.center = viewController.view.center;
        [viewController.view addSubview:_loginView];
        
    }
   
    return NO;
}
#pragma mark FACEBOOK DELEGATE METHODS

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user1
{
    
    loginView.frame = CGRectOffset(loginView.frame, -500, 5);
    
    self.profilePictureView.profileID = user1.id;
    if([SocialsStoreCoordinator checkSocialExistanceForType:kSocialTypeFacebook])
    {
        
        NSLog(@"Fb user Logged In\n%@",[SocialsStoreCoordinator socialDataForType:kSocialTypeFacebook]);
        self.user = [[SocialsStoreCoordinator socialDataForType:kSocialTypeFacebook] objectForKey:@"data"];
        
    }
    else
    {
        
        Profiles *userProfile = [[Profiles alloc] init];
        userProfile.name = user1.name;
        userProfile.fbId = user1.id;
        userProfile.userActivities = self.userActivities;
        userProfile.userInterests = self.userInterests;
        userProfile.userBirthday = user1.birthday;
        userProfile.email = self.email;
        
        [Core addObjectToDB:userProfile];//Initial user information. Now needs to register current user as a Scadaddle user and get full user profile with login string
        
        [[NSUserDefaults standardUserDefaults] setObject:user1 forKey:@"local_user_info"];
        [[NSUserDefaults standardUserDefaults] setObject:[FBSession activeSession].accessTokenData.accessToken forKey:@"FBToken"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"local_user_info"]);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"facebookLoginSuccessful" object:self userInfo:[NSDictionary dictionaryWithObject:userProfile forKey:@"userProfile"]];
    
    }
    
    self.userID = [NSString stringWithFormat:@"%@",user1.id];
    
}
-(void)fbLoginToServer
{

    NSDictionary *local = [[NSUserDefaults standardUserDefaults] objectForKey:@"local_user_info"];
    [Server loginToServerWithFacebookToken:[FBSession activeSession].accessTokenData.accessToken andUserID:local[@"id"]];

}
-(NSString*)loggedInUserFBId
{

    return self.userID;

}
// Implement the loginViewShowingLoggedInUser: delegate method to modify your app's UI for a logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    
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

-(NSString*)getAvatarURLWithID:(NSString*) userID1
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",userID1]]];
    
    NSError *error = nil;
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        return nil;
    }
    NSURL *url = response.URL;
    NSString* urlStr = [url absoluteString];
    return urlStr;
   

}

+(NSArray*)getUserAlbums
{
    __block NSArray *photos = [NSArray new];
    
    NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/me/albums?access_token=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"FBToken"]] ;
    
    NSMutableURLRequest *requestURL = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                              cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                          timeoutInterval:60.0];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:requestURL returningResponse:nil error:nil];
    if(responseData)
    {
        NSError* error = nil;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:kNilOptions
                              error:&error];
        
        photos = json[@"data"];
        NSLog(@"Got response on GetAlbums: %@", photos);
        
    }
    
    return  photos;

}
+(NSArray*)getNotifications
{
    __block NSArray *photos = [NSArray new];
    
    
    NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/me/notifications?access_token=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"FBToken"]] ;
    
    NSMutableURLRequest *requestURL = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                              cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                          timeoutInterval:60.0];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:requestURL returningResponse:nil error:nil];
    if(responseData)
    {
        NSError* error = nil;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:kNilOptions
                              error:&error];
        
        photos = json[@"data"];
        NSLog(@"Got response on Notifications: %@", photos);
        
    }
    
    return  photos;
    
}

+(NSArray*)getUserActivities
{
    __block NSArray *photos = [NSArray new];
    
    
    NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/me/events?access_token=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"FBToken"]] ;
    
    NSMutableURLRequest *requestURL = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                              cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                          timeoutInterval:60.0];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:requestURL returningResponse:nil error:nil];
    if(responseData)
    {
        NSError* error = nil;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:kNilOptions
                              error:&error];
        
        photos = json[@"data"];
        NSLog(@"Got response on GetAlbums: %@", photos);
        
    }
    
    return  photos;
    
}
//739628739432624
+(NSString*)getAlnumCoverImage:(NSString*)albumId
{

    
    __block NSString *photos = [NSString new];
    
    
    NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=album&access_token=%@",albumId,[[NSUserDefaults standardUserDefaults] objectForKey:@"FBToken"]] ;
    
    NSMutableURLRequest *requestURL = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                              cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                          timeoutInterval:60.0];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:requestURL returningResponse:nil error:nil];
    if(responseData)
    {
        NSError* error = nil;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:kNilOptions
                              error:&error];
        
        photos = json[@"photos"][@"data"];
        NSLog(@"Got response on photo in album: %@", photos);
        
    }
    
    return  photos;
    
   
}
+(NSArray*)getUserPhotosInAlbumsWithId:(NSString*)Id
{

    __block NSArray *photos = [NSArray new];
    
    
    NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/%@?fields=photos&access_token=%@",Id,[[NSUserDefaults standardUserDefaults] objectForKey:@"FBToken"]] ;
    
    NSMutableURLRequest *requestURL = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                              cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                          timeoutInterval:60.0];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:requestURL returningResponse:nil error:nil];
    if(responseData)
    {
        NSError* error = nil;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:kNilOptions
                              error:&error];
        
        photos = json[@"photos"][@"data"];
        NSLog(@"Got response on photo in album: %@", photos);
        
    }
    
    return  photos;
}

+(NSArray*)currentUserInterests
{
    NSArray *data = [NSArray new];
    NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/me/likes?access_token=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"FBToken"]] ;
    
    NSMutableURLRequest *requestURL = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                              cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                          timeoutInterval:60.0];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:requestURL returningResponse:nil error:nil];
    if(responseData)
    {
        NSError* error = nil;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:kNilOptions
                              error:&error];
        
        data = [NSArray arrayWithArray:json[@"data"]];
        NSLog(@"Got response on Interests: %@", data);
        
    }
    
    return data;
    
}

+(NSArray*)currentUserFriends
{
    __block NSArray *unsortedFriends = [NSArray new];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"id,name,picture",@"fields",nil];
    
    [FBRequestConnection startWithGraphPath:@"me/friends"
                                 parameters:params
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if(error == nil) {
                                  FBGraphObject *response = (FBGraphObject*)result;
                                  unsortedFriends = [response objectForKey:@"data"];
                                  NSLog(@"Friends: %@",[response objectForKey:@"data"]);
                              }
                          }];
    return unsortedFriends;
    
}
+(NSArray*)getUserInterestWithId:(NSString*)Id
{
    
    __block NSArray *feed = [NSArray new];
    
    
    NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/%@?fields=feed&access_token=%@",Id,[[NSUserDefaults standardUserDefaults] objectForKey:@"FBToken"]] ;
    
    NSMutableURLRequest *requestURL = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                              cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                          timeoutInterval:60.0];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:requestURL returningResponse:nil error:nil];
    if(responseData)
    {
        NSError* error = nil;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:kNilOptions
                              error:&error];
        
        feed = json[@"feed"][@"data"];
        NSLog(@"Got response on feed from user Interests: %@", feed);
        
    }
    
    return  feed;
    
    
}
-(void)createEvent:(NSString*)userId
{

    NSMutableDictionary *postParams = [[NSMutableDictionary alloc]
                                       initWithObjectsAndKeys:
                                       @"Test",@"Test",
                                       @"2015-11-11", @"start_time",
                                       nil];
    
    [FBRequestConnection
     startWithGraphPath:[NSString stringWithFormat:@"%@/events?access_token=%@",userId,[[NSUserDefaults standardUserDefaults] objectForKey:@"FBToken"]]
     parameters:postParams
     HTTPMethod:@"POST"
     completionHandler:^(FBRequestConnection *connection,
                         id result,
                         NSError *error) {
         if (error) {
             NSLog(@"Error: %@", result);
             
         } else {
             NSLog(@"Success: %@", result);
             
             
         }
         
         
     }];

}
@end
