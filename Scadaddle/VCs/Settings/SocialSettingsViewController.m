//
//  SocialSettingsViewController.m
//  Scadaddle
//
//  Created by Roman Bigun on 6/16/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "SocialSettingsViewController.h"
#import "SocialsManager.h"
#import "emsRightMenuVC.h"
#import "emsLeftMenuVC.h"
//#import "emsLoginVC.h"
#import <Accounts/ACAccountStore.h>
#import "emsScadProgress.h"
#import "FBWebLoginViewController.h"
#define INSTA_ADD_ID @"d310e27dfd04421a9ca87e8a32fd7c44"

@interface SocialSettingsViewController (){
emsScadProgress * subView;
}
@property (nonatomic, strong) ACAccountStore *accountStore;
@end

@implementation SocialSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _accountStore = [[ACAccountStore alloc] init];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(manipulations:) name:@"GooglePlusLoginSuccessful" object:nil];
    
    //Check for Signed/Unsigned user status in G+
    
    GPlusHelper *gpHelper = [GPlusHelper new];
    if([gpHelper checkUserSighedIn]){
        [self.gPlusBtn setBackgroundImage:[UIImage imageNamed:@"g+_log_out"] forState:UIControlStateNormal];
        [self.gPlusBtn addTarget:self action:@selector(gplusLogout) forControlEvents:UIControlEventTouchUpInside];
    }
    else{
        [self.gPlusBtn setBackgroundImage:[UIImage imageNamed:@"g+_log_in"] forState:UIControlStateNormal];
        [self.gPlusBtn addTarget:self action:@selector(gPlusLogin) forControlEvents:UIControlEventTouchUpInside];
    }
    [Fabric with:@[TwitterKit]];
    //Check for Signed/Unsigned user status in TWITTER
    
    if([[Twitter sharedInstance] session]){
        [self.twBtn setBackgroundImage:[UIImage imageNamed:@"tw_log_out"] forState:UIControlStateNormal];
        self.twBtn.alpha=1;
        [self.twBtn addTarget:self action:@selector(twLogout) forControlEvents:UIControlEventTouchUpInside];
        [self twitterUser:[[[Twitter sharedInstance] session] userID]];
    }else{
        self.twBtn.alpha=1;
        [self.twBtn setBackgroundImage:[UIImage imageNamed:@"tw_log_in"] forState:UIControlStateNormal];
        [self.twBtn addTarget:self action:@selector(twLogin) forControlEvents:UIControlEventTouchUpInside];
        [self twitterUser:[[[Twitter sharedInstance] session] userID]];
    }
    //Check for Signed/Unsigned user status in INSTAGRAM
    
    NSString *ia_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"instagram_access_token"];
    self.instagram = [[Instagram alloc] initWithClientId:INSTA_ADD_ID delegate:self];
    self.instagram.sessionDelegate = self;
    if(ia_token.length>10 && [[self getPostsWithToken:ia_token andUserID:@"" andCount:1] count]>0){
        [self.igBtn setBackgroundImage:[UIImage imageNamed:@"ig_log_out"] forState:UIControlStateNormal];
    }
    
}
/*!
 * @discussion  Logout from G+
 */
-(void)gplusLogout
{

    GPlusHelper *gpHelper = [GPlusHelper new];
    [gpHelper googlePlusLogout];
    
    if([gpHelper checkUserSighedIn]){
        [self.gPlusBtn setBackgroundImage:[UIImage imageNamed:@"g+_log_out"] forState:UIControlStateNormal];
        [self.gPlusBtn addTarget:self action:@selector(gplusLogout) forControlEvents:UIControlEventTouchUpInside];
    }
    else{
        [self.gPlusBtn setBackgroundImage:[UIImage imageNamed:@"g+_log_in"] forState:UIControlStateNormal];
        [self.gPlusBtn addTarget:self action:@selector(gPlusLogin) forControlEvents:UIControlEventTouchUpInside];
    }
    
}
/*!
 * @discussion  Some kind of callbacks after login to socials which
 * couldnt be handeled here
 */
