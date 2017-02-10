//
//  emsRegistrationVC.m
//  Scadaddle
//
//  Created by developer on 30/03/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsRegistrationVC.h"
#import "Constants.h"
#import "emsInterestsVC.h"
#import "emsDeviceDetector.h"
#import "UserDataManager.h"
#import "SocialsManager.h"
#import "ScadaddlePopup.h"
#import "emsScadProgress.h"
#import "PECropViewController.h"
@interface emsRegistrationVC ()<UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate,PECropViewControllerDelegate>{

    UIImagePickerController *imgPicker;
    IBOutlet UIPickerView* datePicker;
    IBOutlet UIView *viewWithPicker;
    BOOL isPickerShow;
    int marginOrig;
    ScadaddlePopup *popup;
    UIImageView *tmpView;
    int sourceType;
    NSDictionary *imageInfo;
    UIImageView *choosenMedia;
    emsScadProgress * subView;
}
@property (nonatomic, weak) IBOutlet UILabel *aboutMeLbl;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImage;
@property (nonatomic, weak) IBOutlet UITextField *nameTF;
@property (nonatomic, weak) IBOutlet UITextField *ageTF;
@property (nonatomic, weak) IBOutlet UITextView *descriptTF;
@property (nonatomic, weak) IBOutlet UIButton *interestsBtn;
@property (nonatomic, retain) UIImage *tmpImage;
@property(nonatomic, weak)IBOutlet UIScrollView *scrollView;
@property (nonatomic ,strong) NSMutableArray *years;

@end

@implementation emsRegistrationVC

#pragma mark Cropper Delegates
/*!
 * @discussion  method calls when cropping is complete. Set cropped image into the view.
 * @param 'cropedImage' image which has been cropped [use ti as you want]
 */
- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage transform:(CGAffineTransform)transform cropRect:(CGRect)cropRect
{
    
    tmpView = [[UIImageView alloc] init];
    tmpView.image = croppedImage;
    tmpView.frame = CGRectMake(8, 75, 302, 175);
    [self.scrollView addSubview:tmpView];
    [choosenMedia removeFromSuperview];
    choosenMedia = nil;
    
    NSData *imageData = UIImagePNGRepresentation(tmpView.image);
    self.tmpImage = [[UIImage alloc] initWithData:imageData];
    [controller dismissViewControllerAnimated:YES completion:NULL];
    
}
/*!
 * @discussion  Crop image canceled
 */
- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    tmpView = [[UIImageView alloc] init];
    tmpView.image = self.tmpImage;
    tmpView.backgroundColor = [UIColor blackColor];
    tmpView.frame = CGRectMake(8, 75, 302, 175);
    [self.scrollView  addSubview:tmpView];
    [choosenMedia removeFromSuperview];
    choosenMedia = nil;
    [controller dismissViewControllerAnimated:YES completion:NULL];
}
/*!
 * @discussion  Start cropping
 */
-(void)openEditor
{
    
    
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = choosenMedia.image;
    
    UIImage *image = choosenMedia.image;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat length = MIN(width, height);
    controller.imageCropRect = CGRectMake((width - length) / 2,
                                          (height - length) / 2,
                                          length,
                                          length);
     [self presentViewController:controller animated:YES completion:NULL];
}

/*!
 * @discussion  Progress view with animation
 */
-(void)progress{
    subView = [[emsScadProgress alloc] initWithFrame:self.view.frame screenView:self.view andSize:CGSizeMake(320, 580)];
    [self.view addSubview:subView];
    subView.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        subView.alpha = 1;
    }];
}
/*!
 * @discussion  Dismiss progress
 */
-(void)stopSubview{
    
    [UIView animateWithDuration:0.5 animations:^{
        subView.alpha = 0;
    } completion:^(BOOL finished) {
        [subView removeFromSuperview];
        subView = nil;
    }];
}

