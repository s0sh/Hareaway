//
//  FBWebLoginViewController.m
//  Scadaddle
//
//  Created by Roman Bigun on 11/4/15.
//  Copyright © 2015 Roman Bigun. All rights reserved.
//

#import "FBWebLoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <FacebookSDK/FBAccessTokenData.h>
#import <Accounts/ACAccountStore.h>
#import "WelcomeViewController.h"
#import "emsMainScreenVC.h"
#import "emsAPIHelper.h"
@interface FBWebLoginViewController ()

@end

@implementation FBWebLoginViewController

#define PERMISSIONS [NSArray arrayWithObjects:@"email",@"manage_pages",@"user_birthday",@"user_likes",@"user_location",@"user_events",@"user_friends",@"user_photos",@"publish_actions",@"manage_notifications",nil]

@synthesize accessToken,webview,FbActive;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Removeing the UIWebview Cookies
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"server_token"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"local_user_info"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
}
/*!
 * @discussion Login to facebook
 */
-(IBAction)fbLoginPage:(UIButton *)sender1
{
    
    
    NSString   *facebookClientID =[FBSession activeSession].appID;
    NSString   *redirectUri = @"http://www.facebook.com/connect/login_success.html";
    NSString  *extended_permissions=@"email,manage_pages,user_birthday,user_likes,user_location,user_events,user_friends,user_photos,publish_actions,manage_notifications";
    
    NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/oauth/authorize?client_id=%@&redirect_uri=%@&scope=%@&type=user_agent&display=touch", facebookClientID, redirectUri, extended_permissions];
    NSURL *url = [NSURL URLWithString:url_string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    CGRect webFrame =[self.view frame];
    webFrame.origin.y = 0;
    UIWebView *aWebView = [[UIWebView alloc] initWithFrame:webFrame];
    [aWebView setDelegate:self];
    self.webview = aWebView;
    self.FbActive = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.FbActive.color=[UIColor darkGrayColor];
    self.FbActive.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [self.FbActive startAnimating];
    [self.webview setOpaque:NO];
    self.webview.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default-568h.png"]];
    [self.webview loadRequest:request];
    [self.webview addSubview:self.FbActive];
    [self.view addSubview:self.webview];
    
    
}
/*!
 * @discussion Facebook Login Callback.
 */
- (void)webViewDidFinishLoad:(UIWebView *)_webView {
    
    /*!
     * Since there's some server side redirecting involved, this method/function will be called several times
     * we're only interested when we see a url like:  http://www.facebook.com/connect/login_success.html#access_token=..........
     */
    
    //get the url string
    [self.FbActive stopAnimating];
    NSString *url_string = [((_webView.request).URL) absoluteString];
    
    //looking for "access_token="
    NSRange access_token_range = [url_string rangeOfString:@"access_token="];
    
    //looking for "error_reason=user_denied"
    NSRange cancel_range = [url_string rangeOfString:@"error_reason=user_denied"];
    
    //it exists?  coolio, we have a token, now let's parse it out....
    if (access_token_range.length > 0) {
        
        //we want everything after the 'access_token=' thus the position where it starts + it's length
        int from_index = access_token_range.location + access_token_range.length;
        NSString *access_token = [url_string substringFromIndex:from_index];
        
        //finally we have to url decode the access token
        access_token = [access_token stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        //remove everything '&' (inclusive) onward...
        NSRange period_range = [access_token rangeOfString:@"&"];
        
        //move beyond the .
        access_token = [access_token substringToIndex:period_range.location];
        [[NSUserDefaults standardUserDefaults] setObject:access_token forKey:@"FBToken"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //store our request token....
        self.accessToken = access_token;
        
        //remove our window
        //      UIWindow* window = [UIApplication sharedApplication].keyWindow;
        //      if (!window) {
        //          window = [[UIApplication sharedApplication].windows objectAtIndex:0];
        //      }
        
        
        
        
        
        //tell our callback function that we're done logging in :)
        //      if ( (callbackObject != nil) && (callbackSelector != nil) ) {
        //          [callbackObject performSelector:callbackSelector];
        //      }
        
        //the user pressed cancel
        
    }
    else if (cancel_range.length > 0)
    {
        //remove our window
        //      UIWindow* window = [UIApplication sharedApplication].keyWindow;
        //      if (!window) {
        //          window = [[UIApplication sharedApplication].windows objectAtIndex:0];
        //      }
        
        [self.webview removeFromSuperview];
        self.webview=nil;
        
        //tell our callback function that we're done logging in :)
        //      if ( (callbackObject != nil) && (callbackSelector != nil) ) {
        //          [callbackObject performSelector:callbackSelector];
        //      }
        
    }
    [self getuserdetailes];
    
}
-(void)openWelcomePage
{
    
    /*!
     - Opens only once before registration process
     **/
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Welcome" bundle:nil];
    WelcomeViewController *notebook = [storyboard instantiateViewControllerWithIdentifier:@"Welcome"];
    [self presentViewController:notebook animated:YES completion:^{
        
    }];
    
}
/*!
 * @discussion Get Facebook user data and store his data into Defaults
 **/
-(void)getuserdetailes
{
    NSString *action=@"me";
    NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/%@?", action];
    //tack on any get vars we have...
    NSDictionary *get_vars=nil;
    
    if ( (get_vars != nil) && ([get_vars count] > 0) ) {
        
        NSEnumerator *enumerator = [get_vars keyEnumerator];
        NSString *key;
        NSString *value;
        while ((key = (NSString *)[enumerator nextObject])) {
            
            value = (NSString *)[get_vars objectForKey:key];
            url_string = [NSString stringWithFormat:@"%@%@=%@&", url_string, key, value];
            
        }//end while
    }//end if
    
    if (accessToken != nil)
    {
        
        //now that any variables have been appended, let's attach the access token....
        url_string = [NSString stringWithFormat:@"%@access_token=%@", url_string, self.accessToken];
        url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"%@",url_string);
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url_string]];
        
        NSError *err;
        NSURLResponse *resp;
        NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&err];
        NSString *stringResponse = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"%@",stringResponse);
        NSError* error;
        NSDictionary *FBResResjson = [NSJSONSerialization
                                      JSONObjectWithData:response//1
                                      options:kNilOptions
                                      error:&error];
        
        [[NSUserDefaults standardUserDefaults] setObject:FBResResjson forKey:@"local_user_info"];
        [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"FBToken"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"local_user_info"]);
        [self fbLoginToServer];
        
        NSLog(@"%@",FBResResjson);
        
        
    }
}

