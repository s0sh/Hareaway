//
//  emsMapEssenceView.m
//  Scadaddle
//
//  Created by developer on 14/05/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsMapEssenceView.h"
#import "emsMapEssence.h"
#import  "emsMapEssentionAnnotation.h"
#import "ABStoreManager.h"

@interface emsMapEssenceView ()
@property (nonatomic, strong) NSNumber *anID;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIButton *disclosureButton;
@property (nonatomic, strong) FollowBlock followBlock;
@property (nonatomic, strong) DeleteBlock deleteBlock;
@property (nonatomic, strong) InfoBlock infoBlock;
@property (nonatomic, strong) CloseSelfOnMap closeSelfOnMap;
@property (nonatomic, strong) CAShapeLayer *bgLayer;
@property (nonatomic, strong) UIImageView *blueView;
@property (nonatomic, strong) UIImageView *interestImage;
@property (nonatomic, strong) UIImageView *alfaView;
@property (nonatomic, strong) UIImageView *bgView;
@property (nonatomic, strong) UILabel *aditionalLablel;
@property (nonatomic, strong) UILabel *infoLabel;


@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UIButton *infoButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *infoButtonForImage;
@property (nonatomic, strong) UIButton *closeSelfButton;

@property (nonatomic, assign) MapEssenceViewState state;

@property (nonatomic, assign) MapEssenceType viewType;

@end


@implementation emsMapEssenceView

#pragma mark - Setup

-(void)dealloc{

    [self removeFromSuperview];
    NSLog(@"  dealloc  %@",self);
}

- (id)initWithAnnotation:(id<MKAnnotation>)annotation {
    self = [super initWithAnnotation:annotation reuseIdentifier:0];
    
    if (self) {
        self.canShowCallout = NO;
        self.frame = CGRectMake(0, 0, MapEssenceViewStandardWidth, MapEssenceViewStandardHeight);
        self.backgroundColor = [UIColor whiteColor];
        self.centerOffset = CGPointMake(0, -MapEssenceViewVerticalOffset);
        self.backgroundColor = [UIColor clearColor];
        _state = MapEssenceViewStateCollapsed;
        [self setupView];
    }
    
    return self;
}

-(void)showSubviews{
    _bgView.hidden = NO;
    _alfaView.hidden = NO;
    _likeButton.hidden = NO;
    _deleteButton.hidden = NO;
    _infoButtonForImage.hidden = NO;
    _infoButton.hidden = NO;
   _infoLabel.hidden = NO;
    _closeSelfButton.hidden = NO;
}

-(void)showSubviewsHide{
    _bgView.hidden = YES;
    _alfaView.hidden = YES;
    _likeButton.hidden = YES;
    _infoButtonForImage.hidden = YES;
    _deleteButton.hidden = YES;
    _infoButton.hidden = YES;
    _infoLabel.hidden = YES;
    _closeSelfButton.hidden = YES;
}

- (void)setupView {
    [self setupAlfaView];
    [self setupImageView];
    [self setupInterestImage ];
    [self setupBlueImage ];
    [self setupTitleLabel];
    [self setupSubtitleLabel];
    [self setupYardLabel];
//--
    [self setupMainView];
    [self setupInfoButtonForImage ];
    [self setupAlfaView];
    [self setupLikeButton];
    
    [self setupInfoButton];
    [self setupDiscriptionLabel];
    [self setupcloseSelfButton];
    
}

- (void)setupImageView {
     _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, MapEssenceViewStandardWidth, MapEssenceViewStandardHeight)];
    _imageView.autoresizingMask =  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;
    _imageView.image = [[UIImage imageNamed:[NSString stringWithFormat:@"info_block_map"]] resizableImageWithCapInsets:UIEdgeInsetsMake(12.0f, .0f, 16.0f, .0f)];
    _imageView.clipsToBounds = YES;
    [self addSubview:_imageView];
}

- (void)setupBlueImage {
    _blueView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,34,34)];
    _blueView.image = [UIImage imageNamed:@"blue_frame"];
    [self addSubview:_blueView];
}

- (void)setupInterestImage {
    _interestImage = [[UIImageView alloc] initWithFrame:CGRectMake(2.0f, 0.0f,32,32)];
    _interestImage.image = [UIImage imageNamed:@"swimming_interests"];
    [self addSubview:_interestImage];
}
- (void)setupTitleLabel {
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(38.0f, 8.0f,90.0f, 20.0f)];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.font = [UIFont fontWithName:@"MyriadPro-Cond" size:14];
    [_titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self addSubview:_titleLabel];
}
- (void)setupSubtitleLabel {
    _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(132.0f, 4.0f, 40.0f, 20.0f)];
    _subtitleLabel.textColor = [UIColor blackColor];
    _subtitleLabel.font = [UIFont fontWithName:@"MyriadPro-Cond" size:14];;
    _subtitleLabel.backgroundColor = [UIColor clearColor];
    _subtitleLabel.text = @"1502";
    _subtitleLabel.textAlignment = NSTextAlignmentJustified;
    [self addSubview:_subtitleLabel];
}
- (void)setupYardLabel {
    UILabel *yd= [[UILabel alloc] initWithFrame:CGRectMake(138.0f, 15.0f, 32.0f, 20.0f)];
    yd.textColor = [UIColor blackColor];
    yd.font = [UIFont fontWithName:@"MyriadPro-Cond" size:8];;
    yd.backgroundColor = [UIColor clearColor];
    yd.text = @"YD";
    [self addSubview:yd];
}

