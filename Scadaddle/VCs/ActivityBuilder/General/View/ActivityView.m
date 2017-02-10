//
//  ActivityView.m
//  ActivityCreator
//
//  Created by Roman Bigun on 5/6/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "ActivityView.h"
#import "ABStoreManager.h"
#import <QuartzCore/QuartzCore.h>

#define BTN_SIZE 30
#define MARGINE 10
@implementation ActivityView
{
    
    UIImageView * selectedImage;
    UIActivityIndicatorView * indicator;
    UIButton *selectBtn;
    BOOL isSelected;
    NSMutableArray *imagesIndexesToRemoveLater;
    BOOL isObjectVideo;
    UIImageView *videoIndicator;

}
@synthesize index,activityImage,markedForDeletion,curId,gName;

/*
 * @discussion Loading media Images/Video.
 * @param 'imagePath' path to image (local/web/from DB)
 * @param 'myIndex' current media index in the scroller
 * @param 'imId' id of media
 * @Param 'mediaTypeVideo' YES for Video and NO for others
*/
- (id)initWithFrame:(CGRect)frame activityImage:(NSString *)imagePath andIndex:(int)myIndex andId:(NSString *)imId mediaTypeVideo:(BOOL)isVideo
{
    
    self = [super initWithFrame:frame];
    if (self)
    {
        markedForDeletion = NO;
        index = myIndex;
        if(!imagesIndexesToRemoveLater)
            imagesIndexesToRemoveLater = [NSMutableArray new];
        
        if([[NSString stringWithFormat:@"%@",imagePath] containsString:@"i.ytimg.com"])
            isObjectVideo = YES;
        
        
        if([[NSString stringWithFormat:@"%@",imId] containsString:@"assets-library"] || [[NSString stringWithFormat:@"%@",imId] containsString:@"i.ytimg.com"])
        {
            curId = @"-1";//video or stored blob
        }
        else
        {
            curId = [NSString stringWithFormat:@"%@",imId];//media ID (comes from server)
        }
        self.backgroundColor = [UIColor clearColor];
        isSelected = NO;//Media has already selected for deletion/main
        activityImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:activityImage];
        
        indicator = [[UIActivityIndicatorView alloc] init];
        indicator.center = activityImage.center;
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [indicator startAnimating];
        [activityImage addSubview:indicator];
        
        selectedImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width/3, self.frame.size.height/3, 20, 20)];
        [self addSubview:selectedImage];
        
        if(isObjectVideo)
        {
            videoIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width/3, self.frame.size.height/3, 20, 20)];
            [videoIndicator setImage:[UIImage imageNamed:@"play_icon"]];
            [self addSubview:videoIndicator];
        }
        
        selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0, self.frame.size.width, self.frame.size.height)];
        [selectBtn addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:selectBtn];
        selectBtn.backgroundColor = [UIColor clearColor];

        
        [activityImage addObserver:self forKeyPath:@"image" options:0 context:NULL];//KVO
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BLDownloadImageNotification"
                                                            object:self
                                                          userInfo:@{@"activityUrl":imagePath,
                                                                     @"imageView":activityImage}];
        
        
        
        //Make it as a main image in case if it has no ID but has INDEX
        gName = [[NSString stringWithFormat:@"%@",imagePath] copy];
        int ci = [[NSString stringWithFormat:@"%@",
                   [[ABStoreManager sharedManager] editingMode]?[[ABStoreManager sharedManager] editingActivityObject][@"primaryActivityImgIndex"]:[[ABStoreManager sharedManager] ongoingActivity][@"primaryActivityImgIndex"]] intValue];
        if(index == ci && ![gName isEqualToString:@"photo_bg_small"] && !isObjectVideo){
            [self makeMain];
        }
        //Make it as a main image in case if it has ID
        NSString * da1 = [[ABStoreManager sharedManager] editingMode]?[[ABStoreManager sharedManager] editingActivityObject][@"primaryActivityImgId"]:[[ABStoreManager sharedManager] ongoingActivity][@"primaryActivityImgId"];
        if([[NSString stringWithFormat:@"%@",da1] isEqualToString:curId] && ![curId isEqualToString:@"-1"] && ![gName isEqualToString:@"photo_bg_small"] && !isObjectVideo)
        {
            [self makeMain];
        }
        
        NSArray * da = [[ABStoreManager sharedManager] editingMode]?[[ABStoreManager sharedManager] editingActivityObject][@"toRemoveActivityImgIds"]:[[ABStoreManager sharedManager] ongoingActivity][@"toRemoveActivityImgIds"];
        if([da isKindOfClass:[NSArray class]])
        {
            if(da.count>0)
            {
               for(int i=0;i<da.count;i++)
               {
                   int cnmi = [[NSString stringWithFormat:@"%@",da[i]] intValue];
                   if((cnmi==index || cnmi == [curId integerValue]) && !isSelected)
                   {
                       [selectedImage setImage:[UIImage imageNamed:@"delete_photo_icon"]];
                       if(isVideo)
                       {
                           videoIndicator.image=nil;
                       }
                       markedForDeletion = YES;
                    }
                   
                }
            }
         }
        long startIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:@"startIndexForDeletion"] integerValue];
        for(int i=0;i<[[ABStoreManager sharedManager] deleteImagesWithIndexes].count;i++)
        {
        
            if([[[ABStoreManager sharedManager] deleteImagesWithIndexes][i] integerValue]==index-startIndex)
            {
                if(![gName isEqualToString:@"photo_bg_small"])
                {
                    [selectedImage setImage:[UIImage imageNamed:@"delete_photo_icon"]];
                    if(isVideo)
                    {
                        videoIndicator.image=nil;
                    }
                    markedForDeletion = YES;
                }
            
            }
        
        }
        
        
    }
    if([[NSString stringWithFormat:@"%@",imId] containsString:@"assets-library"])
    {
        curId = [NSString stringWithFormat:@"%d",-1];
    }
    
    return self;
}
/*!
 * @discussion to scale image @param image [image to be scaled] with size @param newSize new image size
 */
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}
- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [activityImage removeObserver:self forKeyPath:@"image"];
  
}
/*!
 * @discussion  Remove badges on media in the scroller
 */
