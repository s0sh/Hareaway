//
//  GPlusHelper.m
//  Scadaddle
//
//  Created by Roman Bigun on 4/8/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "GPlusHelper.h"
#import "SocialsStoreCoordinator.h"

@implementation GPlusHelper

@synthesize signIn;


-(void)getPlayList
{

    //https://www.googleapis.com/youtube/v3/channels?part=contentDetails&mine=true&key=AIzaSyCEzinvuIHkRehfFoL3bmIjZAtHyZbkKH4

}
-(void)shareActivityImage:(UIImage*)image andText:(NSString*)activityTitle
{

    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
    [GPPShare sharedInstance].delegate = self;
    [shareBuilder setPrefillText:activityTitle];
    [shareBuilder attachImage:image];
     
    [shareBuilder open];

}
#pragma mark Share Image callback
- (void)finishedSharingWithError:(NSError *)error {
    NSString *text;
    
    if (!error) {
        text = @"Success";
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GooglePlusSharedSuccessfull"
                                                            object:self
                                                          userInfo:@{@"shared":@"1"}];
        
    } else if (error.code == kGPPErrorShareboxCanceled) {
        text = @"Canceled";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GooglePlusSharedSuccessfull"
                                                            object:self
                                                          userInfo:@{@"shared":@"0"}];
    } else {
        text = [NSString stringWithFormat:@"Error (%@)", [error localizedDescription]];
    }
    
    NSLog(@"Status: %@", text);
}
-(void)userActivities
{
    
    activityArray = [NSMutableArray new];
    GTLServicePlus *service = [[GPPSignIn sharedInstance] plusService];
    
    [service setShouldFetchInBackground:YES];
    
    GTLQueryPlus *query = [GTLQueryPlus queryForActivitiesListWithUserId:@"me" collection:kGTLPlusCollectionPublic];
   
    
    [service executeQuery:query
        completionHandler:^(GTLServiceTicket *ticket,
                            GTLPlusActivityFeed *actFeed,
                            NSError *error) {
            
            
        }];
    
    GTLQueryPlus *queryGetPeoples = [GTLQueryPlus queryForPeopleListWithUserId:@"me"
                                                                    collection:@"visible"];
    
    
    
    [service executeQuery:queryGetPeoples
        completionHandler:^(GTLServiceTicket *ticket,
                            GTLPlusPeopleFeed *peopleFeed,
                            NSError *error) {
            if (error)
            {
                GTMLoggerError(@"Error: %@", error);
            }
            else
            {
                // Array of users from GTLPlusPeopleFeed
                NSArray* peopleList = peopleFeed.items;
                __block NSString *hashTagToCompare = [NSString new];
                for (GTLPlusPerson *people in peopleList)
                {
                    
                    GTLQueryPlus *query1 = [GTLQueryPlus queryForActivitiesListWithUserId:[people identifier] collection:kGTLPlusCollectionPublic];
                    
                    [service executeQuery:query1
                        completionHandler:^(GTLServiceTicket *ticket,
                                            GTLPlusActivityFeed *actFeed,
                                            NSError *error) {
                            
                            NSArray *activities = [actFeed items];
                            NSMutableDictionary *act = [[NSMutableDictionary alloc] init];
                            
                            for (GTLPlusActivity *activity in activities)
                            {
                                [act setObject:[activity title] forKey:kPostTextDictKey];
                                [act setObject:[activity identifier] forKey:kPostIDDictKey];
                                [act setObject:[activity url] forKey:@"url"];
                                //[act setObject:[[activity object] content] forKey:postTextDictKey];
                               // [act setObject:[[activity updated] date] forKey:kPostDateDictKey];
                                [act setObject:[[[activity object] plusoners] totalItems] forKey:kPostLikesCountDictKey];
                                
                                NSDictionary *authorDict = @{kPostAuthorIDDictKey: [people identifier], kPostAuthorAvaURLDictKey: [[people image] url], kPostAuthorNameDictKey: [people displayName]};
                                
                                [act setObject:authorDict forKey:kPostAuthorDictKey];
                                
                                NSMutableArray *arrayWithMedia = [[NSMutableArray alloc] init];
                                
                                NSArray *attachments = [[activity object] attachments];
                                if (attachments)
                                {
                                    NSString *displayName, *fullImageURL, *thumbnailImageURL, *content, *url, *videoURL, *albumID, *albumURL, *photoID;
                                    
                                    displayName = nil;
                                    fullImageURL = nil;
                                    thumbnailImageURL = nil;
                                    content = nil;
                                    url = nil;
                                    videoURL = nil;
                                    albumID = nil;
                                    albumURL = nil;
                                    photoID = nil;
                                    
                                    for (GTLPlusActivityObjectAttachmentsItem *attachmentItem in attachments)
                                    {
                                        NSMutableDictionary *tempMediaDict = [[NSMutableDictionary alloc] init];
                                        //
                                        if ([[attachmentItem objectType] isEqualToString:@"article"])
                                        {
                                            displayName = [attachmentItem displayName];
                                            fullImageURL = [[attachmentItem fullImage] url];
                                            thumbnailImageURL = [[attachmentItem image] url];
                                            content = [attachmentItem content];
                                            url = [attachmentItem url];
                                            
                                            if (![[act objectForKey:kPostTextDictKey] length] && [content length])
                                            {
                                                [act setObject:content forKey:kPostTextDictKey];
                                            }
                                            //
                                            
                                        }
                                        if ([[attachmentItem objectType] isEqualToString:@"video"])
                                        {
                                            [tempMediaDict setObject:@"video" forKey:kPostMediaTypeDictKey];
                                            
                                            displayName = [attachmentItem displayName];
                                            content = [attachmentItem content];
                                            videoURL = [attachmentItem url];
                                            thumbnailImageURL = [[attachmentItem image] url];
                                            
                                            if(videoURL && thumbnailImageURL)
                                            {
                                              tempMediaDict = (NSMutableDictionary *)@{kPostMediaURLDictKey:videoURL, kPostMediaPreviewDictKey:thumbnailImageURL, kPostMediaTypeDictKey: @"video"};
                                            }
                                            
                                        }
                                        if ([[attachmentItem objectType] isEqualToString:@"album"])
                                        {
                                            [tempMediaDict setObject:@"album" forKey:kPostMediaTypeDictKey];
                                            displayName = [attachmentItem displayName];
                                            albumID = [attachmentItem identifier];
                                            albumURL = [attachmentItem url];
                                            NSArray *thumbnails = [attachmentItem thumbnails];
                                            
                                            NSMutableArray *thumbnailImages = [[NSMutableArray alloc] init];
                                            for (GTLPlusActivityObjectAttachmentsItemThumbnailsItem *it in thumbnails)
                                            {
                                                [thumbnailImages addObject:@{kPostMediaPreviewDictKey: [[it image] url], kPostMediaURLDictKey: [[it image] url], kPostMediaTypeDictKey: @"image"}];
                                            }
                                            for (NSDictionary *dict in thumbnailImages)
                                            {
                                                [arrayWithMedia addObject:dict];
                                            }
                                        }
                                        if ([[attachmentItem objectType] isEqualToString:@"photo"])
                                        {
                                            [tempMediaDict setObject:@"image" forKey:kPostMediaTypeDictKey];
                                            
                                            displayName = [attachmentItem displayName]; // may be nil
                                            fullImageURL = [[attachmentItem fullImage] url];
                                            thumbnailImageURL = [[attachmentItem image] url];
                                            content = [attachmentItem content]; //NOT WORKING
                                            albumURL = [attachmentItem url];
                                            photoID = [attachmentItem identifier]; //may be nil
                                            
                                            tempMediaDict = (NSMutableDictionary *)@{kPostMediaURLDictKey: fullImageURL, kPostMediaPreviewDictKey: thumbnailImageURL, kPostMediaTypeDictKey: @"image"};
                                        }
                                        if (tempMediaDict)
                                        {
                                            [arrayWithMedia addObject:tempMediaDict];
                                        }
                                    }
                                    if (arrayWithMedia)
                                    {
                                        [act setObject:arrayWithMedia forKey:kPostMediaSetDictKey];
                                    }
                                }
                                
                                if ([act objectForKey:@"text"])
                                {
                                    //DLog(@"%@", [act objectForKey:@"text"]);
                                    NSMutableArray *hashTags = [[NSMutableArray alloc] init];
                                    
                                    NSMutableString *text = [[act objectForKey:@"text"] mutableCopy];
                                    NSRange range = [text rangeOfString:@"#"];
                                    while (range.location != NSNotFound)
                                    {
                                        BOOL endOfString = YES;
                                        NSInteger i = range.location + 1;
                                        while (i < [text length])
                                        {
                                            if (([text characterAtIndex:i] == ' ' || [text characterAtIndex:i] == ',' || [text characterAtIndex:i] == '.' || [text characterAtIndex:i] == ';' || [text characterAtIndex:i] == '\n' || [text characterAtIndex:i] == '\t' || [[NSCharacterSet punctuationCharacterSet] characterIsMember:[text characterAtIndex:i]]) && i < [text length] - 1)
                                                {
                                                    NSInteger length = i - range.location - 1;
                                                    NSLog(@"HASHTAG #%@ handled;", [text substringWithRange:NSMakeRange(range.location + 1, length)]);
                                                    if([[text substringWithRange:NSMakeRange(range.location + 1, length)] isEqualToString:@"TBT"])
                                                        {
                                                            hashTagToCompare = [text substringWithRange:NSMakeRange(range.location + 1, length)];
                                                        
                                                        }
                                                    [hashTags addObject:[text substringWithRange:NSMakeRange(range.location, length + 1)]];
                                                    [text deleteCharactersInRange:NSMakeRange(range.location, length + 1)];
                                                    range = [text rangeOfString:@"#"];
                                                    endOfString = NO;
                                                    break;
                                                }
                                            
                                            i++;
                                        }
                                        if (endOfString)
                                        {
                                            NSInteger tmpLength = [text length] - range.location - 1;
                                            [hashTags addObject:[text substringWithRange:NSMakeRange(range.location, tmpLength + 1)]];
                                            NSLog(@"HASHTAG #%@ handled;", [text substringWithRange:NSMakeRange(range.location, tmpLength)]);
                                            [text deleteCharactersInRange:NSMakeRange(range.location, tmpLength)];
                                            range = [text rangeOfString:@"#"];
                                        }
                                    }
                                    
                                    if ([hashTags count])
                                    {
                                        [act setObject:hashTags forKey:kPostTagsListKey];
                                    }
                                    
                                    if (act)
                                    {
                                       //if([hashTagToCompare isEqualToString:@"TBT"])
                                        [self addActivity:act];
                                        
                                    }
                                }
                            }
                            
                        }];
                }
            }
        }];


}
-(id)init
{

    self  =  [super init];
    if(self)
    {
    
      //  [self authenticateWithGoogle];
        
    
    }

    return self;
    
}
-(void)addActivity:(id)activity
{

    [activityArray addObject:activity];
    
}
- (void)clearCookie
{
    NSHTTPCookieStorage *cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *arrayOfCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    
    for(NSHTTPCookie* cookie in arrayOfCookies)
    {
        [cookies deleteCookie:cookie];
    }
}
- (void)authenticateWithGoogle {

   
        [self clearCookie];
        signIn = [GPPSignIn sharedInstance];
        [signIn signOut];
        [signIn disconnect];
        [signIn setDelegate:self];
        signIn.shouldFetchGooglePlusUser = YES;
        signIn.shouldFetchGoogleUserID = YES;
        signIn.shouldFetchGoogleUserEmail = YES;
        signIn.clientID = kClientID;
        [signIn setScopes:[NSArray arrayWithObjects: kGTLAuthScopePlusLogin, kGTLAuthScopePlusMe,@"https://www.googleapis.com/auth/youtube", nil]];
        [signIn authenticate];

   
}
-(void)googlePlusLogout
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"GooglePlusUser"];
    [self clearCookie];
    [[GPPSignIn sharedInstance] signOut];
    [[GPPSignIn sharedInstance] disconnect];
    
}
-(void)googlePlusLogin
{

    [self login];

}
-(void)GooglePlusButton:(UIViewController*)viewController
{
 
    
    self.signInButton = [[GPPSignInButton alloc] init];
    self.signInButton.frame = CGRectMake(20,320,280, 55);
    
    // Align the button in the center vertically
    
   // self.signInButton.center = viewController.view.center;
    [viewController.view addSubview:self.signInButton];
   
    
    [self login];
}
- (void)reportAuthStatus {
    if ([GPPSignIn sharedInstance].authentication)
    {
        NSLog(@"%@",@"Status: Authenticated");
        [self refreshUserInfo];
        
    }
    else
    {
        // To authenticate, use Google+ sign-in button.
        [signIn trySilentAuthentication];
        NSLog(@"%@",@"Status: Not authenticated");
    }
    
    
}

