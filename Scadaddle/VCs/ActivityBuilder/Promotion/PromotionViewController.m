//
//  PromotionViewController.m
//  Scadaddle
//
//  Created by Roman Bigun on 5/29/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "PromotionViewController.h"
#import "emsMainScreenVC.h"
#import "ABStoreManager.h"
#import "emsAPIHelper.h"
#import <Social/Social.h>
#import "SocialsManager.h"
#import "TWHelper.h"
#import "ScadaddlePopup.h"
#import "InstagHelper.h"
#define consumerKeyScadaddle @"Q42j18ZXFm0QgsXfGGmqpdwbU"
#define consumerSecretScadaddle @"FS5TvqazLYLnCKkk9NcFAJKTk80KO3QqedJTnmt4Xf4JL83yxS"
#import "emsScadProgress.h"


typedef void (^accountChooserBlock_t)(ACAccount *account, NSString *errorMessage); // don't bother with NSError for that

@interface PromotionViewController ()
{

    ScadaddlePopup *popup;
    emsScadProgress * subView;
    BOOL isAlreadySettled;

    
}
@property (nonatomic, strong) NSArray *statuses;
@property (nonatomic, strong) accountChooserBlock_t accountChooserBlock;
@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSArray *iOSAccounts;
@property (nonatomic, strong) NSArray *fbPages;
@end

@implementation PromotionViewController

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
  //Check whether we should display pages selector or not
   
    if(self.fbPages.count==1){
        self.hideFBPage.alpha=1;
    }else if(self.fbPages.count>1){
        self.hideFBPage.alpha=0;
    }
    
    [self initSocialButtons];
}

- (void)viewDidLoad {
   
    [super viewDidLoad];
    [self progress];
    
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    NSMutableArray *tmpPages = [NSMutableArray new];
    [tmpPages addObject:@{@"name":@""}];
    [tmpPages addObjectsFromArray:(NSArray*)[Server facebookPages]];
    UITapGestureRecognizer *panGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    panGesture.delegate = self;
    panGesture.numberOfTapsRequired = 1;
    
    self.fb_checked_bg.alpha=0;
    self.tw_checked_bg.alpha=0;
    self.in_checked_bg.alpha=0;
    self.sharedLink.delegate = self;
    [self.sharedLink setLeftViewMode:UITextFieldViewModeAlways];
    [self.sharedLink setLeftView:spacerView];
    self.accountStore = [[ACAccountStore alloc] init];
    [self.sharedLink addGestureRecognizer:panGesture];
    self.fbPages = [NSArray arrayWithArray:tmpPages];
    
    isTwitterChecked=NO;
    isFacebookChecked=NO;
    isInstaChecked=NO;
    isAlreadySettled = NO;
    
    [self stopSubview];
    
    

    
}
#pragma mark Picker View delegates method
- (NSInteger)numberOfComponentsInPickerView: (UIPickerView*)thePickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.fbPages count];
}
- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    self.sharedLink.text = [[self.fbPages objectAtIndex:row] valueForKey:@"name"];
    return [[self.fbPages  objectAtIndex:row]  valueForKey:@"name"];
}
- (IBAction)pickerAction:(id)sender
{
    NSInteger row = [self.pagesView selectedRowInComponent:0];
    self.sharedLink.text = [[self.fbPages objectAtIndex:row] valueForKey:@"name"];
    
}
/*!
 * @discussion Set facebook page to share
 */