-(void)manipulations:(NSNotification *)notification
{
    NSString * action = notification.userInfo[@"provider"];
    if([action isEqualToString:@"gplus"]){
        [self.gPlusBtn setBackgroundImage:[UIImage imageNamed:@"g+_log_out"] forState:UIControlStateNormal];
        [self.gPlusBtn addTarget:self action:@selector(gplusLogout) forControlEvents:UIControlEventTouchUpInside];
    }
    if([action isEqualToString:@"instagram"]){
        [self.igBtn setBackgroundImage:[UIImage imageNamed:@"ig_log_out"] forState:UIControlStateNormal];
     }
    
}
/*!
 * @discussion  Login to G+
 */
-(IBAction)gPlusLogin
{
    GPlusHelper *gPlus = [[GPlusHelper alloc] init];
    [gPlus googlePlusLogin];
}
/*!
 * @discussion  Facebook Logout
 */
-(IBAction)fbLogout
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FBWebLogin" bundle:nil];
    FBWebLoginViewController *notebook = [storyboard instantiateViewControllerWithIdentifier:@"FBWebLogin"];
    [self presentViewController:notebook animated:YES completion:^{
        
    }];

}
/*!
 * @discussion  Login to Twitter
 */
-(IBAction)twLogin
{

    [[Twitter sharedInstance] logInWithCompletion:^
     (TWTRSession *session, NSError *error) {
         if (session) {
             NSLog(@"signed in as %@", [session userName]);
             [self twitterUser:[session userID]];
             [self.twBtn setBackgroundImage:[UIImage imageNamed:@"tw_log_out"] forState:UIControlStateNormal];
             self.twBtn.alpha=1;
             [self.twBtn removeTarget:self action:@selector(twLogin) forControlEvents:UIControlEventTouchUpInside];
             [self.twBtn addTarget:self action:@selector(twLogout) forControlEvents:UIControlEventTouchUpInside];
             
         } else {
             NSLog(@"error: %@", [error localizedDescription]);
             
             [self.twBtn removeTarget:self action:@selector(twLogout) forControlEvents:UIControlEventTouchUpInside];
             [self.twBtn addTarget:self action:@selector(twLogin) forControlEvents:UIControlEventTouchUpInside];
             [self.twBtn setBackgroundImage:[UIImage imageNamed:@"tw_log_in"] forState:UIControlStateNormal];
         }
     }];
}
/*!
 * @discussion  Logout from Twitter
 */
