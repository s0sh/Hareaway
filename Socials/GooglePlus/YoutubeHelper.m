//
//  YoutubeHelper.m
//  Scadaddle
//
//  Created by Roman Bigun on 4/17/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "YoutubeHelper.h"
#import "MGBox.h"
#import "MGScrollView.h"
#import "JSONModelLib.h"
#import "VideoModel.h"


@implementation YoutubeHelper
{
     NSArray* videos;
}

@synthesize videoObjects;

-(void)searchYoutubeVideosForTerm:(NSString*)term
{
   //URL escape the term
    term = [term stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //make HTTP call
    
    NSString* searchCall = [NSString stringWithFormat:@"%@",@"https://www.googleapis.com/youtube/v3/channels?part=contentDetails&mine=true&key=AIzaSyCEzinvuIHkRehfFoL3bmIjZAtHyZbkKH4"];
    
    [JSONHTTPClient getJSONFromURLWithString: searchCall
                                  completion:^(NSDictionary *json, JSONModelError *err) {
                                      
                                      //got JSON back

                                      NSLog(@"Got JSON from web: %@", json);

                                      
                                      if (err) {
                                          [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                      message:[err localizedDescription]
                                                                     delegate:nil
                                                            cancelButtonTitle:@"Close"
                                                            otherButtonTitles: nil] show];
                                          return;
                                      }
                                      
                                      //initialize the models
                                      videos = [VideoModel arrayOfModelsFromDictionaries:json[@"feed"][@"entry"]];
                                      if (videos)
                                      {
                                          
                                          [self makeVideosFromObjects];
                                      
                                      }
                                      else
                                      {
                                          [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                      message:@"Please try different keywords or try again later"
                                                                     delegate:nil
                                                            cancelButtonTitle:@"Close"
                                                            otherButtonTitles: nil] show];
                                      }
                                  }];
}

-(NSString*)youtubeID:(VideoModel*)video
{
    VideoLink* link = video.link[0];
    
    NSString* videoId = nil;
    NSArray *queryComponents = [link.href.query componentsSeparatedByString:@"&"];
    for (NSString* pair in queryComponents) {
        NSArray* pairComponents = [pair componentsSeparatedByString:@"="];
        if ([pairComponents[0] isEqualToString:@"v"]) {
            videoId = pairComponents[1];
            break;
        }
    }
    
    if (!videoId) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Video ID not found in video URL" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil]show];
        return nil;
    }
    
    return videoId;
}

-(void)makeVideosFromObjects
{
    __autoreleasing NSMutableDictionary *tmp = nil;
    videoObjects = [[NSMutableArray alloc] init];
    
    //add boxes for all videos
    for (int i=0;i<videos.count;i++)
    {
        tmp = [NSMutableDictionary new];
        //get the data
        VideoModel* video = videos[i];
        MediaThumbnail* thumb = video.thumbnail[0];
        VideoLink* link = video.link[0];
        [tmp setObject:video.title forKey:@"title"];
        [tmp setObject:thumb.url forKey:@"thumb_url"];
        [tmp setObject:link.href forKey:@"link"];
        [videoObjects addObject:tmp];
        tmp = nil;
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"youtubeVideoCreated" object:self userInfo:[NSDictionary dictionaryWithObject:videoObjects forKey:@"videoObjects"]];
        
}


@end