// Update the interface elements containing user data to reflect the
// currently signed in user.
-(BOOL)checkUserSighedIn
{

   
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"GooglePlusUser"])
    {
    
        return YES;
    
    }
    
    return NO;

}
-(NSString*)GPlusOAuthToken
{
    NSDictionary *d = [NSDictionary dictionary];
    d = [[NSUserDefaults standardUserDefaults] objectForKey:@"GooglePlusUser"];
    return d[@"access_token"];

}
- (void)refreshUserInfo {
    if ([GPPSignIn sharedInstance].authentication == nil) {
         return;
    }
    
    NSLog(@"%@",[GPPSignIn sharedInstance].userEmail);
    
    // The googlePlusUser member will be populated only if the appropriate
    // scope is set when signing in.
    GTLPlusPerson *person = [GPPSignIn sharedInstance].googlePlusUser;
    if (person == nil) {
        return;
    }
    
    NSLog(@"%@",person.displayName);
    
    #pragma mark Just for tests. In production should be commented out
    [self userActivities];
    
    // Load avatar image asynchronously, in background
    dispatch_queue_t backgroundQueue =
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(backgroundQueue, ^{
        NSData *avatarData = nil;
        NSString *imageURLString = person.image.url;
        if (imageURLString) {
            NSURL *imageURL = [NSURL URLWithString:imageURLString];
            avatarData = [NSData dataWithContentsOfURL:imageURL];
        }
        
        if (avatarData) {
            // Update UI from the main thread when available
            dispatch_async(dispatch_get_main_queue(), ^{
               
                //self.userAvatar.image = [UIImage imageWithData:avatarData];
                
            });
        }
    });
    
    
}
#pragma mark - GPPDeepLinkDelegate