-(IBAction)twLogout
{
    [[Twitter sharedInstance] logOut];
    ACAccountType *accountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
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
        
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
    for (NSHTTPCookie *cookie in cookies)
    {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    [self.twBtn setBackgroundImage:[UIImage imageNamed:@"tw_log_in"] forState:UIControlStateNormal];
    self.twBtn.alpha=1;
    [self.twBtn removeTarget:self action:@selector(twLogout) forControlEvents:UIControlEventTouchUpInside];
    [self.twBtn addTarget:self action:@selector(twLogin) forControlEvents:UIControlEventTouchUpInside];
    [self twitterUser:[[[Twitter sharedInstance] session] userID]];
}
/*!
 * @discussion  Get Logged in user profile data [Twitter]
 */
-(void)twitterUser:(NSString*)userId
{
    if(userId!=nil)
    {
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/account/verify_credentials.json";
    NSDictionary *params = @{@"id" : userId};
    NSError *clientError;
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient]
                             URLRequestWithMethod:@"GET"
                             URL:statusesShowEndpoint
                             parameters:params
                             error:&clientError];
    
    if (request) {
        [[[Twitter sharedInstance] APIClient]
         sendTwitterRequest:request
         completion:^(NSURLResponse *response,
                      NSData *data,
                      NSError *connectionError) {
             if (data) {
                 // handle the response data e.g.
                 NSError *jsonError;
                 NSDictionary *json = [NSJSONSerialization
                                       JSONObjectWithData:data
                                       options:0
                                       error:&jsonError];
                 NSLog(@"Twitter User :%@",json);
                 //save user data to DB
                 [SocialsStoreCoordinator storeDataForSocialType:kSocialTypeTwitter andData:json];
                 
             }
             else {
                 NSLog(@"Error: %@", connectionError);
             }
         }];
    }
    else {
        NSLog(@"Error: %@", clientError);
    }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - IGRequestDelegate
/*!
 * @discussion  Instagram workers
 */
-(void)igDidLogout
{
    
    NSLog(@"Instagram did logout");
    // remove the accessToken
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"instagram_access_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.igBtn setBackgroundImage:[UIImage imageNamed:@"ig_log_in"] forState:UIControlStateNormal];
    
    self.isInstagramLoggedIn = NO;
}

-(void)igDidNotLogin:(BOOL)cancelled
{
    NSLog(@"Instagram did not login");
    // remove the accessToken
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"instagram_access_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.isInstagramLoggedIn = NO;
}
-(void)igSessionInvalidated
{
    NSLog(@"Instagram session was invalidated");
}

- (void)request:(IGRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Instagram did fail: %@", error);
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)request:(IGRequest *)request didLoad:(id)result
{
    
    NSLog(@"Instagram did load: %@", result);
    self.data = (NSArray*)[result objectForKey:@"data"];
    
}

-(void)instagramLogin
{
    NSString *ia_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"instagram_access_token"];
    if(ia_token.length>10 && [[self getPostsWithToken:ia_token andUserID:@"" andCount:1] count]>0){
        [self.instagram logout];
        [self.igBtn setBackgroundImage:[UIImage imageNamed:@"ig_log_in"] forState:UIControlStateNormal];
    }else{
        [self.instagram authorize:[NSArray arrayWithObjects:@"basic", @"likes",@"relationships", nil]];
    }
}
/*!
 * @discussion to get user timeline
 * @param token instagram token which had been gotten after login
 * @param userID id of the user
 * @param count elements quantity
 * @return the list of items
 */
-(NSArray*)getPostsWithToken:(NSString*)token andUserID:(NSString*)userID andCount:(NSUInteger)count
{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"https://api.instagram.com/v1/users/self/feed?access_token=%@&count=%lu",token,count]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    NSError *error = nil; NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSArray *resultArray = [self postsFromData:data isSearched:NO];
    return resultArray;
}
/*!
 * @discussion worker for getPostsWithToken method
 * @param data has been retrived from instagram in getPostsWithToken method
 * @param isSearched you do search or simply retrive timeline
 * @return the list of compiled timeline items
 */