-(IBAction)dofSelected:(id)sender
{
    
    self.pagePickerBG.alpha=0;
    [self.sharedLink resignFirstResponder];
    [[ABStoreManager sharedManager] addData:self.sharedLink.text forKey:@"facebookPage"];
    
}
- (IBAction)handleTap:(UITapGestureRecognizer *)recognizer {
    
     self.pagePickerBG.alpha=1;
     [self.sharedLink resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.pagePickerBG.alpha=1;
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    
    [textField resignFirstResponder];
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*!
 * @discussion Twitter worker
 */
-(void)loginWithiOSAction
{

    __weak typeof(self) weakSelf = self;
    
    self.accountChooserBlock = ^(ACAccount *account, NSString *errorMessage) {
        
        NSString *status = nil;
        if(account) {
            status = [NSString stringWithFormat:@"Did select %@", account.username];
            
            [weakSelf loginWithiOSAccount:account];
        } else {
            status = errorMessage;
        }
        
        
    };
    
    [self chooseAccount];

}
/*!
 * @discussion Silent check whether user is logged in or not to TWITTER
 */
- (void)loginWithiOSAccount:(ACAccount *)account {
    
    self.twitter = [STTwitterAPI twitterAPIOSWithAccount:account];
    
    [_twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        
        NSLog(@"%@",[NSString stringWithFormat:@"@%@ (%@)", username, userID]);
        
    } errorBlock:^(NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
    
}
/*!
 * @discussion Set social buttons status (check/uncheck)
 */
-(void)initSocialButtons
{
    NSDictionary *tmp = [NSDictionary new];
    tmp = [[ABStoreManager sharedManager] ongoingActivity].count>0?
    [[ABStoreManager sharedManager] ongoingActivity]:
    [[ABStoreManager sharedManager] editingActivityData];
    
    if([tmp[@"postFacebook"] isEqualToString:@"1"]){
       isFacebookChecked = YES;
       self.fb_checked_bg.alpha = 1;
    }
    if([tmp[@"postInstagram"] isEqualToString:@"1"]){
        isInstaChecked = YES;
        self.in_checked_bg.alpha = 1;
    }
    if([tmp[@"postTwitter"] isEqualToString:@"1"]){
        isTwitterChecked = YES;
        self.tw_checked_bg.alpha = 1;
    }
    self.sharedLink.text  = tmp[@"facebookPage"];
    
    

}
/*!
 * @discussion Set Post To Facebook flag
 */
-(IBAction)facebookShare:(id)sender
{
    
    if(isFacebookChecked)
    {
        isFacebookChecked = NO;
        self.fb_checked_bg.alpha = 0;
        [[ABStoreManager sharedManager] addData:@"0" forKey:@"postFacebook"];
        
    }
    else
    {
        isFacebookChecked = YES;
        self.fb_checked_bg.alpha = 1;
        [[ABStoreManager sharedManager] addData:@"1" forKey:@"postFacebook"];
        
        
    }
}
/*!
 * @discussion Set Post To Instagram flag
 */
-(IBAction)instaShare:(id)sender
{
    
    if(isInstaChecked)
    {
        isInstaChecked = NO;
        self.in_checked_bg.alpha = 0;
        [[ABStoreManager sharedManager] addData:@"0" forKey:@"postInstagram"];
        
    }
    else
    {
        if(![[InstagHelper sharedInstance] isInstagramLoggedIn])
        {
        
         //   [[InstagHelper sharedInstance] instagramLogin];
        
        }
        
        isInstaChecked = YES;
        self.in_checked_bg.alpha = 1;
        [[ABStoreManager sharedManager] addData:@"1" forKey:@"postInstagram"];
        
        
    }
}
- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier {
    
    // in case the user has just authenticated through WebViewVC
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
    
    [_twitter postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
        NSLog(@"-- screenName: %@", screenName);
        
        NSLog(@"%@",[NSString stringWithFormat:@"%@ (%@)", screenName, userID]);
        
        /*
         At this point, the user can use the API and you can read his access tokens with:
         
         _twitter.oauthAccessToken;
         _twitter.oauthAccessTokenSecret;
         
         You can store these tokens (in user default, or in keychain) so that the user doesn't need to authenticate again on next launches.
         
         Next time, just instanciate STTwitter with the class method:
         
         +[STTwitterAPI twitterAPIWithOAuthConsumerKey:consumerSecret:oauthToken:oauthTokenSecret:]
         
         Don't forget to call the -[STTwitter verifyCredentialsWithSuccessBlock:errorBlock:] after that.
         */
        
    } errorBlock:^(NSError *error) {
        
       
        NSLog(@"-- %@", [error localizedDescription]);
    }];
}
/*!
 * @discussion  Calls if we want to use twitter account stored into the ACAccountStore
 */
- (void)chooseAccount {
    
    ACAccountType *accountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    ACAccountStoreRequestAccessCompletionHandler accountStoreRequestCompletionHandler = ^(BOOL granted, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            if(granted == NO) {
                _accountChooserBlock(nil, @"Acccess not granted.");
                return;
            }
            
            self.iOSAccounts = [_accountStore accountsWithAccountType:accountType];
            
            if([_iOSAccounts count] == 1) {
                ACAccount *account = [_iOSAccounts lastObject];
                _accountChooserBlock(account, nil);
            } else {
                UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Select an account:"
                                                                delegate:self
                                                       cancelButtonTitle:@"Cancel"
                                                  destructiveButtonTitle:nil otherButtonTitles:nil];
                for(ACAccount *account in _iOSAccounts) {
                    [as addButtonWithTitle:[NSString stringWithFormat:@"@%@", account.username]];
                }
                [as showInView:self.view];
            }
        }];
    };
    
