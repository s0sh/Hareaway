//
//  YoutubeHelper.h
//  Scadaddle
//
//  Created by Roman Bigun on 4/17/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoBox.h"
@protocol EMSYoutubeDelegate;

@interface YoutubeHelper : NSObject<PhotoBoxDelegate>

@property (nonatomic,assign) id <EMSYoutubeDelegate> delegate;
@property(nonatomic,retain) NSMutableArray *videoObjects;
-(void)searchYoutubeVideosForTerm:(NSString*)term;
@end

@protocol EMSYoutubeDelegate <NSObject>
@required
@optional
-(void)youtubeBrowser:(YoutubeHelper*)browser select:(NSString*)keyID title:(NSString*)title;
-(void)youtubeBrowser:(YoutubeHelper*)browser down:(NSString*)keyID;
-(void)youtubeBrowserDidClose:(YoutubeHelper*)browser;
@end