- (NSArray *)postsFromData:(NSData *)data isSearched:(BOOL)isSearched
{
    NSMutableArray* resultArray = [[NSMutableArray alloc] init];
    if(data)
    {
        NSError* error = nil;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:data
                              options:kNilOptions
                              error:&error];
        if(!error)
        {
            NSDictionary* dataArray = [json objectForKey:@"data"];
            for(NSDictionary* dataDict in dataArray)
            {
                NSMutableDictionary *resultDictionary = [[NSMutableDictionary alloc] init];
                NSString* userID = [dataDict objectForKey:@"id"];
                NSString* createdAt = [dataDict objectForKey:@"created_time"];
                NSDate* dateAdding = [NSDate dateWithTimeIntervalSince1970:[createdAt longLongValue]];
                NSDictionary* caption = [dataDict objectForKey:@"caption"];
                [resultDictionary setObject:userID forKey:kPostIDDictKey];
                [resultDictionary setObject:dateAdding forKey:kPostDateDictKey];
                
                [resultDictionary setObject:[NSNumber numberWithBool:isSearched] forKey:kPostIsSearched];
                
                if (dataDict[@"link"]){
                    [resultDictionary setObject:dataDict[@"link"] forKey:kPostLinkOnWebKey];
                }
                
                if([caption isKindOfClass:[NSDictionary class]] && [caption objectForKey:@"text"])
                {
                    // TODO: get tags here
                    NSString *postText = [caption objectForKey:@"text"];
                    [resultDictionary setObject:postText forKey:kPostTextDictKey];
                }
                else
                {
                    resultDictionary[kPostTextDictKey] = @"";
                }
                
                //media
                NSString* typeMedia = [dataDict objectForKey:@"type"];
                NSMutableArray* mediaResultArray = [[NSMutableArray alloc] init];
                
                
                NSMutableDictionary* mediaResultDict = [[NSMutableDictionary alloc] init];
                if([typeMedia isEqualToString:@"video"])
                {
                    NSDictionary* videos = [dataDict objectForKey:@"videos"];
                    NSDictionary* standartResolution = [videos objectForKey:@"standard_resolution"];
                    NSString* videoLink = [standartResolution objectForKey:@"url"];
                    [mediaResultDict setObject:videoLink forKey:kPostMediaURLDictKey];
                    [mediaResultDict setObject:typeMedia forKey:kPostMediaTypeDictKey];
                    
                    if (dataDict[@"images"])
                    {
                        NSDictionary* images = [dataDict objectForKey:@"images"];
                        NSDictionary* imageURLDict = [images objectForKey:@"low_resolution"];
                        [mediaResultDict setObject:[imageURLDict objectForKey:@"url"] forKey:kPostMediaPreviewDictKey];
                    }
                }
                else
                {
                    if (dataDict[@"images"])
                    {
                        NSDictionary* images = [dataDict objectForKey:@"images"];
                        NSDictionary* imageURLDict = [images objectForKey:@"low_resolution"];
                        [mediaResultDict setObject:[imageURLDict objectForKey:@"url"] forKey:kPostMediaURLDictKey];
                        [mediaResultDict setObject:@"image" forKey:kPostMediaTypeDictKey];
                    }
                }
                [mediaResultArray addObject:mediaResultDict];
                
                [resultDictionary setObject:mediaResultArray forKey:kPostMediaSetDictKey];
                
                //user Info
                NSDictionary* authorDict = [dataDict objectForKey:@"user"];
                NSString* authorID = [authorDict objectForKey:@"id"];
                NSString* authorName = [authorDict objectForKey:@"username"];
                NSString* userPicture = [authorDict objectForKey:@"profile_picture"];
                
                NSMutableDictionary* personPosted = [[NSMutableDictionary alloc] init];
                
                [personPosted setValue:authorName forKey:kPostAuthorNameDictKey];
                [personPosted setValue:userPicture forKey:kPostAuthorAvaURLDictKey];
                [personPosted setValue:authorID forKey:kPostAuthorIDDictKey];
                
                [resultDictionary setObject:personPosted forKey:kPostAuthorDictKey];
                
                //get comments
                NSNumber* countOfComments = [NSNumber numberWithInt:0];
                if ([dataDict objectForKey:@"comments"])
                {
                    NSDictionary* commentData = [dataDict objectForKey:@"comments"];
                    NSNumber* count = [commentData objectForKey:@"count"];
                    if(count.integerValue>0)
                    {
                        NSMutableArray* commentsResArray = [[NSMutableArray alloc] init];
                        NSArray* commentsArray = [commentData objectForKey:@"data"];
                        for(NSDictionary* comment in commentsArray)
                        {
                            NSMutableDictionary* commentResDict = [[NSMutableDictionary alloc] init];
                            NSMutableDictionary* authorResDict = [[NSMutableDictionary alloc] init];
                            
                            NSString* commentText = [comment objectForKey:@"text"];
                            
                            NSString* commentID = [comment objectForKey:@"id"];
                            NSString* commentCreatedTime = [comment objectForKey:@"created_time"];
                            NSDate* dateAddingComment = [NSDate dateWithTimeIntervalSince1970:[commentCreatedTime longLongValue]];
                            [commentResDict setObject:commentText forKey:kPostCommentTextDictKey];
                            [commentResDict setObject:commentID forKey:kPostCommentIDDictKey];
                            [commentResDict setObject:dateAddingComment forKey:kPostCommentDateDictKey];
                            
                            //author comment
                            NSDictionary* authorComment = [comment objectForKey:@"from"];
                            if ([authorComment objectForKey:@"profile_picture"])
                            {
                                NSString* authorCommentImageURL = [authorComment objectForKey:@"profile_picture"];
                                [authorResDict setObject:authorCommentImageURL forKey:kPostCommentAuthorAvaURLDictKey];
                            }
                            NSString* authorCommentName = [authorComment objectForKey:@"username"];
                            NSString* authorCommentID = [authorComment objectForKey:@"id"];
                            [authorResDict setObject:authorCommentName forKey:kPostCommentAuthorNameDictKey];
                            [authorResDict setObject:authorCommentID forKey:kPostCommentAuthorIDDictKey];
                            
                            [commentResDict setObject:authorResDict forKey:kPostCommentAuthorDictKey];
                            
                            [commentsResArray addObject:commentResDict];
                        }
                        [resultDictionary setObject:commentsResArray forKey:kPostCommentsDictKey];
                    }
                    countOfComments = [NSNumber numberWithInt:count.integerValue];
                }
                [resultDictionary setObject:countOfComments forKey:kPostCommentsCountDictKey];
                
                //likes
                if ([dataDict objectForKey:@"likes"])
                {
                    NSDictionary* like = [dataDict objectForKey:@"likes"];
                    if ([like objectForKey:@"count"])
                    {
                        NSNumber* countOfLikes = [like objectForKey:@"count"];
                        [resultDictionary setObject:countOfLikes forKey:kPostLikesCountDictKey];
                    }
                }
                
                [resultArray addObject:resultDictionary];
            }
        }
    }
    return [resultArray copy];
}
/*!********************************Instagram workers END**********************************************/


