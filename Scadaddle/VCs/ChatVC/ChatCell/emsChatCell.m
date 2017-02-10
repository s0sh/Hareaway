//
//  emsChatCell.m
//  Fishy
//
//  Created by developer on 11/03/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsChatCell.h"
#import <QuartzCore/QuartzCore.h>
#import "ABStoreManager.h"
const CGFloat WidthOffset = 30.0f;
const CGFloat ImageSize = 50.0f;
@implementation emsChatCell

- (void)layoutSubviews
{
    [self updateFramesForAuthorType:self.authorType];
}

- (void)setAuthorType:(AuthorType)type
{
    _authorType = type;
    [self updateFramesForAuthorType:_authorType];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _bubbleView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _dateLable = [[UILabel alloc] initWithFrame:CGRectZero];
        _arrowImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        _statusImage= [[UIImageView alloc] initWithFrame:CGRectZero];
        _circleImage= [[UIImageView alloc] initWithFrame:CGRectZero];
        _twitterButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _fbButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _attachView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _showImageBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_circleImage];
        [self.contentView addSubview:_dateLable];
        [self.contentView addSubview:_bubbleView];
        [self.contentView addSubview:_arrowImage];
        [self.contentView addSubview:_statusImage];
        [self.contentView addSubview:_twitterButton];
        [self.contentView addSubview:_fbButton];
        [self.contentView addSubview:_attachView];
        self.dateLable.font = [UIFont fontWithName:@"MyriadPro-Cond" size:9];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.numberOfLines = 0;
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.textLabel.textColor = [UIColor blackColor];
        self.textLabel.font = [UIFont fontWithName:@"MyriadPro-Cond" size:14];
        self.textLabel.textColor = [UIColor colorWithRed:51/255 green:51/255 blue:51/255 alpha:0.7];
        
        
        
        
        
    }
    
    return self;
}
- (void)updateFramesForAuthorType:(AuthorType)type
{
    CGSize size;
    CGSize sizeDate;
    CGFloat minInset = 0.0f;
    if([self.dataSource respondsToSelector:@selector(minInsetForCell:atIndexPath:)])
    {
        minInset = [self.dataSource minInsetForCell:self atIndexPath:[[self tableView] indexPathForCell:self]];
    }
    
    sizeDate = [self.dateLable.text sizeWithFont:self.dateLable.font constrainedToSize:CGSizeMake(self.frame.size.width - minInset - WidthOffset - ImageSize - 8.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    
    size = [self.textLabel.text sizeWithFont:[UIFont fontWithName:@"MyriadPro-Cond" size:14] constrainedToSize:CGSizeMake(self.frame.size.width - minInset - WidthOffset - ImageSize -12.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    
    if(type == cellAuthorTypeSelf)
    {
        [self setImageForBubbleColor];
        
        self.bubbleView.frame = CGRectMake(self.frame.size.width - (size.width + WidthOffset) - ImageSize - 3.0f, self.frame.size.height - (size.height + 33.0f) -8, size.width + WidthOffset -10, size.height + 24.0f);
        self.imageView.frame = CGRectMake(self.frame.size.width - ImageSize - 5.0f, self.frame.size.height - ImageSize - 12.0f, ImageSize, ImageSize);
        self.textLabel.frame = CGRectMake(self.frame.size.width - (size.width + WidthOffset - 10.0f) - ImageSize - 8.0f, self.frame.size.height - (size.height + 27.0f) -4, size.width + WidthOffset - 23.0f, size.height+10);
        self.dateLable.frame =  CGRectMake(/*self.frame.size.width - sizeDate.width - ImageSize - WidthOffset +15*/10,/* self.imageView.frame.origin.y +(self.imageView.frame.size.height)*/self.imageView.frame.origin.y ,sizeDate.width,11);
        self.statusImage.frame =CGRectMake(self.frame.size.width - self.dateLable.frame.size.width- ImageSize - WidthOffset+4 , self.imageView.frame.origin.y +(self.imageView.frame.size.height)+2  ,7,7);
        _circleImage.image = [UIImage imageNamed:@"user1"];
        _circleImage.frame = CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y - size.height +24, self.imageView.frame.size.width-9, self.imageView.frame.size.height-9);
        _arrowImage.frame =  CGRectMake(self.frame.size.width - ImageSize -WidthOffset +13, _circleImage.frame.origin.y +10 ,7,11);
        _twitterButton.frame = CGRectMake(22,  self.imageView.frame.origin.y +10 ,44, 44);
        [_twitterButton setImage:[UIImage imageNamed:@"twitter"] forState:UIControlStateNormal];
        _fbButton.frame = CGRectMake(-5,  self.imageView.frame.origin.y +10 ,44, 44);
        [_fbButton setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
        self.arrowImage.image = [UIImage imageNamed:@"Bubble_greeen_part"];
        self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.bubbleView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.bubbleView.transform = CGAffineTransformIdentity;
        
        self.attachView.frame = CGRectMake(90,  20 ,160,80);
        
        if ( self.attachView.image !=nil) {
            
            _showImageBtn.frame = self.attachView.frame;
            [self.contentView addSubview:_showImageBtn];
            
            self.bubbleView.frame = CGRectMake(86,16 , 160 + WidthOffset - 18, 80 + 10.0f);
           // self.bubbleView.frame = CGRectMake(138,10 , 100 + WidthOffset -10, 100 + 20.0f);
            _circleImage.frame = CGRectMake(self.imageView.frame.origin.x,12, self.imageView.frame.size.width-9, self.imageView.frame.size.height-9);
            _arrowImage.frame =  CGRectMake(self.frame.size.width - ImageSize -WidthOffset +13, _circleImage.frame.origin.y +10 ,7,11);
            _fbButton.hidden = YES;
            _twitterButton.hidden = YES;
        }
        
        NSString *string = @"http://scad";
        
        if ([self.textLabel.text rangeOfString:string].location != NSNotFound) {
            self.attachView.image =[UIImage imageNamed:@"send_chat"];
            _showImageBtn.frame = self.attachView.frame;
            [self.contentView addSubview:_showImageBtn];
            
            self.bubbleView.frame = CGRectMake(86,16 , 160 + WidthOffset - 18, 80 + 10.0f);
            _circleImage.frame = CGRectMake(self.imageView.frame.origin.x,12, self.imageView.frame.size.width-9, self.imageView.frame.size.height-9);
            _arrowImage.frame =  CGRectMake(self.frame.size.width - ImageSize -WidthOffset +13, _circleImage.frame.origin.y +10 ,7,11);
            _fbButton.hidden = YES;
            _twitterButton.hidden = YES;
            self.textLabel.hidden = YES;
     
            if(![self imageHandlerInterest:self.textLabel.text andInterestView:_attachView])
            {
                [self downloadImage:self.textLabel.text andIndicator:nil addToImageView:_attachView andImageName:self.textLabel.text];
            }
            
        }
        
    }
    else
    {
        [self setImageForBubbleColorGray];
        self.bubbleView.frame = CGRectMake(ImageSize + 13.0f, self.frame.size.height - (size.height + 15.0f)-22, size.width + WidthOffset-10, size.height  + 20.0f);
        self.imageView.frame = CGRectMake(5.0, self.frame.size.height - ImageSize - 12.0f, ImageSize, ImageSize);
        self.textLabel.frame = CGRectMake(ImageSize + 8.0f + 16.0f, self.frame.size.height - (size.height + 15.0f) -13, size.width + WidthOffset - 23.0f, size.height+10);
        self.dateLable.frame =  CGRectMake(/*ImageSize +15*/270,/* self.imageView.frame.origin.y +(self.imageView.frame.size.height)*/  self.imageView.frame.origin.y ,sizeDate.width,11);
        self.arrowImage.image = [UIImage imageNamed:@"Bubble_gray_part"];
        _circleImage.image = [UIImage imageNamed:@"user1"];
        _circleImage.frame = CGRectMake(self.imageView.frame.origin.x,self.imageView.frame.origin.y - size.height +24, self.imageView.frame.size.width-9, self.imageView.frame.size.height-9);
        _arrowImage.frame =  CGRectMake( ImageSize +11,  _circleImage.frame.origin.y +10 ,7,11);
        _twitterButton.frame = CGRectMake(279,  self.imageView.frame.origin.y +10 ,44, 44);
        [_twitterButton setImage:[UIImage imageNamed:@"twitter"] forState:UIControlStateNormal];
        _fbButton.frame = CGRectMake(252,  self.imageView.frame.origin.y +10 ,44, 44);
        [_fbButton setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
        self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.bubbleView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.bubbleView.transform = CGAffineTransformIdentity;
        self.bubbleView.transform = CGAffineTransformMakeScale(-1.0f, 1.0f);
        
        self.attachView.frame = CGRectMake(70,  14 ,160,80);
       
        if ( self.attachView.image !=nil) {
            self.bubbleView.frame = CGRectMake(ImageSize + 13.0f ,10 , 100 + WidthOffset -10, 100 + 22.0f);
            _circleImage.frame = CGRectMake(self.imageView.frame.origin.x,12, self.imageView.frame.size.width-9, self.imageView.frame.size.height-9);
            _arrowImage.frame =  CGRectMake( ImageSize +11,  _circleImage.frame.origin.y +10 ,7,11);
            _fbButton.hidden = YES;
            _twitterButton.hidden = YES;
        }
        
        NSString *string =  @"http://scad" ;
        
        if ([self.textLabel.text rangeOfString:string].location != NSNotFound) {
            _showImageBtn.frame = self.attachView.frame;
            [self.contentView addSubview:_showImageBtn];
          //  self.bubbleView.frame = CGRectMake(86,16 , 160 + WidthOffset - 20, 80 + 8.0f);
            self.bubbleView.frame = CGRectMake(ImageSize + 13.0f ,10 , 160 + WidthOffset -20, 80 + 8.0f);
            _circleImage.frame = CGRectMake(self.imageView.frame.origin.x,12, self.imageView.frame.size.width-9, self.imageView.frame.size.height-9);
            _arrowImage.frame =  CGRectMake( ImageSize +11,  _circleImage.frame.origin.y +10 ,7,11);
            _fbButton.hidden = YES;
            _twitterButton.hidden = YES;
            self.textLabel.hidden = YES;
            
          //  _attachView.contentMode = UIViewContentModeScaleAspectFill;
        
            [_attachView setClipsToBounds:YES];
            
            if(![self imageHandlerInterest:self.textLabel.text andInterestView:_attachView])
            {
                
                [self downloadImage:self.textLabel.text andIndicator:nil addToImageView:_attachView andImageName:self.textLabel.text];
            }
            
        }
    }
    
    if(![self imageHandlerInterest:[NSString stringWithFormat:@"%@%@",SERVER_PATH,self.imageUrl] andInterestView:_circleImage])
    {
        
        [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,self.imageUrl] andIndicator:nil addToImageView:_circleImage andImageName:[NSString stringWithFormat:@"%@%@",SERVER_PATH,self.imageUrl]];
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString: self.textLabel.text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:4];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self.textLabel.text length])];
    self.textLabel.attributedText = attributedString ;
    
    [self cornerIm:_circleImage];
}
- (void)setImageForBubbleColorGray
{
    self.bubbleView.image = [[UIImage imageNamed:[NSString stringWithFormat:@"Bubble_gray"]] resizableImageWithCapInsets:UIEdgeInsetsMake(11.0f, 15.0f, 16.0f, 18.0f)];
}

- (void)setImageForBubbleColor
{
    self.bubbleView.image = [[UIImage imageNamed:[NSString stringWithFormat:@"Bubble_green"]] resizableImageWithCapInsets:UIEdgeInsetsMake(11.0f, 15.0f, 16.0f, 18.0f)];
}

- (UITableView *)tableView
{
    UIView *tableView = self.superview;
    
    while(tableView)
    {
        if([tableView isKindOfClass:[UITableView class]])
        {
            return (UITableView *)tableView;
        }
        
        tableView = tableView.superview;
    }
    
    return nil;
}
-(void)cornerIm:(UIImageView*)imageView{
    imageView .layer.cornerRadius =  imageView.bounds.size.width/2;
    UIColor *color = [UIColor colorWithRed:139/255.0 green:185/255.0 blue:172/255.0 alpha:1];
    [imageView.layer setBorderColor:color.CGColor];
    [imageView.layer setBorderWidth:1.0];
    imageView.layer.masksToBounds = YES;
}
/*!
 * @discussion to download image by path and set image to appropriate image view
 * @param coverUrl absolute path to image
 * @param targetView set image here after download is complete
 * @param imageName we use it as a unique key to save image in cache
 */
-(void)downloadImage:(NSString *)coverUrl andIndicator:(UIActivityIndicatorView*)indicator addToImageView:(UIImageView*)targetView andImageName:(NSString*)imageName{
    __block UIImage *image = [UIImage new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:coverUrl]];
        image  = [UIImage imageWithData:imageData];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [indicator stopAnimating];
            if (image == nil) {
                
                targetView.image = [UIImage imageNamed:@"placeholder"];
                
            }else{
            
               targetView.image = image;
                
                if(image){
                    
                [[[ABStoreManager sharedManager] imageCache] setObject:image forKey:imageName];
                    
                }
            }
        });
    });
    
    
}

/*!
 * @discussion  check whether image with path @param path cached or not.
 * If cached. add image to target else returns NO to start download
 * @param imageView image view to add retrived from cache image
 * @param path path to image
 */
-(BOOL)imageHandlerInterest:(NSString*)path andInterestView:(UIImageView *)imageView
{
    UIImage *image = [[[ABStoreManager sharedManager] imageCache] objectForKey:path];
    
    if(image)
    {
        imageView.image = image;
        
        return YES;
    }
    
    imageView.image = [UIImage imageNamed:@"placeholder"];
    
    return NO;
}

@end


