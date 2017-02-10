//
//  emsLeftMenuVC.m
//  Scadaddle
//
//  Created by developer on 14/04/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsLeftMenuVC.h"
#import "emsMenuCell.h"
#import "emsMainScreenVC.h"
#import "emsProfileVC.h"
#import "DSViewController.h"
#import "IceCreamViewController.h"
//#import "emsLoginVC.h"
#import "emsDeviceManager.h"
#import "DSViewController.h"
#import "IceCreamViewController.h"
#import "emsLogic.h"
#import "emsMapVC.h"
#import "Constants.h"
#import "emsActivityVC.h"
#import "ActivityGeneralViewController.h"
#import "NotebookViewController.h"
#import "emsAPIHelper.h"
#import "SettingsViewController.h"
#import "PrimaryInterestImage.h"
#import "SocialsManager.h"
#import "emsChatVC.h"
#import "ABStoreManager.h"
#import "ActivityDetailViewController.h"
@interface emsLeftMenuVC ()

@property (nonatomic, weak) IBOutlet UIImageView *interestView;
@property (nonatomic, weak) IBOutlet UIView *viewForCollections;
@property (nonatomic, weak) IBOutlet UICollectionView *interesrtsCollection;
@property (nonatomic, weak) IBOutlet UIImageView *bgView;


@property (retain, nonatomic) NSMutableArray *interestsArray;

@end

@implementation emsLeftMenuVC

/*!
 @discussion 
 **/

-(void)setUpSelf{
    
    self.view.frame = CGRectMake( self.view.frame.origin.x, self.delegate.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:0.1 animations:^{
        self.view.frame  = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.bgView.alpha = 1;
        }];
    }];
    
}
-(id)initWithDelegate:(UIViewController *)delegateVC{
    
    self = [super init];
    
    if (self) {
        self.delegate = (UIViewController<leftMenudelegate>*)delegateVC;
        [delegateVC addChildViewController:self];
        [delegateVC.view addSubview:self.view];
        
    }
    return self;
    
}
-(void)viewDidAppear:(BOOL)animated{
    
     self.interestView.image = [[PrimaryInterestImage sharedInstance] interestImage];//Load main user interest image on the view
     [self setArray];//Get interests list from server
     [[ABStoreManager sharedManager] setEditProfileMode:NO];//Just for case set editing mode to NO
}

-(void)dealloc{
    [self.view removeFromSuperview];
    for (UIView *view in self.delegate.view.subviews) {
        [view removeFromSuperview];
        
    }
    if ([self.delegate isKindOfClass:[emsProfileVC class]]) {
        [(emsProfileVC *)self.delegate clearData];
    }
    if ([self.delegate isKindOfClass:[emsMainScreenVC class]]) {
        [(emsMainScreenVC *)self.delegate clearData];
    }
    
    if ([self.delegate isKindOfClass:[emsChatVC class]]) {
        [(emsChatVC *)self.delegate clearData];
    }
    if ([self.delegate isKindOfClass:[emsMapVC class]]) {
        [(emsMapVC *)self.delegate clearData];
    }
    if ([self.delegate isKindOfClass:[emsActivityVC class]]) {
        [(emsActivityVC *)self.delegate clearData];
    }
    if ([self.delegate isKindOfClass:[NotebookViewController class]]) {
       [(NotebookViewController *)self.delegate clearData];
    }
    if ([self.delegate isKindOfClass:[ActivityDetailViewController class]]) {
        [(ActivityDetailViewController *)self.delegate clearData];
    }

    self.delegate = nil;
    NSLog(@"dealloc %@",self);
}
/*!
 @discussion  load interests list from server and reload view
 **/