#if TARGET_OS_IPHONE &&  (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0)
    if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_6_0) {
        [self.accountStore requestAccessToAccountsWithType:accountType
                                     withCompletionHandler:accountStoreRequestCompletionHandler];
    } else {
        [self.accountStore requestAccessToAccountsWithType:accountType
                                                   options:NULL
                                                completion:accountStoreRequestCompletionHandler];
    }
#else
    [self.accountStore requestAccessToAccountsWithType:accountType
                                               options:NULL
                                            completion:accountStoreRequestCompletionHandler];
#endif
    
}

#pragma mark Twitter Workers
/*!
 * @discussion Trying to get user info+tokens by reversing auth
 */
-(void)twitterProcess:(UIView*)target
{
    
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIWithOAuthConsumerName:nil consumerKey:consumerKeyScadaddle consumerSecret:consumerSecretScadaddle];
    
    [twitter postReverseOAuthTokenRequest:^(NSString *authenticationHeader) {
        
        self.accountChooserBlock = ^(ACAccount *account, NSString *errorMessage) {
            
            if(account == nil) {
                NSLog(@"Twitter error %@",errorMessage);
                return;
            }
            
            STTwitterAPI *twitterAPIOS = [STTwitterAPI twitterAPIOSWithAccount:account];
            
            [twitterAPIOS verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
                
                [twitterAPIOS postReverseAuthAccessTokenWithAuthenticationHeader:authenticationHeader successBlock:^(NSString *oAuthToken, NSString *oAuthTokenSecret, NSString *userID, NSString *screenName) {
                    
                    NSLog(@"Reverse auth. success for @%@", screenName);
                    
                    NSLog(@"-- REVERSE AUTH OK");
                    NSLog(@"-- you can now access @%@ account (ID: %@) with specified consumer tokens and the following access tokens:", screenName, userID);
                    NSLog(@"-- oAuthToken: %@", oAuthToken);
                    NSLog(@"-- oAuthTokenSecret: %@", oAuthTokenSecret);
                    isTwitterChecked = YES;
                    self.tw_checked_bg.alpha = 1;
                    [[ABStoreManager sharedManager] addData:@"1" forKey:@"postTwitter"];
                    [[ABStoreManager sharedManager] addData:oAuthToken forKey:@"twitterOAuthToken"];
                    [[ABStoreManager sharedManager] addData:oAuthTokenSecret forKey:@"twitterOAuthTokenSecret"];
                    
                } errorBlock:^(NSError *error) {
                    NSLog(@"%@",[error localizedDescription]);
                    isTwitterChecked = NO;
                    self.tw_checked_bg.alpha = 0;
                    [[ABStoreManager sharedManager] addData:@"0" forKey:@"postTwitter"];
                }];
                
            } errorBlock:^(NSError *error) {
                NSLog(@"%@",[error localizedDescription]);
                isTwitterChecked = NO;
                self.tw_checked_bg.alpha = 0;
                [[ABStoreManager sharedManager] addData:@"0" forKey:@"postTwitter"];
            }];
            
        };
        
        
    } errorBlock:^(NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
    
    
}
/*!
 * @discussion  Logged in user profile data
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
                     [[ABStoreManager sharedManager] addData:@"1" forKey:@"postTwitter"];
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
/*!
 * @discussion  Check whether user is logged in or not
 */