-(void)dealloc{



}
-(void)setScroll{
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    [self.scrollView setFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    [self.view addSubview:self.scrollView];
}
/*!
 * @discussion  Make image square-shaped
 */
-(UIImage *)makeSquare:(UIImage*)source
{
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([source CGImage], CGRectMake(0, source.size.height/3, source.size.width, source.size.height/2));
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
    
}
/*!
 * @discussion to download image by path and set image to appropriate image view
 * @param coverUrl absolute path to image
 * @param targetView set image here after download is complete
 */
-(void)downloadImageWithoutCropping:(NSString *)coverUrl andIndicator:(UIActivityIndicatorView*)indicator addToImageView:(UIImageView*)targetView{
    __block UIImage *image = [UIImage new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:coverUrl]];
        image  = [UIImage imageWithData:imageData];
        dispatch_sync(dispatch_get_main_queue(), ^{
            targetView.image = [self makeSquare:image];
            NSData *imageData = UIImagePNGRepresentation([self makeSquare:image]);
            self.tmpImage = [[UIImage alloc] initWithData:imageData];
            [indicator stopAnimating];
        });
    });
}
/*!
 * @discussion  Download user profile image from facebook and pass image to a cropper.Open cropper
 * @param coverUrl absolute path to a image
 */
-(void)downloadImage:(NSString *)coverUrl andIndicator:(UIActivityIndicatorView*)indicator addToImageView:(UIImageView*)targetView{
    __block UIImage *image = [UIImage new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:coverUrl]];
        image  = [UIImage imageWithData:imageData];
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            targetView.image = image;
            [self openEditor];
            [indicator stopAnimating];
        });
    });
}
/*!
 * @discussion  Set square [10x10] indents to textfilds
 */
-(void)setIndents:(UITextField*)textfield
{

    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [textfield setLeftViewMode:UITextFieldViewModeAlways];
    [textfield setLeftView:spacerView];

}
/*!
 * @discussion  Fill all controls with user information
 */