-(void)setArray{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.interestsArray  = [NSMutableArray arrayWithArray:[Server profile][@"interestActivity"]];
        dispatch_sync(dispatch_get_main_queue(), ^{
            
           [self.interesrtsCollection reloadData];
        });
    });
    
    //make corners rounded
    self.viewForCollections.layer.cornerRadius = 2;
    self.viewForCollections.layer.masksToBounds = YES;
    self.interesrtsCollection.layer.cornerRadius = 12;
    self.interesrtsCollection.layer.masksToBounds = YES;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpInterestsView];
    [self cornerIm:self.interestView];//Make interest image round
    [self.interesrtsCollection registerClass:[emsMenuCell class] forCellWithReuseIdentifier:@"emsMenuCell"];//register cell class
    [self setUpSelf];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)cornerIm:(UIImageView*)imageView{
    imageView .layer.cornerRadius = imageView.frame.size.height/2;
    imageView.layer.masksToBounds = YES;
}
-(void)hideInterests{
    
    [UIView animateWithDuration:0.4 animations:^{
        self.viewForCollections.frame  = CGRectMake(0,[UIScreen mainScreen].bounds.size.height,
                                                    self.viewForCollections.frame.size.width,
                                                    self.viewForCollections.frame.size.height);
        
    } completion:^(BOOL finished) {
        
    }];
}
-(void)setUpInterestsView{
    
    self.viewForCollections.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height , self.viewForCollections.frame.size.width, self.viewForCollections.frame.size.height);
    [self.view addSubview:self.viewForCollections];
    
}
#pragma CollectionView
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.interestsArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    
    
    static NSString *cellIdentifier = @"emsMenuCell";
    emsMenuCell *cell = (emsMenuCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if(![self imageHandler:self.interestsArray[indexPath.row][@"img"] toView:cell.interestsImage])
    {
       [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,self.interestsArray[indexPath.row][@"img"]] andIndicator:nil addToImageView:cell.interestsImage];
    }
    
    [self cornerIm:cell.interestsImage];
    cell.interestsName.text = self.interestsArray[indexPath.row][@"name"];

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
     self.interestView.image = [(emsMenuCell*)[collectionView cellForItemAtIndexPath:indexPath] interestsImage].image;
    [Server setPrimaryInterest:[NSString stringWithFormat:@"%@",self.interestsArray[indexPath.row][@"id"]]];
    [[ABStoreManager sharedManager] addData:[NSString stringWithFormat:@"%@",self.interestsArray[indexPath.row][@"id"]] forKey:vInterests];
    [self hideInterests];
    
}
/*!
 @discussion  Check whether image has already cached or not
 @param 'path' path to image
 @param 'target' view, to where cached image should be placed
 **/
-(BOOL)imageHandler:(NSString*)path toView:(UIImageView*)target
{
    UIImage *image = [[[ABStoreManager sharedManager] imageCache] objectForKey:path];
    if(image)
    {
        target.image = image;
        
        return YES;
    }
    return NO;
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
            [indicator stopAnimating];
            if (image == nil) {
                
               // targetView.image = [UIImage imageNamed:@"placeholder"];
                
            }else{
                targetView.image = image;
                [[[ABStoreManager sharedManager] imageCache] setObject:image forKey:coverUrl];
                [indicator stopAnimating];
            }
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
/*!
 @discussion  delete image from view
 **/
-(IBAction)clearImage{
    
    
    [UIView animateWithDuration:0.4 animations:^{
        self.view.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 animations:^{
            //  self.bgView.alpha = 1;
        }];
    }];
    
    [UIView animateWithDuration:0.4 animations:^{
        self.interestView.image = [UIImage imageNamed:@"placeholder_menu"];
    }];
}
-(IBAction)soundOff{
    
    //sound on / off
}
/*!
 @discussion  hide view
 **/
-(IBAction)selectInterests{
    
    [UIView animateWithDuration:0.4 animations:^{
        
        self.viewForCollections.center = self.view.center;
    } completion:^(BOOL finished) {
        
    }];
    
}
/*!
 @discussion  if user presses menu1 when menu2 is opend, this method 
 hides menu2 and opens menu1
 **/
-(IBAction)openOpposite:(id)sender{
    
    [self hideLeftMenu:^{
        if([self.delegate respondsToSelector:@selector(showRightMenu)]){
            [self.delegate showRightMenu];
        }
    }];

}
/*!
 @discussion  Press menu buttons handler
 **/
