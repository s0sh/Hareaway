//
//  emsChatCell.h
//  Fishy
//
//  Created by developer on 11/03/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol emsChatCellDataSource, emsChatCellDelegate;

typedef NS_ENUM(NSUInteger, AuthorType) {
    cellAuthorTypeSelf = 0,
    cellAuthorTypeOther
};

@interface emsChatCell : UITableViewCell
@property (nonatomic, strong, readonly) UIImageView *bubbleView;
@property (nonatomic, strong, readonly) UIImageView *attachView;
@property (nonatomic, strong, readonly) UIImageView *circleImage;
@property (nonatomic, strong, readonly) UIImageView *arrowImage;
@property (nonatomic, strong, readonly) UIImageView *statusImage;
@property (nonatomic, strong, readonly) UILabel *dateLable;
@property (nonatomic, strong, readonly) UIButton *twitterButton;
@property (nonatomic, strong, readonly) UIButton *fbButton;
@property (nonatomic, strong, readonly) UIButton *showImageBtn;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, assign) AuthorType authorType;
@property (nonatomic, weak) id <emsChatCellDataSource> dataSource;
@property (nonatomic, weak) id <emsChatCellDelegate> delegate;
@end


@protocol emsChatCellDataSource <NSObject>
@optional
- (CGFloat)minInsetForCell:(emsChatCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@protocol emsChatCellDelegate <NSObject>
@optional
- (void)tappedImageOfCell:(emsChatCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end