-(void)isTwitterLoggedIn
{

    [Fabric with:@[TwitterKit]];
    
    [[Twitter sharedInstance] logInWithCompletion:^
     (TWTRSession *session, NSError *error) {
         if (session) {
             NSLog(@"signed in as %@", [session userName]);
             [self twitterUser:[session userID]];
             [self twitterProcess:self.view];
             
             
         } else {
             NSLog(@"error22: %@", [error localizedDescription]);
             isTwitterChecked = NO;
             self.tw_checked_bg.alpha = 0;
             [[ABStoreManager sharedManager] addData:@"0" forKey:@"postTwitter"];
             
         }
     }];

}
/*!
 * @discussion Set up flag for Share to twitter
 */
-(IBAction)twitterShare:(id)sender
{
    
    if(isTwitterChecked)
    {
        isTwitterChecked = NO;
        self.tw_checked_bg.alpha = 0;
        [[ABStoreManager sharedManager] addData:@"0" forKey:@"postTwitter"];
        
    }
    else
    {
     
        isTwitterChecked = YES;
        self.tw_checked_bg.alpha = 1;
        [self isTwitterLoggedIn];
        
    }
   
}
#pragma mark -Popups
/*!
 * @discussion  to fire progress indicator
 */
-(void)progress{
    subView = [[emsScadProgress alloc] initWithFrame:self.view.frame screenView:self.view andSize:CGSizeMake(320, 580)];
    [self.view addSubview:subView];
    subView.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        subView.alpha = 1;
    }];
}
/*!
 * @discussion  to hide progress indicator
 * @see emsScadProgress class
 */
-(void)stopSubview{
    
    [UIView animateWithDuration:0.5 animations:^{
        subView.alpha = 0;
    } completion:^(BOOL finished) {
        [subView removeFromSuperview];
        subView = nil;
    }];
    
}
-(void)upThread
{
    
    [self startUpdating];
    
}
/*!
 * @discussion to fire popup
 */
-(void)startUpdating
{
    
    popup = [[ScadaddlePopup alloc] initWithFrame:self.view.frame withTitle:@"Getting data from Twitter..." withProgress:YES andButtonsYesNo:NO forTarget:self andMessageType:-1];
    [self.view addSubview:popup];
    
}
/*!
 * @discussion  to hide popup
 * @param title text for popup title
 * @param show to display/hide OK button
 */
-(void)messagePopupWithTitle:(NSString*)title hideOkButton:(BOOL)show
{
    
    popup = [[ScadaddlePopup alloc] initWithFrame:self.view.frame withTitle:title withProgress:NO andButtonsYesNo:NO forTarget:self andMessageType:-1];
    [popup hideDisplayButton:show];
    [self.view addSubview:popup];
    
}
/*!
 * @discussion to dismiss progress with title and duration so 
 * to hide it slowly
 * @param title text for popup title
 * @param duration time to disappear
 * @param exit if exit==1 this controller will be dismissed
 */
-(void)dismissPopupActionWithTitle:(NSString*)title andDuration:(double)duration andExit:(BOOL)exit
{
    
    [popup updateTitleWithInfo:title];
    [UIView animateWithDuration:duration animations:^{
        
        popup.alpha=0.9;
    } completion:^(BOOL finished) {
        
        [popup removeFromSuperview];
        if(exit)
        {
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
        
    }];
    
    
}
-(IBAction)dismissPopup
{
    
    // [popup updateTitleWithInfo:@"Done!"];
    [UIView animateWithDuration:0.01 animations:^{
        
        popup.alpha=0.9;
    } completion:^(BOOL finished) {
        
        [popup removeFromSuperview];
        
    }];
    
}

@end