- (void)setUI{
    

    [self setIndents:self.ageTF];
    [self setIndents:self.nameTF];
    [self addBorders:self.nameTF addCornerRadius:YES];
    [self addBorders:self.ageTF addCornerRadius:YES];
    
    self.interestsBtn .layer.cornerRadius = 2;
    self.interestsBtn.layer.masksToBounds = YES;
    self.descriptTF .layer.cornerRadius = 2;
    self.descriptTF.layer.masksToBounds = YES;
    
    NSDictionary *local = [[NSUserDefaults standardUserDefaults] objectForKey:kUDKLocalUserInfo];
    
    self.descriptTF.text = local[@"about"];
    if(self.descriptTF.text.length==0)
    {
       self.descriptTF.text = @"About me";
    }
    self.ageTF.text = local[@"birthday"];
    self.nameTF.text = local[@"name"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *dofDate = [dateFormatter dateFromString:local[@"birthday"]];
    [self.dofPicker setDate:dofDate];
    
    
    NSLog(@"%@",local[@"img"]);
    NSLog(@"%@",local[@"fbid"]);
    
    choosenMedia = [[UIImageView alloc] initWithFrame:CGRectMake(8, 75, 302, 175)]; //CGRectMake(0, 70, 320, 320)];
    [self.scrollView addSubview:choosenMedia];
        
    
}
/*!
 * @discussion  Add borders and corner radius to textfilds
 * @param 'sender' textfield to which it should be applied
 * @param 'cornerRadus' 1/0 whether it should be rounded or not
 */
- (void)addBorders:(UITextField *)sender addCornerRadius:(BOOL)cornerRadius
{

    CGRect frameRect = sender.frame;
    frameRect.size.height = 32;
    sender.frame = frameRect;
    sender .layer.cornerRadius = 2;
    sender.layer.masksToBounds = YES;
    UIColor *color = [UIColor colorWithRed:155/255.f green:169/255.f blue:178/255.f alpha:0.8];

    sender.attributedPlaceholder = [[NSAttributedString alloc] initWithString:sender.placeholder attributes:@{NSForegroundColorAttributeName: color,NSFontAttributeName : [UIFont fontWithName:@"MYRIADPRO-Regular" size:12]}];
}
-(void)picData{
    
    isPickerShow=NO;
    viewWithPicker.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height , 320, 255);
    [self.view addSubview:viewWithPicker];
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{

      self.ageTF.text = [NSString stringWithFormat:@"%@ ",[self.years objectAtIndex:row]];
      self.dofPickerBGView.alpha=0;
}
-(void)flurrySessionDidCreateWithInfo:(NSDictionary *)info
{
    

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    ////[Flurry setDelegate:self];
    //[Flurry logEvent:@"Registration started"];
    marginOrig = 0;
    self.cropperBackground.alpha=0;
    self.cropperBottom.alpha=0;
    self.cropperPhotoFrame.alpha=0;
    self.cropperTop.alpha=0;
    self.cropperDone.alpha = 0;
    self.cropperCancel.alpha = 0;
    self.scadLabel.alpha = 0;
    self.captionLabel.alpha=0;
    self.buttonsBgView.alpha=0;
    
    [self setScroll];
    [self setUI];
    [self picData];
    [self setUpYears];
    
    self.descriptTF.textContainerInset = UIEdgeInsetsMake(5.0, 5.0, 0.0, 0.0);
    
    
//  [[[UIAlertView alloc] initWithTitle:@"Registration" message:@"We've discovered an information about you from facebook. You could change this information here or in your profile screen later. Please select your photo and tell us a little bit about youself." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
    NSMutableDictionary *userData = [[NSMutableDictionary alloc] initWithDictionary:[[UserDataManager sharedManager] registrationInfo]];
    if(userData[@"name"]!=nil)
    {
        
        
        self.nameTF.text = userData[kUDKUserInfoName];
        self.ageTF.text = userData[kUDKUserInfoAge];
        self.descriptTF.text = userData[kUDKUserInfoAbout];
        choosenMedia.image = userData[kUDKUserInfoAvatarFile];
        //   tmpView.image
        
    }
    else
    {
        
        [self messagePopupWithTitle:@"We've discovered an information about you from Facebook. You could change this information here or in your profile screen later. Please select your photo and tell us a little bit about yourself." hideOkButton:NO];
        
        UIActivityIndicatorView *interestsIndicator = [[UIActivityIndicatorView alloc] init];
        interestsIndicator.center = choosenMedia.center;
        interestsIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [interestsIndicator startAnimating];
        [self.view addSubview:interestsIndicator];
        SocialsManager *sm = [[SocialsManager alloc] init];
        NSDictionary *local = [[NSUserDefaults standardUserDefaults] objectForKey:kUDKLocalUserInfo];
        [self downloadImageWithoutCropping:[sm avatarUrlWithID:local[@"id"]] andIndicator:interestsIndicator addToImageView:choosenMedia];
        
    }
    
    if(choosenMedia.image==nil)
    {
        UIActivityIndicatorView *interestsIndicator = [[UIActivityIndicatorView alloc] init];
        interestsIndicator.center = choosenMedia.center;
        interestsIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [interestsIndicator startAnimating];
        [self.view addSubview:interestsIndicator];
        SocialsManager *sm = [[SocialsManager alloc] init];
        NSDictionary *local = [[NSUserDefaults standardUserDefaults] objectForKey:kUDKLocalUserInfo];
        [self downloadImageWithoutCropping:[sm avatarUrlWithID:local[@"id"]] andIndicator:interestsIndicator addToImageView:choosenMedia];
    }
    
    int len = self.descriptTF.text.length;
    self.counterLabel.text=[NSString stringWithFormat:@"%i",100-len];
    
    
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES; // Works for most use cases of pinch + zoom + pan
}

/*!
 * @discussion Uses for loading birth years into the picker
 */
-(void)setUpYears{

    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    int i2  = [[formatter stringFromDate:[NSDate date]] intValue];
    
    self.years = [[NSMutableArray alloc] init];
    for (int i=1954; i<=i2; i++) {
        [self.years addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    formatter = nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    
        [self scrolBack];//Release scroller which has been scroll up when keyboard displays
        [textField resignFirstResponder ];
    
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{

    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    if([text length] == 0)
    {
        if([textView.text length] != 0)
        {
            return YES;
        }
    }
    else if([[textView text] length] > 100)
    {
        return NO;
    }
    
    return YES;

}

/*!
 * @discussion  Display day of birth picker
 */
-(IBAction)chooseDOF
{
        self.dofPickerBGView.alpha=1;
}

/*!
 * @discussion  Change text for age text field when picker is being spinning
 */
- (IBAction)pickerAction:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *date = self.dofPicker.date;
    NSLog(@"%@",date);
    NSString *formatedDate = [dateFormatter stringFromDate:self.dofPicker.date];
    
    self.ageTF.text =formatedDate;
    
    
}

/*!
 * @discussion  Day of birth selected. Put in appropriate data into appropriate controls and hide picker
 */
-(IBAction)dofSelected:(id)sender
{

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *date = self.dofPicker.date;
    NSLog(@"%@",date);
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *formatedDate = [dateFormatter stringFromDate:self.dofPicker.date];
    
    self.ageTF.text =formatedDate;
    self.dofPickerBGView.alpha=0;

}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
       if (textField == self.ageTF) {
           
           [self.nameTF resignFirstResponder];
           [self.ageTF resignFirstResponder];
           
           self.dofPickerBGView.alpha=1;
          
           [self.descriptTF resignFirstResponder];
           
           [self.view endEditing:YES];
      }
    else
    {
       self.dofPickerBGView.alpha=0;
       [self scrolToTextField:textField];
    }
    
}
-(void)textViewDidChange:(UITextView *)textView
{
    
    if([[self.descriptTF text] length] > 100)
    {
        return;
    }
    else
    {
       int len = textView.text.length;
       self.counterLabel.text=[NSString stringWithFormat:@"%i",100-len];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
   
    [textField resignFirstResponder];
  
    return YES;
}


-(void)scrolToTextField:(UITextField *)sender{

    
    [UIView animateWithDuration:0.4f animations:^{
        
        self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x ,sender.frame.origin.y - kScrollUP);
        
    } completion:^(BOOL finished) {
        
    }];
    
}
/*!
 * @discussion  scroll back entire view after keyboard is dismissed
 */
-(void)scrolBack{
    
    [self.nameTF resignFirstResponder];
    [self.ageTF resignFirstResponder];
    [self.descriptTF resignFirstResponder];
    [UIView animateWithDuration:0.4f animations:^{
        
        self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x ,self.scrollView.contentOffset.x);
        
    } completion:^(BOOL finished) {
        
    }];
    
}
/*!
 * @discussion  scroll back textfield after keyboard is dismissed
 */
-(void)scrollBack:(UITextField *)sender{
    
    [UIView animateWithDuration:0.4f animations:^{
        
        self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x ,0);
        
    } completion:^(BOOL finished) {
        
    }];
    
}
#pragma mark Picker
-(IBAction)fromGallary{
    [self.nameTF resignFirstResponder];
    [self.ageTF resignFirstResponder];
    [self.descriptTF resignFirstResponder];
    self.dofPickerBGView.alpha = 0;
    [self.view endEditing:YES];
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
    [self.view endEditing:YES];
    self.dofPickerBGView.alpha = 0;
    [self.nameTF resignFirstResponder];
    [self.ageTF resignFirstResponder];
    [self.descriptTF resignFirstResponder];
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
-(IBAction)fromFacebook
{
    [self.view endEditing:YES];
    self.dofPickerBGView.alpha = 0;
    [self.nameTF resignFirstResponder];
    [self.ageTF resignFirstResponder];
    [self.descriptTF resignFirstResponder];
    if(!choosenMedia)
    {
        choosenMedia = [[UIImageView alloc] initWithFrame: CGRectMake(0, 70, 400, 200)];
        [self.scrollView  insertSubview:choosenMedia aboveSubview:self.cropperBackground];
        
    }
    choosenMedia.contentMode = UIViewContentModeScaleAspectFill;
    [tmpView removeFromSuperview];
    tmpView = nil;
   
    
    NSDictionary *local = [[NSUserDefaults standardUserDefaults] objectForKey:kUDKLocalUserInfo];;
    SocialsManager *sm = [[SocialsManager alloc] init];
    
        
    [self downloadImage:[local[@"img"] isEqualToString:@""]||local[@"img"]==NULL?[sm avatarUrlWithID:local[@"id"]]:[NSString stringWithFormat:@"%@%@",SERVER_PATH,local[@"img"]] andIndicator:nil addToImageView:choosenMedia];


}
-(void)startCrop
{

    self.cropperBackground.alpha=1;
    self.cropperBottom.alpha=0.55;
    self.cropperTop.alpha=0.55;
    self.cropperDone.alpha = 1;
    self.cropperPhotoFrame.alpha=1;
    self.cropperCancel.alpha = 1;
    self.scadLabel.alpha = 1;
    self.captionLabel.alpha = 1;
    self.buttonsBgView.alpha=1;
    
    
}
-(IBAction)cropCancel
{
    
    tmpView = [[UIImageView alloc] init];
    tmpView.image = self.tmpImage;
    tmpView.backgroundColor = [UIColor blackColor];
    tmpView.frame = CGRectMake(8, 75, 302, 175);
    [self.scrollView  insertSubview:tmpView aboveSubview:self.cropperBackground];
    [choosenMedia removeFromSuperview];
    choosenMedia = nil;
    self.buttonsBgView.alpha=0;
    self.cropperBackground.alpha=0;
    self.cropperBottom.alpha=0;
    self.cropperTop.alpha=0;
    self.cropperDone.alpha = 0;
    self.cropperPhotoFrame.alpha=0;
    self.cropperCancel.alpha = 0;
    self.scadLabel.alpha = 0;
    self.captionLabel.alpha = 0;
    
    
}
-(IBAction)doneCrop
{
    self.cropperPhotoFrame.alpha=0;
    self.cropperBottom.alpha=0;
    self.cropperTop.alpha=0;
    self.cropperDone.alpha = 0;
    self.cropperCancel.alpha = 0;
    self.scadLabel.alpha = 0;
    self.captionLabel.alpha = 0;
    self.buttonsBgView.alpha=0;
    tmpView = [[UIImageView alloc] init];
    tmpView.image = choosenMedia.image;
    
    tmpView.frame = CGRectMake(8, 75, 302, 175);
    [self.scrollView  insertSubview:tmpView aboveSubview:self.cropperBackground];
    [choosenMedia removeFromSuperview];
    choosenMedia = nil;
    self.cropperBackground.alpha=0;
    
    NSData *imageData = UIImagePNGRepresentation(tmpView.image);
    self.tmpImage = [[UIImage alloc] initWithData:imageData];
    
}
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    if(!choosenMedia)
    {
        choosenMedia = [[UIImageView alloc] initWithFrame: CGRectMake(0, 70, 400, 200)];
        [self.scrollView  insertSubview:choosenMedia aboveSubview:self.cropperBackground];
       
    }
    
    [tmpView removeFromSuperview];
    tmpView = nil;
    
    imageInfo = [[NSDictionary alloc] initWithDictionary:info];
    
    UIImage *image =  [info objectForKey:UIImagePickerControllerOriginalImage];
    //[self resizeImage:image width:300 height:180];
    choosenMedia.contentMode = UIViewContentModeScaleAspectFill;
    choosenMedia.image = image;
    
    if(picker.sourceType==UIImagePickerControllerSourceTypePhotoLibrary || picker.sourceType==UIImagePickerControllerSourceTypeSavedPhotosAlbum)
    {
        
        sourceType = 0;
        
    }
    else
    {
        
        sourceType = 1;
        
    }
    
    
    if ((imgPicker != nil) ) {
        [imgPicker  dismissViewControllerAnimated:TRUE completion:^{
            
        }];
        imgPicker=nil;
    }
    
    [self openEditor];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [imgPicker dismissViewControllerAnimated:TRUE completion:^{
        
    }];
}

