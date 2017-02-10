//
//  CreateInterestViewController.m
//  Scadaddle
//
//  Created by Roman Bigun on 5/22/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "CreateInterestViewController.h"
#import "InterestCollectionViewCell.h"
#import "emsAPIHelper.h"
#import "emsMenuCell.h"
#import "UserDataManager.h"
#import "ABStoreManager.h"
#import "ScadaddlePopup.h"
#import "emsInterestsBuilderVC.h"
#import "emsInterestsVC.h"

@interface CreateInterestViewController ()
{

    UIImagePickerController *imgPicker;
    IBOutlet UIImageView *avatarImage;
    NSMutableArray *interests;
    BOOL photoSelected;
    ScadaddlePopup *popup;
    
}
@property (nonatomic, weak) IBOutlet UIView *viewForCollections;
@property (nonatomic, weak) IBOutlet UITextField *nameTF;
@property (nonatomic, weak) IBOutlet UISwitch *makePublic;
@property (nonatomic, weak) IBOutlet UICollectionView *interesrtsCollection;
@end

@implementation CreateInterestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    photoSelected = NO;
    self.nameTF.delegate = self;
    avatarImage.layer.cornerRadius = avatarImage.frame.size.height/2;
    avatarImage.layer.masksToBounds = YES;
    avatarImage.contentMode = UIViewContentModeScaleAspectFill;
   [self setIndents:self.nameTF];
    
    
}
/*!
 * @discussion  set indents to textfield [10x10]
 */
-(void)setIndents:(UITextField*)textfield
{
    
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [textfield setLeftViewMode:UITextFieldViewModeAlways];
    [textfield setLeftView:spacerView];
    
}
/*!
 * @discussion  get round-shaped corners on imageView
 */
-(void)cornerIm:(UIImageView*)imageView{
    imageView .layer.cornerRadius =  imageView.bounds.size.width/2;
    imageView.layer.masksToBounds = YES;
}

-(void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:YES];
  
   
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Picker

-(IBAction)fromGallary{
    
    if (!imgPicker) {
        imgPicker = [[UIImagePickerController alloc] init];
        [imgPicker setDelegate:(id)self];
    }
    
    imgPicker.allowsEditing = NO;
    [imgPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:imgPicker animated:TRUE completion:^{
        
    }];
    
}
-(IBAction)fromCamera:(id)sender{
    
    if (imgPicker) {
        imgPicker = nil;
    }
    
    if (!imgPicker) {
        imgPicker = [[UIImagePickerController alloc] init];
        [imgPicker setDelegate:(id)self];
    }
    
    if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]){
        [imgPicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [self presentViewController:imgPicker animated:TRUE completion:nil];
    }else{
        [self messagePopupWithTitle:@"Your Device doesn't support a camera" hideOkButton:NO];
        
        
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image =  [info objectForKey:UIImagePickerControllerOriginalImage];
    
    
    [UIView animateWithDuration:0.7f animations:^{
        
        avatarImage.image = image;
        [self cornerIm:avatarImage];
        photoSelected = YES;
    } completion:^(BOOL finished) {
        
    }];
    
    
    if ((imgPicker != nil) ) {
        [imgPicker  dismissViewControllerAnimated:TRUE completion:^{
            
        }];
        imgPicker=nil;
    }
}
- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
 
    [imgPicker dismissViewControllerAnimated:TRUE completion:^{
        
    }];
}
#pragma CollectionView
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return interests.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"emsMenuCell";
    emsMenuCell *cell = (emsMenuCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if(![self imageHandler:interests[indexPath.row][@"file"][@"filepath"]])
    {
         [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,interests[indexPath.row][@"file"][@"filepath"]] andIndicator:nil addToImageView:cell.interestsImage andImageName:interests[indexPath.row][@"file"][@"filepath"]];
    }
    else
    {
    
        cell.interestsImage.image = [[[ABStoreManager sharedManager] imageCache] objectForKey:interests[indexPath.row][@"file"][@"filepath"]];
        
    
    }
    cell.interestsName.text = interests[indexPath.row][@"name"];
    return cell;
}
/*!
 * @discussion  check whether image with path @param path cached or not.
 * If cached. add image to target else returns NO to start download
 * @param path path to image
 */