-(IBAction)presedAct:(UIButton*)selector{
    
    
    if([self.delegate respondsToSelector:@selector(actionPresed:complite:)])
    {
        [self hideLeftMenu:^{
            
            if (selector.tag == 7){
               self.actionsTypel = quitAction;
            }
            
            [self.delegate actionPresed:self.actionsTypel complite:^{
            
                switch (selector.tag)
                {
                    case 0:
                    {
                        if(![self.delegate isKindOfClass:[emsMainScreenVC class]]){
                            if (selector.tag != 7){
                                [self cleanSelf];
                            }
                            
                            [self.delegate presentViewController:[[emsMainScreenVC alloc] init] animated:YES completion:^{}];
                        }
                        self.actionsTypel = socialRadarAction;
                        
                    break;
                    }
                   case 1:
                        
                      self.actionsTypel = mapAction;
                    
                       if(![self.delegate isKindOfClass:[emsMapVC class]])
                       {
                            if (selector.tag != 7){
                                [self cleanSelf];
                            }
                            [self.delegate presentViewController:[[emsMapVC alloc] init] animated:YES completion:^{}];
                            
                       }
                     
                        break;
                        
                    case 2:
                        
                        if(![self.delegate isKindOfClass:[emsActivityVC class]])
                        {
                            if (selector.tag != 7){
                                [self cleanSelf];
                            }
                            [self.delegate presentViewController:[[emsActivityVC alloc]init] animated:YES completion:^{}];
                        }
                        
                        self.actionsTypel = activityAction;
                        break;
                        
                    case 3:
                    {
                        self.actionsTypel = notebookAction;
                        
                        if(![self.delegate isKindOfClass:[NotebookViewController class]])
                        {
                                if (selector.tag != 7){
                                    [self cleanSelf];
                                }

                            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[emsDeviceManager isIphone6plus]?@"Notebook_6plus":@"Notebook_6plus" bundle:nil];
                            NotebookViewController *notebook = [storyboard instantiateViewControllerWithIdentifier:@"NotebookViewController"];
                            [self.delegate presentViewController:notebook animated:YES completion:^{}];
                        }
                        
                    }
                    break;
                        
                    case 4:
                    {
                        
                        
                       if (selector.tag != 7){
                              [self cleanSelf];
                        }
                        [self.delegate presentViewController:[[emsProfileVC alloc] init] animated:YES completion:^{}];
                        self.actionsTypel = myProfileAction;
                        
                    }
                        break;
                        
                    case 5:
                        self.actionsTypel = activityBuilderAction;
                    {
                        if(![self.delegate isKindOfClass:[ActivityGeneralViewController class]])
                        {
                            if (selector.tag != 7){
                                [self cleanSelf];
                            }
                            
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[emsDeviceManager isIphone6plus]?@"ActivityBuilder_6plus":@"ActivityBuilder_4" bundle:nil];
                        ActivityGeneralViewController *dreamShot = [storyboard instantiateViewControllerWithIdentifier:@"ActivityGeneralViewController"];
                        [self.delegate presentViewController:dreamShot animated:YES completion:^{}];
                        }
                    }
                        break;
                        
                    case 6:
                    {
                        self.actionsTypel = settingAction;
                        if(![self.delegate isKindOfClass:[SettingsViewController class]])
                        {
                            if (selector.tag != 7){
                                [self cleanSelf];
                            }
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
                        SettingsViewController *notebook = [storyboard instantiateViewControllerWithIdentifier:@"Settings"];
                        [self.delegate presentViewController:notebook animated:YES completion:^{}];
                        }
                    }
                        
                    {
                }
                        break;
                        case 7:
                        {
                            //void
                        }
                        break;
                        
                    default:
                        break;
                }
               
            }];
            
        }];
        
    }
}

-(void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion{
    NSLog(@"Не надо детать  presentViewController из Menu !!!   self.delegate - вот что нужно");
}
/*!
 @discussion  Hides menu
 **/
-(IBAction)hideLeftHard{
    
    [UIView animateWithDuration:0.4 animations:^{
        self.bgView.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 animations:^{
            self.view.frame =CGRectMake( self.view.frame.origin.x, self.delegate.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        } completion:^(BOOL finished) {
            
        }];
    }];
    
}
/*!
 @discussion  hides menu with completion block
 **/
-(void)hideLeftMenu:(void (^)())complite{
    
    [UIView animateWithDuration:0.4 animations:^{
        self.bgView.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 animations:^{
            self.view.frame = CGRectMake( self.view.frame.origin.x, self.delegate.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        } completion:^(BOOL finished) {
            complite();
            
        }];
    }];
    
}

-(void)cleanSelf{
    [[self.delegate.childViewControllers lastObject] willMoveToParentViewController:nil];
    [[[self.delegate.childViewControllers lastObject] view] removeFromSuperview];
    [[self.delegate.childViewControllers lastObject] removeFromParentViewController];
}

@end