- (void)setupAlfaView {
    _alfaView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 87, 155.0f, 42.0f)];
    _alfaView.backgroundColor = [UIColor whiteColor];
    _alfaView.alpha = 0.7;
    _alfaView.hidden = YES;

    
    CALayer *mask = [CALayer layer];
    mask.contents = (id)[[UIImage imageNamed:@"info_block_map"]CGImage];
    mask.frame = CGRectMake(0 , -0, 155, 42.0f);
    _alfaView.layer.mask = mask;
    _alfaView.layer.masksToBounds = YES;
    
   [self addSubview:_alfaView];
}
- (void)setupLikeButton {
    //_likeButton = [[ UIButton alloc] initWithFrame:CGRectMake(130, 93, 22.0f, 22.0f)];
     _likeButton = [[ UIButton alloc] initWithFrame:CGRectMake(124, 86, 33.0f, 33.0f)];
    [_likeButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [_likeButton setContentMode:UIViewContentModeCenter];
    [_likeButton addTarget:self action:@selector(likeBtn) forControlEvents:UIControlEventTouchUpInside];
    [_likeButton setImage:[UIImage imageNamed:@"follow"] forState:UIControlStateNormal];
    _likeButton.hidden = YES;
    [self addSubview:_likeButton];
}
- (void)setupDeleteButton {
   // _deleteButton = [[ UIButton alloc] initWithFrame:CGRectMake(78, 93, 22.0f, 22.0f) ];
    _deleteButton = [[ UIButton alloc] initWithFrame:CGRectMake(64, 86, 33.0f, 33.0f) ];
    [_deleteButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [_deleteButton setContentMode:UIViewContentModeCenter];
    [_deleteButton addTarget:self action:@selector(delBtn) forControlEvents:UIControlEventTouchUpInside];
    [_deleteButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    _deleteButton.hidden = YES;
    [self addSubview:_deleteButton];
}
- (void)setupInfoButton {
   // _infoButton = [[ UIButton alloc] initWithFrame:CGRectMake(104, 93, 22.0f, 22.0f)];
    _infoButton = [[ UIButton alloc] initWithFrame:CGRectMake(94, 86, 33.0f, 33.0f)];
    [_infoButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [_infoButton setContentMode:UIViewContentModeCenter];
    [_infoButton addTarget:self action:@selector(infoBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [_infoButton setImage:[UIImage imageNamed:@"info"] forState:UIControlStateNormal];
    _infoButton.hidden = YES;
    [self addSubview:_infoButton];
}

- (void)setupMainView {
    _bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0 , 33, 155, 116.0f)];
    _bgView.image =[UIImage imageNamed:@"placeholder"];
    _bgView.hidden = YES;
    CALayer *mask = [CALayer layer];
    mask.contents = (id)[[UIImage imageNamed:@"info_block_map_190"]CGImage];
    mask.frame = CGRectMake(0 , -0, 155, 96.0f);
     _bgView.layer.mask = mask;
     _bgView.layer.masksToBounds = YES;
    
    [_imageView addSubview:_bgView];
}

- (void)setupDiscriptionLabel {

    _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(2.0f, 94.0f, 70.0f, 20.0f)];
    _infoLabel.textColor = [UIColor blackColor];
      _infoLabel.numberOfLines = 3;
    _infoLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:9];
    _infoLabel.hidden = YES;
    [self addSubview:_infoLabel];
}


- (void)setupInfoButtonForImage {
    _infoButtonForImage = [[ UIButton alloc] initWithFrame:_bgView.frame];
    [_infoButtonForImage addTarget:self action:@selector(infoBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    _infoButtonForImage.hidden = YES;
    [self addSubview:_infoButtonForImage];
}
- (void)setupcloseSelfButton {
    _closeSelfButton = [[ UIButton alloc] initWithFrame:CGRectMake(0, 0, MapEssenceViewStandardWidth, MapEssenceViewStandardHeight)];
    _closeSelfButton.backgroundColor = [UIColor clearColor];
    [_closeSelfButton addTarget:self action:@selector(closeSelfOnMapPressed) forControlEvents:UIControlEventTouchUpInside];
    _closeSelfButton.hidden = YES;
    [self addSubview:_closeSelfButton];
}


- (void)didDeselectAnnotationViewInMap:(MKMapView *)mapView {
       [self shrink];
    
}

- (void)shrink {
    
    if (self.state != MapEssenceViewStateExpanded) return;
    
    self.state = MapEssenceViewStateAnimating;
    
    [UIView animateWithDuration:MapEssenceViewAnimationDuration/2.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                
                            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y+42.5, self.frame.size.width, self.frame.size.height-MapEssenceViewExpandOffset/2);
                         
                                              [self showSubviewsHide ];
                       
                     }
                     completion:^(BOOL finished) {
                        self.state = MapEssenceViewStateCollapsed;
                     }];
    
}
/*!
 * @discussion to download image by path and set image to appropriate image view
 * @param coverUrl absolute path to image
 * @param targetView set image here after download is complete
 * @param imageName we use it as a unique key to save image in cache
 */

-(void)downloadImage:(NSString *)coverUrl andIndicator:(UIActivityIndicatorView*)indicator addToImageView:(UIImageView*)targetView andImageName:(NSString*)imageName{
    UIImage *image = [UIImage new];
           NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:coverUrl]];
        image  = [UIImage imageWithData:imageData];
    if (image == nil) {
        
                targetView.image = [UIImage imageNamed:@"placeholder"];
        
    }else{
                targetView.image = image;
        if(image){
                [[[ABStoreManager sharedManager] imageCache] setObject:image forKey:imageName];
        }
    }
    
}
#pragma mark - Updating