-(BOOL)imageHandler:(NSString*)path
{
    
    UIImage *image = [[[ABStoreManager sharedManager] imageCache] objectForKey:path];
    if(image)
    {
       
        return YES;
    }
    return NO;
}
/*!
 * @discussion to download image by path and set image to appropriate image view
 * @param coverUrl absolute path to image
 * @param targetView set image here after download is complete
 * @param name we use it as a unique key to save image in cache
 */
-(void)downloadImage:(NSString *)coverUrl andIndicator:(UIActivityIndicatorView*)indicator addToImageView:(UIImageView*)targetView andImageName:(NSString*)name{
    __block UIImage *image = [UIImage new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:coverUrl]];
        image  = [UIImage imageWithData:imageData];
        dispatch_sync(dispatch_get_main_queue(), ^{
            targetView.image = image;
            [self cornerIm:targetView];
            [indicator stopAnimating];
            if (image == nil) {
                
                targetView.image = [UIImage imageNamed:@"placeholder"];
                
            }else{
            
                if(image){
                    
                [[[ABStoreManager sharedManager] imageCache] setObject:image forKey:name];
            
                [indicator stopAnimating];
                    
                }
            }
        });
    });
    
}
-(void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    avatarImage.image = [(emsMenuCell*)[collectionView cellForItemAtIndexPath:indexPath] interestsImage].image;
    self.nameTF.text = [(emsMenuCell*)[collectionView cellForItemAtIndexPath:indexPath] interestsName].text;
    [self cornerIm:avatarImage];
    
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
 * @discussion  set placeholder image instead of downloaded one
 */
-(IBAction)clearImage{
    
    [UIView animateWithDuration:0.4 animations:^{
        avatarImage.image = [UIImage imageNamed:@"placeholder_menu"];
    }];
}

#pragma mark TF delegates
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
   
    [textField resignFirstResponder ];
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if(textField.text.length>30)
    {
        if([string length]==0)
            return YES;
        
        return NO;
    }
    return YES;
}
/**
 * @discussion: Fire popup when interests is being saved
 */
-(void)startUpdating
{
    
    popup = [[ScadaddlePopup alloc] initWithFrame:self.view.frame withTitle:@"Saving..." withProgress:YES andButtonsYesNo:NO forTarget:self andMessageType:-1];
    [self.view addSubview:popup];
    
}
/*!
 * @discussion to opens custom Popup with title
 * @param title desired message to display on popup
 * @param show YES/NO YES to display OK button
 */
-(void)messagePopupWithTitle:(NSString*)title hideOkButton:(BOOL)show
{

    popup = [[ScadaddlePopup alloc] initWithFrame:self.view.frame withTitle:title withProgress:NO andButtonsYesNo:NO forTarget:self andMessageType:-1];
    [popup hideDisplayButton:show];
    [self.view addSubview:popup];

}
/*!
 * @discussion to dismiss popup [slowly disappears]
 * @param title desired message to display on popup
 * @param duration time while disappearing
 * @param exit YES/NO YES to dismiss this controller
 */
-(void)dismissPopupActionWithTitle:(NSString*)title andDuration:(double)duration andExit:(BOOL)exit
{
    
    [popup updateTitleWithInfo:title];
    [UIView animateWithDuration:duration animations:^{
        
        popup.alpha=0.9;
    } completion:^(BOOL finished) {
        
       [popup removeFromSuperview];
        if(exit)
        {
            
            [self presentViewController:[[emsInterestsVC alloc] init] animated:YES completion:^{
                //  [self dismissPopup];
                
               
            }];
                
           
        }
        
    }];
    
    
}
/**
 * @discussion close popup when clicking on 'OK' button on popup
 */
