//
//  InstagHelper.m
//  Scadaddle
//
//  Created by Roman Bigun on 4/8/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//



#import "InstagHelper.h"
#define INSTA_ADD_ID @"d310e27dfd04421a9ca87e8a32fd7c44"
@implementation InstagHelper
@synthesize isInstagramLoggedIn = _isInstagramLoggedIn;
@synthesize instagram = _instagram;


+ (InstagHelper *)sharedInstance
{
    
    static InstagHelper * _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[InstagHelper alloc] init];
        
    });
    
    return _sharedInstance;
}

-(id)init
{
    
    self = [super init];
    if(self)
    {
        self.instagram = [[Instagram alloc] initWithClientId:INSTA_ADD_ID delegate:self];
        self.instagram.sessionDelegate = self;
    }
    
    return self;
    
}
-(void)instagramLogin
{
    
   
    if(self.instagram.accessToken==nil)
    {
       [self.instagram authorize:[NSArray arrayWithObjects:@"basic", @"likes",@"relationships", nil]];
    }

}
-(void)igDidLogin
{
    
    NSLog(@"Instagram did login %@",self.instagram.accessToken);
    [[NSUserDefaults standardUserDefaults] setObject:self.instagram.accessToken forKey:@"accessToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.isInstagramLoggedIn = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GooglePlusLoginSuccessful"
                                                        object:self
                                                      userInfo:@{@"provider":@"instagram"}];
//    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"users/self/feed", @"method", nil];
//    [self.instagram requestWithParams:params delegate:self];
    
}
-(void)igDidLogout
{
    NSLog(@"Instagram did logout");
    // remove the accessToken
 
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"accessToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.isInstagramLoggedIn = NO;
}
-(void)igDidNotLogin:(BOOL)cancelled
{
    NSLog(@"Instagram did not login");
    // remove the accessToken
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"accessToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.isInstagramLoggedIn = NO;
}
-(void)igSessionInvalidated
{
    NSLog(@"Instagram session was invalidated");
}
#pragma mark - IGRequestDelegate

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
-(NSArray*)getInstagramPosts
{
   if(self.instagram.accessToken==nil)
   {
   
       [self instagramLogin];
       return [self getPostsWithToken:self.instagram.accessToken andUserID:@"" andCount:200];

   }
   return [self getPostsWithToken:self.instagram.accessToken andUserID:@"" andCount:200];

}
-(NSArray*)getPostsWithToken:(NSString*)token andUserID:(NSString*)userID andCount:(NSUInteger)count
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