-(void)showPicker{
    isPickerShow =YES;
    [self.nameTF resignFirstResponder];
    [self.ageTF resignFirstResponder];
    [self.descriptTF resignFirstResponder];
    
    [UIView animateWithDuration:0.3 animations:^{
     
        viewWithPicker.frame = CGRectMake(0, 313 , 320, 555);
        [self.nameTF resignFirstResponder];
        [self.ageTF resignFirstResponder];
        [self.descriptTF resignFirstResponder];
    }];
    
}



-(IBAction)hidePicker{
  
    [self.nameTF resignFirstResponder];
    [self.ageTF resignFirstResponder];
    [self.descriptTF resignFirstResponder];
    
        [UIView animateWithDuration:0.4 animations:^{
            
            viewWithPicker.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height , 320, 255);
            self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x ,0);

            }];
    
    isPickerShow = NO;
   
}


- (NSInteger)numberOfComponentsInPickerView: (UIPickerView*)thePickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.years count];
}
- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.years  objectAtIndex:row];
}


-(void)cornerIm:(UIImageView*)imageView{
    imageView .layer.cornerRadius = 2;
    imageView .layer.borderWidth = 1.0f;
    imageView .layer.borderColor = [UIColor colorWithRed:95/255.f green:129/255.f blue:139/255.f alpha:0.5f].CGColor;
    imageView .layer.shadowColor = [UIColor blackColor].CGColor;
    imageView.layer.masksToBounds = YES;
}
-(IBAction)interestsAction{
    
    
    FBHelper *fh = [[FBHelper alloc] init];
    [fh fbLoginToServer];
    [self saveUserData];
    
    
}
/*!
 * @discussion  Uses when register or 'update profile'
 * @note 'update profile' means that you went to Select Interest Page and then get back to FillProfile screen
 */