#pragma Mark leftMenudelegate
-(void)actionPresed:(ActionsType)actionsTypel complite:(void (^)())complite{
    
    NSLog(@"actionsTypel %lu", (unsigned long)actionsTypel);
    
    
    if (actionsTypel == quitAction) {
        
        [self progressForQuit:^{
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FBWebLogin" bundle:nil];
            FBWebLoginViewController *notebook = [storyboard instantiateViewControllerWithIdentifier:@"FBWebLogin"];
            [self presentViewController:notebook animated:YES completion:^{
                [self stopSubviewForQuit];
                [[self.childViewControllers lastObject] willMoveToParentViewController:nil];
                [[[self.childViewControllers lastObject] view] removeFromSuperview];
                [[self.childViewControllers lastObject] removeFromParentViewController];
                
            }];
        }];
        
    }
    complite();
}

/*!
 * @discussion  to display Notification menu
 */
-(IBAction)showRightMenu{
    
    emsRightMenuVC *emsRightMenu = [ [emsRightMenuVC alloc] initWithDelegate:self];
    NSLog(@"emsLeftMenu %@",emsRightMenu.delegate);
}
/*!
 * @discussion  to display main menu
 */
-(IBAction)showLeftMenu{
    
    emsLeftMenuVC *emsLeftMenu =[[emsLeftMenuVC alloc]initWithDelegate:self ];
    NSLog(@"emsLeftMenu %@",emsLeftMenu.delegate);
}
/*!
 * @discussion  to lounch progress indicator
 */
-(void)progressForQuit:(void (^)())callback;{
    
    if (subView == nil) {
        subView = [[emsScadProgress alloc] initWithFrame:self.view.frame screenView:self.view andSize:CGSizeMake(320, 580)];
        [self.view addSubview:subView];
        subView.alpha = 0;
        
        [UIView animateWithDuration:0.5 animations:^{
            subView.alpha = 1;
        } completion:^(BOOL finished) {
            callback();
        }];
        
    }
}

-(void)stopSubviewForQuit{
    
    [UIView animateWithDuration:0.5 animations:^{
        subView.alpha = 0;
    } completion:^(BOOL finished) {
        [subView removeFromSuperview];
        subView = nil;
    }];
}
@end