-(IBAction)dismissPopup
{
    
    [self dismissPopupActionWithTitle:@"" andDuration:0 andExit:NO];
    
    
}
/*!
 * @discussion  resizes image
 * @param image image to resize
 * @param wdth wanted width
 * @param hght wanted height
 */
-(UIImage *)resizeImage:(UIImage *)image width:(int)wdth height:(int)hght{
    int w = image.size.width;
    int h = image.size.height;
    CGImageRef imageRef = [image CGImage];
    int width, height;
    int destWidth = wdth;
    int destHeight = hght;
    if(w > h){
        width = destWidth;
        height = h*destWidth/w;
    }
    else {
        height = destHeight;
        width = w*destHeight/h;
    }
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmap;
    bitmap = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedFirst);
    
    if (image.imageOrientation == UIImageOrientationLeft) {
        
        CGContextRotateCTM (bitmap, M_PI/2);
        CGContextTranslateCTM (bitmap, 0, -height);
        
    } else if (image.imageOrientation == UIImageOrientationRight) {
        
        CGContextRotateCTM (bitmap, -M_PI/2);
        CGContextTranslateCTM (bitmap, -width, 0);
        
    }
    else if (image.imageOrientation == UIImageOrientationUp) {
        
    } else if (image.imageOrientation == UIImageOrientationDown) {
        
        CGContextTranslateCTM (bitmap, width,height);
        CGContextRotateCTM (bitmap, -M_PI);
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage *result = [UIImage imageWithCGImage:ref];
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return result;
    
}
/*!
 * @discussion  Save interest to a interest object and send it to a server
 * @see avatarImage.image interest image
 * @see self.nameTF.text interest title
 * @see self.makePublic set interest public/private
 */
-(IBAction)saveInterestAndUploadToServer:(UIButton*)sender
{
    
    
    if (self.nameTF.text.length==0) {
        
        [self messagePopupWithTitle:@"Please, enter Name for new Interest!" hideOkButton:NO];
        return;
    }
    else
    {
        if( photoSelected )
        {
            [NSThread detachNewThreadSelector:@selector(startUpdating) toTarget:self withObject:nil];
            NSMutableDictionary *tmp=[[NSMutableDictionary alloc] init];
            [tmp setObject:self.nameTF.text forKey:kUDKUserInfoName];
            [tmp setObject:[self resizeImage:avatarImage.image width:240 height:240] forKey:kUDKUserInfoAvatarFile];
            [tmp setObject:[NSString stringWithFormat:@"%i",[self.makePublic isOn]?1:0] forKey:kUDKIterestIsPublic];
            [tmp setObject:[[UserDataManager sharedManager] serverToken] forKey:kServerApiToken];
            [Server addInterestWithData:tmp];
            
            if ([[ABStoreManager sharedManager] editProfileMode]) {
                [self dismissViewControllerAnimated:YES completion:^{
                }];
            }else{
                
            [self dismissPopupActionWithTitle:@"New interest has been created" andDuration:2 andExit:YES];
                
            }
            
        }
        else
        {
            [self messagePopupWithTitle:@"Please, add an image to current interest" hideOkButton:NO];
                    
        }
    }
    
   
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if(buttonIndex==0)
    {
    
        [alertView removeFromSuperview];
        self.nameTF.placeholder = @"Name";
        self.nameTF.text=@"";
        avatarImage.image = [UIImage imageNamed:@"placeholder_menu"];
    
    }
    else
    {
    
        [self presentViewController:[[emsInterestsVC alloc] init] animated:YES completion:^{
            //  [self dismissPopup];
            
            
        }];
    
    }

}
-(IBAction)back:(id)sender{
    
    if ( [[ABStoreManager sharedManager] editProfileMode]) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }else{
    
        [self presentViewController:[[emsInterestsVC alloc] init] animated:YES completion:^{
            //  [self dismissPopup];
            
            
        }];

    }
    
}
@end
