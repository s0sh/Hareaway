//
//  IGViewController.m
//  Scadaddle
//
//  Created by Roman Bigun on 6/23/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "IGViewController.h"
#import "ObjectHandler.h"
#import "InstagramCollectionViewCell.h"
#import "ABStoreManager.h"
#import "MediaPickerViewController.h"
#import "emsScadProgress.h"

@interface IGViewController ()
{

    NSMutableArray *facebookAlbumsArray;
    NSString *max_id;
    emsScadProgress * subView;
}
@end

@implementation IGViewController



-(void)progress:(void (^)())callback;{
    
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
/*!
 * @discussion dismiss this view
 */
-(IBAction)back
{

    [self dismissViewControllerAnimated:YES completion:^{
        
    }];

}
-(void)stopSubview{
    
    [UIView animateWithDuration:0.5 animations:^{
        subView.alpha = 0;
    } completion:^(BOOL finished) {
        [subView removeFromSuperview];
        subView = nil;
    }];
}

/*!
 * @discussion to pinpoint if image cached or not. If it was stored 
 * then set image to target view
 * @param target target to add image to
 * @param path absolute path to image
 * @return bool value YES/NO
 */
-(BOOL)imageHandler:(NSString*)path andImageView:(UIImageView*)target
{
    
    UIImage *image = [[[ABStoreManager sharedManager] imageCache] objectForKey:path];
    if(image)
    {
        target.image = image;
        
        return YES;
    }
    return NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    
    [self.facebookAlbumsCollection reloadData];
    
    if ([[ABStoreManager sharedManager] doneEditing]) {
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
    }
    
    [self stopSubview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    max_id = [NSString new];
    [self progress:^{
    
    
    }];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    if ( [[ABStoreManager sharedManager] editProfileMode] ){
        
        
        
        [self.xButton removeTarget:nil
                            action:NULL
                  forControlEvents:UIControlEventAllEvents];
        
        
        [self.xButton addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    }

    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    // here i can set accessToken received on previous login
    appDelegate.instagram.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    appDelegate.instagram.sessionDelegate = self;
    if ([appDelegate.instagram isSessionValid]) {
       
    } else {
        [appDelegate.instagram authorize:[NSArray arrayWithObjects:@"comments", @"likes", nil]];
    }
    
    self.facebookAlbumsCollection.delegate = self;
    [self.facebookAlbumsCollection registerClass:[InstagramCollectionViewCell class] forCellWithReuseIdentifier:@"InstagramCollectionViewCell"];
  
    [self getMyImagesWithToken:appDelegate.instagram.accessToken andCount:1000]; //мои фото
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
    
    [self getMyImagesWithToken:appDelegate.instagram.accessToken andCount:200];
    [self.facebookAlbumsCollection reloadData];
        
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
-(void)getMore
{
 
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"https://api.instagram.com/v1/users/self/media/recent?access_token=%@&count=%d&max_id=%@",appDelegate.instagram.accessToken,10,max_id]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    NSError *error = nil; NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString* responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ;
    NSLog(@"%@",responseString);
    NSArray *tmp = [NSArray arrayWithArray:[self postsFromData:data isSearched:NO]];
    NSDictionary *pagination = (NSDictionary*)[responseString JSONValue][@"pagination"];
    
    for(int i=0;i<tmp.count;i++)
    {
        if([tmp[i][@"media"][0][@"mediaType"] isEqualToString:@"image"] || [tmp[i][@"media"][0][@"mediaType"] isEqualToString:@"video"])
        {
            [facebookAlbumsArray addObject:tmp[i]];
            NSLog(@"%@,link %@",tmp[i][@"media"][0][@"mediaType"],tmp[i][@"media"][0][@"previewURLString"]);
        }
        
    }
    max_id = pagination[@"next_max_id"];
    
    [self.facebookAlbumsCollection reloadData];
}
-(NSArray*)getMyImagesWithToken:(NSString*)token andCount:(NSUInteger)count
{
    
    facebookAlbumsArray = [NSMutableArray new];
    /*
     
     -- Get users feed
      NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"https://api.instagram.com/v1/users/self/feed?access_token=%@&count=%lu",token,count]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
     
     */
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"https://api.instagram.com/v1/users/self/media/recent?access_token=%@&count=%d",token,10]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    NSError *error = nil; NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString* responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ;
    NSLog(@"%@",responseString);
    NSArray *tmp = [NSArray arrayWithArray:[self postsFromData:data isSearched:NO]];
    NSDictionary *pagination = (NSDictionary*)[responseString JSONValue][@"pagination"];
    
    for(int i=0;i<tmp.count;i++)
    {
        if([tmp[i][@"media"][0][@"mediaType"] isEqualToString:@"image"] || [tmp[i][@"media"][0][@"mediaType"] isEqualToString:@"video"])
        {
            [facebookAlbumsArray addObject:tmp[i]];
            NSLog(@"%@,link %@",tmp[i][@"media"][0][@"mediaType"],tmp[i][@"media"][0][@"previewURLString"]);
        }
        
        
    }
    max_id = pagination[@"next_max_id"];
    return facebookAlbumsArray;
}
-(NSArray*)getPostsWithToken:(NSString*)token andCount:(NSUInteger)count
{
    facebookAlbumsArray = [NSMutableArray new];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"https://api.instagram.com/v1/users/self/feed?access_token=%@&count=%lu",token,count]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    NSError *error = nil; NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSArray *tmp = [NSArray arrayWithArray:[self postsFromData:data isSearched:NO]];
    for(int i=0;i<tmp.count;i++)
    {
        if([tmp[i][@"media"][0][@"mediaType"] isEqualToString:@"image"] || [tmp[i][@"media"][0][@"mediaType"] isEqualToString:@"video"])
        {
            [facebookAlbumsArray addObject:tmp[i]];
            NSLog(@"%@,link %@",tmp[i][@"media"][0][@"mediaType"],tmp[i][@"media"][0][@"previewURLString"]);
        }
        
    
    }
    return facebookAlbumsArray;
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
                        NSDictionary* imageURLDict = [images objectForKey:@"standard_resolution"];
                        [mediaResultDict setObject:[imageURLDict objectForKey:@"url"] forKey:kPostMediaPreviewDictKey];
                    }
                }
                else
                {
                    if (dataDict[@"images"])
                    {
                        NSDictionary* images = [dataDict objectForKey:@"images"];
                        NSDictionary* imageURLDict = [images objectForKey:@"standard_resolution"];
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

#pragma CollectionView
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [facebookAlbumsArray count];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self getMore];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
   [self getMore];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"InstagramCollectionViewCell";
    InstagramCollectionViewCell *cell = (InstagramCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
       cell.albumCover.image = [UIImage imageNamed:@"placeholder"];
    
        self.indicator.center = cell.albumCover.center;
        self.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self.indicator startAnimating];
        [cell.albumCover addSubview:self.indicator];
        if([facebookAlbumsArray[indexPath.row][@"media"][0][@"mediaType"] isEqualToString:@"image"])
        {
            NSString *url = facebookAlbumsArray[indexPath.row][@"media"][0][@"mediaURL"];
            if(![self imageHandler:url andImageView:cell.albumCover])
            {
            
                [self downloadImage:url andIndicator:self.indicator addToImageView:cell.albumCover];
            
                
            }
            
        }
    else
    {
        NSString *url = facebookAlbumsArray[indexPath.row][@"media"][0][@"previewURLString"];
        if(![self imageHandler:url andImageView:cell.albumCover])
        {
            
            [self downloadImage:url andIndicator:self.indicator addToImageView:cell.albumCover];
            
        }
    
    }
    
   
    cell.albumName.text = facebookAlbumsArray[indexPath.row][@"text"];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *) indexPath {
    
    
            
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ActivityBuilder_4"
                                                         bundle:nil];
    MediaPickerViewController *m = (MediaPickerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MediaPicker"];
    m.curImage = [(InstagramCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath] albumCover].image;
    [self presentViewController:m animated:YES completion:NULL];
    
    
//    UIImageView *check = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 0, 0)];
//    [check setImage:[UIImage imageNamed:@"chek_icon_green_builder"]];
//    [(InstagramCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath] addSubview:check];
//    [UIView animateWithDuration:0.2 animations:^{
//        check.frame = CGRectMake(50, 40, 60, 60);
//    } completion:^(BOOL finished) {
//       [(InstagramCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath] setUserInteractionEnabled:NO];
//        
//        [UIView animateWithDuration:0.2 animations:^{
//            check.frame = CGRectMake(50, 40, 40, 40);
//        } completion:^(BOOL finished) {
//            
//        }];
//    }];

    
}
/*!
 * @discussion to download image by path and set image to appropriate image view
 * @param coverUrl absolute path to image
 * @param targetView set image here after download is complete
 */
-(void)downloadImage:(NSString *)coverUrl andIndicator:(UIActivityIndicatorView*)indicator addToImageView:(UIImageView*)targetView{
    __block UIImage *image = [UIImage new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:coverUrl]];
        image  = [UIImage imageWithData:imageData];
        dispatch_sync(dispatch_get_main_queue(), ^{
            targetView.image = image;
            
            if(image)
                [[[ABStoreManager sharedManager] imageCache] setObject:image forKey:coverUrl];
            [indicator stopAnimating];
        });
    });
    
    
}
#pragma mark Collection view layout things

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0;
}


- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(0,8,0,8);
}
-(void)test{
    
    if ([[ABStoreManager sharedManager] chatMode] ) {
        
        [[ABStoreManager sharedManager] setDoneEditing:YES];
        
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
        
    }else{
    
        [[ABStoreManager sharedManager] setDoneEditing:YES];
        
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
    }
}


@end