- (void)updateWithThumbnail:(emsMapEssence *)mapEssence {
    self.subtitleLabel.text = mapEssence.distance;
    self.titleLabel.text = mapEssence.title;
    self.infoLabel.text = mapEssence.subtitle;
    self.deleteBlock = mapEssence.deleteBlock;
    self.followBlock = mapEssence.followBlock;
    self.infoBlock= mapEssence.infoBlock;
    
    
   
    
    
    
    if (mapEssence.interestImageUrl && [mapEssence.interestImageUrl length]>2) {
            
          if(![self imageSatusHandler:mapEssence.interestImageUrl])
        {
            
            [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,mapEssence.interestImageUrl]
                   andIndicator:nil addToImageView: self.interestImage andImageName:mapEssence.interestImageUrl];
            
        }
    }


    if (mapEssence.annotationImageUrl &&  [mapEssence.interestImageUrl length]>2) {
        
        if(![self imageAnnotationHandler:mapEssence.annotationImageUrl])
        {
            
            [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,mapEssence.annotationImageUrl]
                   andIndicator:nil addToImageView: _bgView andImageName:mapEssence.annotationImageUrl];
            
        }
            
}
    self.closeSelfOnMap = mapEssence.closeSelfOnMap;
    self.viewType = mapEssence.essenceType;
    if (mapEssence.essenceType != rewardEssence) {
        [self setupDeleteButton];
    }
}

#pragma mark - MapEssenceViewProtocol

- (void)didSelectAnnotationViewInMap:(MKMapView *)map {
    [self expand];
}

- (void)expand {
    if (self.state != MapEssenceViewStateCollapsed) return;
    self.state = MapEssenceViewStateAnimating;
    [self expandView];
}

-(void)expandView{
    [UIView animateWithDuration:MapEssenceViewAnimationDuration animations:^{
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y-42.5, self.frame.size.width, self.frame.size.height+MapEssenceViewExpandOffset/2);
     [self showSubviews ];
        
    } completion:^(BOOL finished) {
        self.state = MapEssenceViewStateExpanded;
    }];
    
}

-(void)deleteAnimation{
    
    [UIView animateWithDuration:MapEssenceViewAnimationDuration animations:^{
        self.frame = CGRectMake(self.frame.origin.x+200, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        self.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
    
        self.state = MapEssenceViewStateExpanded;
        if (self.deleteBlock){
            self.deleteBlock(self.annotation);
        }

    }];
}

-(void)followAnimation{

    [UIView animateWithDuration:MapEssenceViewAnimationDuration animations:^{
        
        self.frame = CGRectMake(self.frame.origin.x-200, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        self.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        
        if (self.followBlock){
            self.followBlock(self.annotation);
        }
        self.state = MapEssenceViewStateExpanded;
    }];
}
-(void)likeBtn{
    
    [self followAnimation];
    
}
-(void)delBtn{
    [self deleteAnimation ];
}
-(void)infoBtnPressed{
    
    if (self.infoBlock){
        self.infoBlock();
    }
}

-(void)closeSelfOnMapPressed{
    
    if (self.closeSelfOnMap){
        self.closeSelfOnMap(self.annotation);
    }
}


-(BOOL)imageAnnotationHandler:(NSString*)path
{
    UIImage *image = [[[ABStoreManager sharedManager] imageCache] objectForKey:path];
    
    if(image)
    {
        _bgView.image = image;
        
        return YES;
    }
    
    _bgView.image = [UIImage imageNamed:@"placeholder"];
    
    return NO;
}


-(BOOL)imageSatusHandler:(NSString*)path
{
    
    UIImage *image = [[[ABStoreManager sharedManager] imageCache] objectForKey:path];
    
    if(image)
    {

        self.interestImage.image = image;
        
        return YES;
    }
    
     self.interestImage.image = [UIImage imageNamed:@"placeholder"];
    
    return NO;
}
@end