-(void)saveUserData
{
    
    
    if(self.nameTF.text.length==0)
    {
        [self messagePopupWithTitle:@"Fill all fields, please!" hideOkButton:NO];
        [self.view endEditing:YES];
        
        return;
    
    }
    else
    {
        if([self checkDate])
        {
      
        [self progress];
        NSMutableDictionary *userData = [[NSMutableDictionary alloc] init];
        [userData setObject:self.nameTF.text forKey:kUDKUserInfoName];
        [userData setObject:self.ageTF.text forKey:kUDKUserInfoAge];
        NSString *string = self.descriptTF.text;
        NSString *trimmedString = [string stringByTrimmingCharactersInSet:
                                       [NSCharacterSet whitespaceCharacterSet]];
            
        [userData setObject:trimmedString forKey:kUDKUserInfoAbout];
        [userData setObject:tmpView.image!=nil?tmpView.image:choosenMedia.image forKey:kUDKUserInfoAvatarFile];
        
            
        [[UserDataManager sharedManager] saveAdditionalUserInfo:userData];
        
        [self presentViewController:[[emsInterestsVC alloc] init] animated:YES completion:^{
          //  [self dismissPopup];
            
            [self stopSubview];
        }];

        }
        else
        {
        
            [self messagePopupWithTitle:@"Wrong date!" hideOkButton:NO];
        
        }
    }
        
}
/*!
 * @discussion  Check if user is 18+ years old
 */