-(void)setSelectedNO
{
    
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BLDeselectActivitiesNotification"
                                                            object:self
                                                          userInfo:@{@"exceptIndex":[NSString stringWithFormat:@"%i",index]}];
        
    
    
          
    
}
/*!
 * Deselect selected media 'as main' image
 */
-(void)deselectMe
{
        [selectedImage setImage:nil];
        isSelected = NO;
        [[ABStoreManager sharedManager] selectActivity:NO];
}
/*!
 * @discussion Mark current media for deletion
 */
-(void)markDeleted
{

    
    if([gName isEqualToString:@"photo_bg_small"] || isSelected)
    {
        return;
        
    }
    markedForDeletion = YES;
    [selectedImage setImage:[UIImage imageNamed:@"delete_photo_icon"]];
    
    int ci = [curId intValue];
    if(ci != -1 )
    {
        [[ABStoreManager sharedManager] markForDeletion:curId];
    }
    else
    {
        
    }
    if(isObjectVideo)
    {
        
        videoIndicator.image = nil;
        
    }
    
}
/*!
 * @discussion Mark image as main image for Activity
 */
-(void)makeMain
{
    if(!isObjectVideo)
    {
        [selectedImage setImage:[UIImage imageNamed:@"main_photo_icon"]];
        isSelected = YES;
        [[ABStoreManager sharedManager] selectActivity:YES];
        
        if((![[ABStoreManager sharedManager] editingMode] && index==0) && [[ABStoreManager sharedManager] ongoingActivity][@"primaryActivityImgId"]==nil)
        {
            [[ABStoreManager sharedManager] addData:[NSNumber numberWithInt:index] forKey:@"primaryActivityImgIndex"];
        }
        
        if([curId intValue]!=-1 && curId!=nil)
        {
          [[ABStoreManager sharedManager] addData:curId forKey:@"primaryActivityImgId"];
          [[ABStoreManager sharedManager] addData:[NSNumber numberWithInt:-1] forKey:@"primaryActivityImgIndex"];
        }
        else
        {
        
            [[ABStoreManager sharedManager] addData:[NSNumber numberWithInt:-1] forKey:@"primaryActivityImgId"];
            [[ABStoreManager sharedManager] addData:[NSNumber numberWithInt:index] forKey:@"primaryActivityImgIndex"];
        
        }
       [self setSelectedNO];
    }
}
/*!
 * @discussion Restore video which has been marked for deletion
 */
-(void)restoreVideo
{

    [[NSNotificationCenter defaultCenter] postNotificationName:@"ABActivityImageManager"
                                                        object:self
                                                      userInfo:@{@"exceptIndex":[NSString stringWithFormat:@"%i",index],
                                                                 @"image":activityImage.image,
                                                                 @"object":self,
                                                                 @"hideButtons":isSelected?@"1":@"0",
                                                                 @"restore":@"1",
                                                                 @"video":isObjectVideo?@"1":@"0"}];

}
/*!
 * @discussion Remove badge 'Deleted' from current media
 */
-(void)unmarkMe
{

    markedForDeletion = NO;
    if([curId isEqualToString:@"-1"])
    {
        
    }
    else
    {
        [[ABStoreManager sharedManager] unmarkForDeletion:curId];
    }
    
    [selectedImage setImage:nil];
    if(isObjectVideo)
    {
        [videoIndicator setImage:[UIImage imageNamed:@"play_icon"]];
        NSLog(@"YOUTUBE BEFORE RESTORE %@",[[ABStoreManager sharedManager] youtubeObjectsToRemoveO]);
        
        for(int i=0;i<[[ABStoreManager sharedManager] youtubeObjects].count;i++){
            if([[[ABStoreManager sharedManager] youtubeObjects][i][@"img"] isEqualToString:gName])
            {
                [[ABStoreManager sharedManager] restoreYoutubeFromRemove:[[ABStoreManager sharedManager] youtubeObjects][i]];
                
            }
            
        }
        
        NSLog(@"YOUTUBE AFTER RESTORE %@",[[ABStoreManager sharedManager] youtubeObjectsToRemoveO]);
    }
    
}
-(IBAction)selectAction:(UIButton*)sender
{

    if([gName isEqualToString:@"photo_bg_small"])
    {
        return;
        
    }
    if(markedForDeletion)
    {
        
        [self restoreVideo];
        return;
           
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ABActivityImageManager"
                                                                object:self
                                                              userInfo:@{@"exceptIndex":[NSString stringWithFormat:@"%i",index],
                                                                         @"image":activityImage.image,
                                                                         @"path":gName,
                                                                         @"object":self,
                                                                         @"hideButtons":isSelected?@"1":@"0",
                                                                         @"hideMain":isObjectVideo?@"1":@"0"}];
    
   
}
 /*!
  * @discussion KVO
  */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"image"])
    {
        [indicator stopAnimating];
        
    }
}

@end
