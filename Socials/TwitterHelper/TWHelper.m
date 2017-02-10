//
//  TWHelper.m
//  Scadaddle
//
//  Created by Roman Bigun on 4/8/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "TWHelper.h"
#import "SocialsStoreCoordinator.h"
#import "ABStoreManager.h"
@implementation TWHelper

+(void)insertTwitterLoginButtonIntoViewController:(UIViewController*)controller
{
    if([SocialsStoreCoordinator checkSocialExistanceForType:kSocialTypeTwitter])
    {
    
        return;
    
    }
    else
    {
        [Fabric with:@[TwitterKit]];
        TWTRLogInButton *logInButton = [TWTRLogInButton buttonWithLogInCompletion:^(TWTRSession *session, NSError *error)
        {
          
            [self twitterUser:session.userID];
        
        }];
        logInButton.center = CGPointMake(controller.view.frame.size.width/2, 170);
        [controller.view addSubview:logInButton];
    }
}
+(void)loadTweets
{

    NSArray *tweetIDs = @[@"20", @"510908133917487104"];
    [[[Twitter sharedInstance] APIClient]
     loadTweetsWithIDs:tweetIDs
     completion:^(NSArray *tweets,
                  NSError *error) {
         NSLog(@"%@",tweets);
     }];

}
+(void)twitterUser:(NSString*)userId
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
                 [self loadTweets];
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


@end
