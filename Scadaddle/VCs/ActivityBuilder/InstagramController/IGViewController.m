//
//  IGViewController.m
//  Scadaddle
//
//  Created by Roman Bigun on 6/23/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "IGViewController.h"
#import "ObjectHandler.h"
#import "FBAlbumCollectionViewCell.h"
@interface IGViewController ()

@end

@implementation IGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton* loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [loginButton sizeToFit];
    loginButton.center = CGPointMake(160, 200);
    [loginButton addTarget:self
                    action:@selector(login)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    // here i can set accessToken received on previous login
    appDelegate.instagram.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    appDelegate.instagram.sessionDelegate = self;
    if ([appDelegate.instagram isSessionValid]) {
       
    } else {
        [appDelegate.instagram authorize:[NSArray arrayWithObjects:@"comments", @"likes", nil]];
    }
    
    self.facebookAlbumsCollection.delegate = self;
    [self.facebookAlbumsCollection registerClass:[FBAlbumCollectionViewCell class] forCellWithReuseIdentifier:@"FBAlbumCollectionViewCell"];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void)login {
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.instagram authorize:[NSArray arrayWithObjects:@"comments", @"likes", nil]];
}

#pragma - IGSessionDelegate

-(void)igDidLogin {
    NSLog(@"Instagram did login");

    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [[NSUserDefaults standardUserDefaults] setObject:appDelegate.instagram.accessToken forKey:@"accessToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self getPostsWithToken:appDelegate.instagram.accessToken andCount:200];
        
}

-(void)igDidNotLogin:(BOOL)cancelled {
    NSLog(@"Instagram did not login");
    NSString* message = nil;
    if (cancelled) {
        message = @"Access cancelled!";
    } else {
        message = @"Access denied!";
    }
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

-(void)igDidLogout {
    NSLog(@"Instagram did logout");
    // remove the accessToken
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"accessToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)igSessionInvalidated {
    NSLog(@"Instagram session was invalidated");
}

///////////////////

-(NSArray*)getPostsWithToken:(NSString*)token andCount:(NSUInteger)count
{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"https://api.instagram.com/v1/users/self/feed?access_token=%@&count=%lu",token,count]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    NSError *error = nil; NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSArray *resultArray = [self postsFromData:data isSearched:NO];
    return resultArray;
}
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
                
                if (dataDict[@"link"])
                {
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

@end
