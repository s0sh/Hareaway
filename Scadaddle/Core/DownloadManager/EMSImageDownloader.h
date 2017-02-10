//
//  EMSImageDownloader.h
//  Scadaddle
//
//  Created by Roman Bigun on 3/30/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^EMSDownloadProgressBlock)(float progressValue,NSInteger percentage);
typedef void (^EMSDowloadFinished)(NSData* fileData,NSString* fileName);
typedef void (^EMSDownloadFailBlock)(NSError*error);


@protocol EMSDownloaderDelegate <NSObject>

@required
-(void)EMSDownloadProgress:(float)progress Percentage:(NSInteger)percentage;
-(void)EMSDownloadFinished:(NSData*)fileData;
-(void)EMSDownloadFail:(NSError*)error;
@end

@interface EMSImageDownloader : NSObject <NSURLConnectionDataDelegate>

/*!
 * @discussion Get Receive NSData.
 */
@property (nonatomic,readonly) NSMutableData* receiveData;

/*!
 * @discussion Current Download Percentage
 */
@property (nonatomic,readonly) NSInteger downloadedPercentage;

/*!
 * @discussion `float` value for progress bar
 */
@property (nonatomic,readonly) float progress;

/*!
 * @discussion Server is allow resume or not
 */
@property (nonatomic,readonly) BOOL allowResume;

/*!
 * @discussion Suggest Download File Name
 */
@property (nonatomic,readonly) NSString* fileName;

/*!
 * @discussion Delegate Method
 */
@property (nonatomic,strong) id<EMSDownloaderDelegate>delegate;


//initwith file URL and timeout
-(id)initWithURL:(NSURL *)fileURL timeout:(NSInteger)timeout;

-(void)startWithDownloading:(EMSDownloadProgressBlock)progressBlock onFinished:(EMSDowloadFinished)finishedBlock onFail:(EMSDownloadFailBlock)failBlock;

-(void)startWithDelegate:(id<EMSDownloaderDelegate>)delegate;
-(void)cancel;
-(void)pause;
-(void)resume;
@end