-(BOOL)checkDate
{
    double unixTime = (time_t) [self.dofPicker.date timeIntervalSince1970];
    NSCalendar *c = [NSCalendar currentCalendar];
    NSDate *d1 = [NSDate date];
    NSDate *d2 = [NSDate dateWithTimeIntervalSince1970:unixTime];
    NSDateComponents *components = [c components:NSCalendarUnitYear fromDate:d2 toDate:d1 options:0];
    NSInteger diff = components.year;
    NSLog(@"%@",[NSNumber numberWithInteger:diff]);
    if([NSNumber numberWithInteger:diff]>=[NSNumber numberWithInt:18] && [NSNumber numberWithInteger:diff]>0)
        return YES;
    
    return NO;

}
-(BOOL)textViewShouldEndEditing:(UITextView *)textField{
    
    [self scrolBack];
    [textField resignFirstResponder ];
    
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textField{
    
    
    static dispatch_once_t task;
    dispatch_once(&task, ^{
    
            if (textField == self.descriptTF) {
                self.descriptTF.text = @"";
            }
    
    });
   
    
    [self scrolToTextView:textField];
}

- (BOOL)textViewShouldReturn:(UITextView *)textField{
    
    
    [textField resignFirstResponder];
    
    return YES;
}

-(void)scrolToTextView:(UITextView *)sender{
    
    
    [UIView animateWithDuration:0.4f animations:^{
        
        self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x ,sender.frame.origin.y - kScrollUP);
        
    } completion:^(BOOL finished) {
        
    }];
    
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
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
        
    }];
    
    
}
-(IBAction)dismissPopup
{
    
    [self dismissPopupActionWithTitle:@"" andDuration:0 andExit:NO];
    
    
}
@end
