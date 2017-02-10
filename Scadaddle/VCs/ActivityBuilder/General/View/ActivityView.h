//
//  ActivityView.h
//  ActivityCreator
//
//  Created by Roman Bigun on 5/6/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityView : UIView
- (id)initWithFrame:(CGRect)frame
         activityImage:(NSString *)imagePath andIndex:(int)index andId:(NSString *)imId mediaTypeVideo:(BOOL)isVideo;


@property int index;
@property(nonatomic,retain)NSString *curId;
@property(nonatomic,retain)UIImageView * activityImage;
@property(nonatomic,retain)NSString *gName;
@property BOOL markedForDeletion;
@property BOOL isObjectVideo;
/*!
 * @discussion to deselect image at all [select type could be delete/video/main]
 */
-(void)deselectMe;
/*!
 * @discussion to make image as main for the activity
 */
-(void)makeMain;
/*!
 * @discussion mark an item as to be deleted
 */
-(void)markDeleted;
-(void)unmarkMe;
@end