-(void)fbLoginToServer
{
    
    NSDictionary *local = [[NSUserDefaults standardUserDefaults] objectForKey:@"local_user_info"];
    /*!
     - Login to server with minimum data. At this point server creates 
     gost user. This is just matrix for further registration.
     **/
    [Server loginToServerWithFacebookToken:self.accessToken andUserID:local[@"id"]];
    [self manageLoading];
    
}
-(void)manageLoading
{
    
    /*!
     - Check whether the user is registered or not by calling 
     'refreshToken'
     **/
    [Server refreshToken];
    /*!
     - Try to get user data from server
     **/
    NSDictionary *profile = [NSDictionary dictionaryWithDictionary:[Server profile]];
    NSLog(@"profile\n%@",profile);
    /*!
     @note that user (gost) could be created after login but not registered
     yet, so it needs to check the flag 'is_registered'. If user registered 
     value will be equal 1
     **/
    if([[NSString stringWithFormat:@"%@",profile[@"is_register"]] intValue]==0)
    {
        /*!
         - User didnt register - open Welcome page
         **/
        [self openWelcomePage];
        [self.webview removeFromSuperview];
        self.webview=nil;
        
    }
    else
    {
        /*!
         - Store my ID for further use
         **/
        [[NSUserDefaults standardUserDefaults] setValue:profile[@"uId"] forKey:@"myid"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        /*!
         - User registered. But just for case we refreshes token again 
         to be sure the app will work properly
         **/
        if([Server refreshToken])
        {
            /*!
             - Redirect registered user to Main Page [SocialRadar]
             **/
            [self presentViewController:[[emsMainScreenVC alloc] init] animated:YES completion:^{
                [self.webview removeFromSuperview];
                self.webview=nil;
            }];
            
            
        }
        
    }
    
    
}


@end