- (void)didReceiveDeepLink:(GPPDeepLink *)deepLink {
    // An example to handle the deep link data.
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Deep-link Data"
                          message:[deepLink deepLinkID]
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}
-(void)refreshInterfaceBasedOnSignIn {
    if ([[GPPSignIn sharedInstance] authentication]) {
        
        self.signInButton.hidden = YES;
       
        
    } else {
        self.signInButton.hidden = NO;
        
    }
}
- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth
                   error:(NSError *)error
{
    
    if (!error)
    {
        NSLog(@"Auth params %@\n",[auth parameters]);
        
        OAuthToken = [[auth parameters] objectForKey:@"access_token"];
        idToken = [[auth parameters] objectForKey:@"id_token"];
        refreshToken = [[auth parameters] objectForKey:@"refresh_token"];
        tokenType = [[auth parameters] objectForKey:@"token_type"];
        serviceProvider = [[auth parameters] objectForKey:@"serviceProvider"];
        expireDate = [[auth parameters] objectForKey:@"expires_in"];
        userID = [signIn userID];
        userName = [[signIn googlePlusUser] displayName];
        userImage = [[[signIn googlePlusUser] image] url];
        
        NSMutableDictionary *user = [NSMutableDictionary new];
        [user setObject:OAuthToken forKey:@"access_token"];
        [user setObject:idToken forKey:@"id_token"];
        [user setObject:refreshToken forKey:@"refresh_token"];
        [user setObject:tokenType forKey:@"token_type"];
        [user setObject:expireDate forKey:@"expires_in"];
        [user setObject:userID forKey:@"id"];
        [user setObject:userName forKey:@"name"];
        [user setObject:userImage forKey:@"image"];
        [SocialsStoreCoordinator storeDataForSocialType:kSocialTypeGoogle andData:user];
        [[NSUserDefaults standardUserDefaults] setObject:user forKey:@"GooglePlusUser"];
        [_delegate loginSuccessWithToken:OAuthToken timeExpire:[NSString stringWithFormat:@"%@", expireDate] userID:userID userName:userName imageURL:userImage];
        [self refreshInterfaceBasedOnSignIn];
        [self reportAuthStatus];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GooglePlusLoginSuccessful"
                                                            object:self
                                                          userInfo:@{@"provider":@"gplus"}];
        
        
    }
    
  
}
- (id)login
{
    [self authenticateWithGoogle];
    [self clearCookie];
    
    
    SEL finishedSel = @selector(self:finishedWithAuth:error:);
    
    GTMOAuth2ViewControllerTouch *viewController;
    
    
    //kGTLAuthScopePlusLogin, kGTLAuthScopePlusMe
    viewController = [GTMOAuth2ViewControllerTouch controllerWithScope:kGTLAuthScopePlusLogin
                                                              clientID:kClientID
                                                          clientSecret:kGooglePlusClientSecret
                                                      keychainItemName:@"OAuth Scadaddle Google Contacts"
                                                              delegate:self
                                                      finishedSelector:finishedSel];
    
    return viewController;
    
}
- (void)didDisconnectWithError:(NSError *)error
{
    //[self dismissViewControllerAnimated:YES completion:nil];
}@end
