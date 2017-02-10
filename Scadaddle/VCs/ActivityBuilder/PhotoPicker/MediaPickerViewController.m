//
//  MediaPickerViewController.m
//  ActivityCreator
//
//  Created by Roman Bigun on 5/7/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "MediaPickerViewController.h"
#import "ABStoreManager.h"
#import "SocialsManager.h"
#import "AssetsLibrary/AssetsLibrary.h"
#import "ActivityGeneralViewController.h"
#import "YTPlayerViewController.h"
#import "emsEditProfileVC.h"
#import "UserDataManager.h"
#import "FacebookAlbumsViewController.h"
#import "PECropViewController.h"
@interface MediaPickerViewController ()<UIGestureRecognizerDelegate,PECropViewControllerDelegate>
{

    UIImageView *tmpView;
    int sourceType;
    NSDictionary *imageInfo;
    UIImageView *choosenMedia;
    BOOL socialImageHere;
    BOOL clearedPlaceholder;
    int marginOrig;
    BOOL firstLoad;
    
}
@property (nonatomic, retain) UIImage *tmpImage;
@end

@implementation MediaPickerViewController

@synthesize curImage,curYoutubeObject;

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage transform:(CGAffineTransform)transform cropRect:(CGRect)cropRect
{
    
    self.cropperPhotoFrame.alpha=0;
    self.cropperBottom.alpha=0;
    self.cropperTop.alpha=0;
    self.cropperDone.alpha = 0;
    self.cropperCancel.alpha = 0;
    self.scadLabel.alpha = 0;
    self.captionLabel.alpha = 0;
    self.buttonsBgView.alpha=0;
    if(curYoutubeObject!=nil)
        curYoutubeObject = nil;
    tmpView = [[UIImageView alloc] init];
    tmpView.image = croppedImage;
    tmpView.frame = CGRectMake(0, 158, 320, 158);
    [self.view  addSubview:tmpView];
    [choosenMedia removeFromSuperview];
    choosenMedia = nil;
    clearedPlaceholder = NO;
    self.cropperBackground.alpha=0;
    self.curImage=nil;
    NSData *imageData = UIImagePNGRepresentation(tmpView.image);
    self.tmpImage = [[UIImage alloc] initWithData:imageData];
    [self.doneBtn setEnabled:YES];
    [self.clearImageBtn setEnabled:YES];
    [controller dismissViewControllerAnimated:YES completion:NULL];
    
}
-(IBAction)clearLastPhoto
{
    
    self.youtubePlayBtn.alpha=0;
    clearedPlaceholder = YES;
    [self.clearImageBtn setEnabled:NO];
    tmpView.image = [UIImage imageNamed:@"photo_bg"];
    choosenMedia.image = nil;
    [[ABStoreManager sharedManager] removeLastImage];
    [self.doneBtn setEnabled:NO];
    if(curYoutubeObject!=nil)
        curYoutubeObject = nil;
    
}
- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [[ABStoreManager sharedManager] removeLastImage];
    tmpView = [[UIImageView alloc] init];
    tmpView.image = self.tmpImage;
    if(tmpView.image!=nil)
        [self.clearImageBtn setEnabled:YES];
    if(tmpView.image==nil)
    {
    
        tmpView.image = [UIImage imageNamed:@"photo_bg"];
    
    }
    tmpView.frame = CGRectMake(0, 158, 320, 158);
    [self.view  insertSubview:tmpView aboveSubview:self.cropperBackground];
    [choosenMedia removeFromSuperview];
    choosenMedia = nil;
    self.curImage=nil;
    clearedPlaceholder = NO;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
       
    }
    
    [controller dismissViewControllerAnimated:YES completion:NULL];
}
-(void)openEditor:(UIImage *)source
{

    
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = source;
    
    UIImage *image = source;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat length = MIN(width, height);
    controller.imageCropRect = CGRectMake((width - length) / 2,
                                          (height - length) / 2,
                                          length,
                                          length);
    /*
     
     UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
     
     if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
     navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
     }
     
     [self presentViewController:navigationController animated:YES completion:NULL];
     
     
     */
    
 [self presentViewController:controller animated:YES completion:NULL];
}
-(IBAction)playYoutubeVideo
{

    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ActivityBuilder_4" bundle:nil];
    YTPlayerViewController *m = (YTPlayerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"YTPlayer"];
    [self presentViewController:m animated:YES completion:NULL];

}
-(void)dismissSelf
{
    
     if ([[ABStoreManager sharedManager] chatMode] ) {
         [[ABStoreManager sharedManager] setDoneEditing:YES];
         [[ABStoreManager sharedManager] setImageForChat:nil];
         [self dismissViewControllerAnimated:YES completion:^{
             
         }];
         
     }else{
         [[ABStoreManager sharedManager] setDoneEditing:YES];
         [self dismissViewControllerAnimated:YES completion:^{
             
         }];

     }
    
}
-(void)setupCropper
{

    self.cropperBackground.alpha=0;
    self.cropperBottom.alpha=0;
    self.cropperPhotoFrame.alpha=0;
    self.cropperTop.alpha=0;
    self.cropperDone.alpha = 0;
    self.cropperCancel.alpha = 0;
    self.scadLabel.alpha = 0;
    self.captionLabel.alpha=0;
    self.buttonsBgView.alpha=0;
    
    if(self.tmpImage==nil && choosenMedia.image==nil)
    {
    
        clearedPlaceholder = YES;
    
    }
    if(firstLoad)
    {
       [choosenMedia removeFromSuperview];
        firstLoad = NO;
    }
    
    if(self.curImage==nil)
    {
        
        
        previousScale = 2.0f;
        self.cropperBackground.alpha=0;
        self.cropperBottom.alpha=0;
        self.cropperTop.alpha=0;
        self.cropperPhotoFrame.alpha=0;
        self.cropperDone.alpha = 0;
        if(curYoutubeObject==nil)
           self.youtubePlayBtn.alpha=0;
        
        
    }
    else
    {
        if(curYoutubeObject==nil)
        {
            
            clearedPlaceholder = NO;
            [self.clearImageBtn setEnabled:YES];
            previousScale = 2.0;
            choosenMedia = [[UIImageView alloc] initWithFrame: CGRectMake(0, 158, 320, 158)];
            choosenMedia.image = self.curImage;
            [self openEditor:choosenMedia.image];
            [self fixrotation:self.curImage];
            choosenMedia.contentMode = UIViewContentModeScaleAspectFill;
            [self.view insertSubview:choosenMedia aboveSubview:self.cropperBackground];
            self.youtubePlayBtn.alpha=0;
            
        }
        else
        {
            [self.clearImageBtn setEnabled:YES];
            self.cropperPhotoFrame.alpha=0;
            self.cropperBottom.alpha=0;
            self.cropperTop.alpha=0;
            self.cropperDone.alpha = 0;
            self.cropperBackground.alpha=0;
            self.youtubePlayBtn.alpha=1;
            choosenMedia = [[UIImageView alloc] initWithFrame: CGRectMake(0, 158, 320, 158)];
            choosenMedia.image = self.curImage;
            tmpView = [[UIImageView alloc] init];
            tmpView.image = choosenMedia.image;
            [self fixrotation:self.curImage];
            //   choosenMedia.contentMode = UIViewContentModeScaleAspectFit;
            [self.view addSubview:choosenMedia];
            [self.view bringSubviewToFront:self.youtubePlayBtn];
           
            
            
        }
        
    }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.doneBtn setEnabled:NO]; //Nothing to save
    choosenMedia = [[UIImageView alloc] initWithFrame: CGRectMake(0, 158, 320, 158)];
    choosenMedia.image = [UIImage imageNamed:@"photo_bg"];
    [self.view addSubview:choosenMedia];
    
    self.titleLbl.text = @"Add Image & Video";
   
    
    if ([[ABStoreManager sharedManager] chatMode] ) {

        self.titleLbl.text = @"Add Image";
        
        
        [self.faceBookButtonForChat setTranslatesAutoresizingMaskIntoConstraints:YES];
        [UIView animateWithDuration:0.5 animations:^{
            self.youtubeBtnGo.alpha=0;
            self.faceBookButtonForChat.frame = CGRectMake(140,
                                                          self.faceBookButtonForChat.origin.y ,
                                                          self.faceBookButtonForChat.frame.size.width,
                                                          self.faceBookButtonForChat.frame.size.height);
        }];

        
        [self.editProfileBack removeTarget:nil
                                    action:NULL
                          forControlEvents:UIControlEventAllEvents];
        
        [self.editProfileBack addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
        
        
    }
    if ( [[ABStoreManager sharedManager] editProfileMode] ){
        self.titleLbl.text = @"Add Image & Video";
        
        
        [self.editProfileBack removeTarget:nil
                           action:NULL
                 forControlEvents:UIControlEventAllEvents];
        
        [self.editProfileBack addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];

    }
    
}
- (void)addMovementGesturesToView:(UIView *)view {
    view.userInteractionEnabled = YES;  // Enable user interaction
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panGesture.delegate = self;
    [view addGestureRecognizer:panGesture];
   
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinchGesture.delegate = self;
    [view addGestureRecognizer:pinchGesture];
    
}
-(IBAction)handleRotationGesture:(UIRotationGestureRecognizer *)recognizer {

    CGFloat angle = recognizer.rotation;
    choosenMedia.transform = CGAffineTransformRotate(choosenMedia.transform, angle);
    recognizer.rotation = 0.0;
    

}
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)pinchGesture {
    
       if (UIGestureRecognizerStateBegan == pinchGesture.state ||
        UIGestureRecognizerStateChanged == pinchGesture.state) {
        
        // Use the x or y scale, they should be the same for typical zooming (non-skewing)
        float currentScale = [[pinchGesture.view.layer valueForKeyPath:@"transform.scale.x"] floatValue];
        
        // Variables to adjust the max/min values of zoom
        float minScale = 1.0;
        float maxScale = 2.0;
        float zoomSpeed = .5;
        
        float deltaScale = pinchGesture.scale;
        
        // You need to translate the zoom to 0 (origin) so that you
        // can multiply a speed factor and then translate back to "zoomSpace" around 1
        deltaScale = ((deltaScale - 1) * zoomSpeed) + 1;
        
        // Limit to min/max size (i.e maxScale = 2, current scale = 2, 2/2 = 1.0)
        //  A deltaScale is ~0.99 for decreasing or ~1.01 for increasing
        //  A deltaScale of 1.0 will maintain the zoom size
        deltaScale = MIN(deltaScale, maxScale / currentScale);
        deltaScale = MAX(deltaScale, minScale / currentScale);
        
        CGAffineTransform zoomTransform = CGAffineTransformScale(pinchGesture.view.transform, deltaScale, deltaScale);
        pinchGesture.view.transform = zoomTransform;
        
        // Reset to 1 for scale delta's
        //  Note: not 0, or we won't see a size: 0 * width = 0
        pinchGesture.scale = 1;
    }
    
    
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint translation = [recognizer translationInView:self.view];
    marginOrig = (recognizer.view.frame.size.width - self.cropperPhotoFrame.frame.size.width)/2;
    
    
    CGRect frame = [self.view convertRect:recognizer.view.frame fromView:self.view];
    NSLog(@"Movement %f",frame.origin.y);
    
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        
        double dist = hypot((self.cropperPhotoFrame.frame.origin.x-frame.origin.x),
                            (self.cropperPhotoFrame.frame.origin.y-frame.origin.y));
        
        CGRect container    = self.cropperPhotoFrame.frame;//Cropper frame
        UIImage *origImage = [imageInfo objectForKey:UIImagePickerControllerOriginalImage];//Choosen image
        CGRect origRect = CGRectMake(frame.origin.x,frame.origin.y-158,origImage.size.width,origImage.size.height);
        float margineY = origRect.size.height-320;
        CGRect shifted = CGRectOffset (container, frame.origin.x,frame.origin.y);
        
        if (CGRectContainsRect(container, origRect))
            NSLog (@"Cropper contains Image ");
        
        [UIView animateWithDuration:0.5 animations:^{
            
            //for small images inside the cropperPhotoFrame
            if ((self.cropperPhotoFrame.frame.origin.x-recognizer.view.center.x!=0 && self.cropperPhotoFrame.frame.size.height == recognizer.view.frame.size.height && origRect.size.height<160) || frame.size.height<160)
                
            {
                
                
                
                recognizer.view.center = CGPointMake(160,
                                                     
                                                     238);
                return;
                
                
            }
            
            else if(self.cropperPhotoFrame.frame.origin.x-recognizer.view.center.x<0 && frame.size.width>320 && frame.origin.x>0)
            {
                
                
                recognizer.view.center = CGPointMake(frame.size.width/2,
                                                     recognizer.view.center.y + translation.y);
                
                
            }
            else if(frame.size.width>320 && frame.origin.x<-marginOrig)
            {
                
                recognizer.view.center = CGPointMake(160-marginOrig,
                                                     recognizer.view.center.y + translation.y);
                
                
            }
            
            if(frame.origin.y-self.cropperPhotoFrame.frame.origin.y>=margineY-10)
            {
                
                recognizer.view.center = CGPointMake(recognizer.view.center.x+translation.x,
                                                     158+margineY);
                
            }
            else if(frame.origin.y<158-margineY)
            {
                
                recognizer.view.center = CGPointMake(recognizer.view.center.x+translation.x,
                                                     158+margineY);
                
            }
            
            
        }];
        
        
        //
    }
    
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}

-(void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:YES];
    [self setupCropper];
   
    if ([[ABStoreManager sharedManager] doneEditing]) {
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
    }
    
    if(curYoutubeObject!=nil)
    {
        
        [self.doneBtn setEnabled:YES];
        
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)youtubeVideos
{
    
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startLocating:) name:@"youtubeVideoCreated" object:nil];//Пришло видео из Ютьюба
    SocialsManager *sm = [[SocialsManager alloc] init];
    [sm youtubeVideoLinksForTerm:@"adamtomasmoran"];
    */
}

-(IBAction)instagramPosts
{
       /*
    SocialsManager *sm = [[SocialsManager alloc] init];
    [sm instagramPosts];
     */
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"users/self/followed-by", @"method", nil];
    [appDelegate.instagram requestWithParams:params
                                    delegate:self];
    
}

- (void)request:(IGRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Instagram did fail: %@", error);
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)request:(IGRequest *)request didLoad:(id)result {
    NSLog(@"Instagram did load: %@", result);
   
}
- (void)startLocating:(NSNotification *)notification {
    
    NSDictionary *dict = [notification userInfo];
    
   if([[notification name] isEqualToString:@"youtubeVideoCreated"])
    {
        //Ловим список из Ютьюба здесь
        
        NSArray *va=[NSArray arrayWithArray:[dict valueForKey:@"videoObjects"]];
        NSLog(@"%@",va);
    }
    
}

-(IBAction)fromGallary{
    
    if (!imgPicker) {
        imgPicker = [[UIImagePickerController alloc] init];
        [imgPicker setDelegate:(id)self];
    }
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
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
        UIAlertView *warning = [[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:@"Ooops!You have no camera.Buy a new iPhone!"
                                                         delegate:nil
                                                cancelButtonTitle:@"Cencel"
                                                otherButtonTitles:nil, nil];
        [warning show];
        
    }
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo
{

    NSLog(@"Info %@",contextInfo);
    

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
-(BOOL)isPortraiteOrientation
{

    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
    {
        return YES;
        
    }
    
    return NO;


}
/*!
 * @discussion to rotate image from portrait to landscape
 */
- (UIImage *)fixrotation:(UIImage *)image{
    
    
    //if (image.imageOrientation == UIImageOrientationUp)
    //    return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES; // Works for most use cases of pinch + zoom + pan
}
/*!
 * @discussion to make screenshot
 */
- (UIImage*)imageFromView:(UIImageView *)view
{
   
    CGSize imageSize = [view bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 1.0f);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, [view center].x, [view center].y);
    CGContextConcatCTM(context, [view transform]);
    CGContextTranslateCTM(context,
                          -[view bounds].size.width * [[view layer] anchorPoint].x,
                          -[view bounds].size.height * [[view layer] anchorPoint].y);
    
    // Render the layer hierarchy to the current context
    [[view layer] renderInContext:context];
    
    // Restore the context
    CGContextRestoreGState(context);
    
    // Retrieve the screenshot image
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    CGRect cropRect = CGRectMake(0, 100, 320, 158);
    CGImageRef imageRef = CGImageCreateWithImageInRect([viewImage CGImage], cropRect);
    
    UIGraphicsEndImageContext();
    
    return [[UIImage alloc]initWithCGImage:imageRef];
}
- (UIImageView *)rp_screenshotImageViewWithCroppingRect:(CGRect)croppingRect {
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(croppingRect.size, YES, [UIScreen mainScreen].scale);
    } else {
        UIGraphicsBeginImageContext(croppingRect.size);
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, -croppingRect.origin.x, -croppingRect.origin.y);
    [self.view.layer renderInContext:ctx];
    
    // Retrieve a UIImage from the current image context:
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Return the image in a UIImageView:
    return [[UIImageView alloc] initWithImage:snapshotImage];
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
    
    UIImage *image = [[UIImage alloc] init];
    image = [self imageFromView:choosenMedia];
    tmpView = [[UIImageView alloc] init];
    tmpView.image = choosenMedia.image;
    tmpView = [self rp_screenshotImageViewWithCroppingRect:CGRectMake(0, 158, 320, 158)];
    tmpView.frame = CGRectMake(0, 158, 320, 158);
    [self.view  insertSubview:tmpView aboveSubview:self.cropperBackground];
    [choosenMedia removeFromSuperview];
    choosenMedia = nil;
    clearedPlaceholder = NO;
    self.cropperBackground.alpha=0;
    
    NSData *imageData = UIImagePNGRepresentation(tmpView.image);
    self.tmpImage = [[UIImage alloc] initWithData:imageData];
    [self.doneBtn setEnabled:YES];
}
-(void)startCrop
{
    
    self.cropperBackground.alpha=1;
    self.cropperBottom.alpha=0.1;
    self.cropperTop.alpha=0.1;
    self.cropperDone.alpha = 1;
    self.cropperPhotoFrame.alpha=1;
    self.cropperCancel.alpha = 1;
    self.scadLabel.alpha = 1;
    self.captionLabel.alpha = 1;
    self.buttonsBgView.alpha=1;
    [self addMovementGesturesToView:choosenMedia];
    
}
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.clearImageBtn setEnabled:YES];
    clearedPlaceholder = NO;
    
    [tmpView removeFromSuperview];
    tmpView = nil;
    
    imageInfo = [[NSDictionary alloc] initWithDictionary:info];
    
        UIImage *image =  [info objectForKey:UIImagePickerControllerOriginalImage];
        [self fixrotation:image];
    
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
    
    [self openEditor:image];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [imgPicker dismissViewControllerAnimated:TRUE completion:^{
        
    }];
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
            
            targetView.image = image;
            NSData *imageData = UIImagePNGRepresentation(image);
            self.tmpImage = [[UIImage alloc] initWithData:imageData];
            [indicator stopAnimating];
        });
    });
}
-(IBAction)cropCancel
{

       [[ABStoreManager sharedManager] removeLastImage];
        tmpView = [[UIImageView alloc] init];
        tmpView.image = self.tmpImage;
        tmpView.backgroundColor = [UIColor blackColor];
        tmpView.frame = CGRectMake(0, 158, 320, 158);
        [self.view  insertSubview:tmpView aboveSubview:self.cropperBackground];
        [choosenMedia removeFromSuperview];
        choosenMedia = nil;
        self.buttonsBgView.alpha=0;
        self.cropperBackground.alpha=0;
        self.cropperBottom.alpha=0;
        self.cropperTop.alpha=0;
        self.cropperDone.alpha = 0;
        self.cropperPhotoFrame.alpha=0;
        self.cropperCancel.alpha = 0;
        self.captionLabel.alpha = 0;
        clearedPlaceholder = YES;
    
  
}
-(IBAction)doneAction
{
   
    
   if ([[ABStoreManager sharedManager] chatMode]) {
       
       [[ABStoreManager sharedManager] setImageForChat:tmpView.image];
       
       [[ABStoreManager sharedManager] setDoneEditing:YES];
       
       [self dismissViewControllerAnimated:TRUE completion:^{
         
       }];
   }
    
    if ([[ABStoreManager sharedManager] editProfileMode]) {
        
        if(tmpView.image!=nil)
        {
            
            
            
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
       // [dict setObject:tmpView.image forKey:@"file" ];
        [dict setObject:[[UserDataManager sharedManager] serverToken] forKey:@"restToken"];
        
          
            if(curYoutubeObject!=nil)
            {
                [[ABStoreManager sharedManager] addYoutubeToActivity:curYoutubeObject];
                [[ABStoreManager sharedManager] addSocialImagePath:curYoutubeObject[@"img"]];
                
                NSDictionary *dict2 = [[[ABStoreManager sharedManager]youtubeObjects] copy];

                NSArray *dict4 =[dict2 valueForKey:@"title"] ;
                
                 NSArray *dict5 =[dict2 valueForKey:@"id"] ;
                
                NSString *titleStr= [dict4 objectAtIndex:0];
                
                NSString *idStr  = [dict5 objectAtIndex:0];
                
                [dict setObject:titleStr forKey:@"videoTitle" ];
                
                [dict setObject:idStr forKey:@"videoId" ];
                
            }else{
                
               [dict setObject:tmpView.image forKey:@"file" ];
            }
            
        [Server postProfileInfoandUserID:dict callback:^(NSDictionary *dictionary) {
            
            NSLog(@"%@",dictionary);
            
        }];
            
            
        
        NSData* imdata = UIImagePNGRepresentation(tmpView.image);
        NSString *stringOfImageData = [imdata base64EncodedStringWithOptions:0];
        NSString *prefix = [NSString stringWithFormat:@"%@",@"data:image/png;base64,"];
        NSString *base64res =  [prefix stringByAppendingString:stringOfImageData];
        [[ABStoreManager sharedManager] addImagesToArray:base64res];
        }
        
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        // Request to save the image to camera roll
        [library writeImageToSavedPhotosAlbum:[tmpView.image CGImage] orientation:ALAssetOrientationUp completionBlock:^(NSURL *assetURL, NSError *error){
            if (error) {
                NSLog(@"error");
            } else {
                NSLog(@"url %@", assetURL);
                if(tmpView.image!=nil && clearedPlaceholder==NO)
                {
                    [[ABStoreManager sharedManager] savePickedPastFromAssets:[NSString stringWithFormat:@"%@",assetURL]];
                    
                }
                
                [[ABStoreManager sharedManager] setDoneEditing:YES];
                [self dismissViewControllerAnimated:YES completion:^{
                    
                }];
                

            }
        }];
        

        
        
    }else{
    
        
        if(tmpView.image!=nil && clearedPlaceholder==NO && curYoutubeObject==nil)
        {
            NSData* imdata = UIImagePNGRepresentation(tmpView.image);
            NSString *stringOfImageData = [imdata base64EncodedStringWithOptions:0];
            NSString *prefix = [NSString stringWithFormat:@"%@",@"data:image/png;base64,"];
            NSString *base64res =  [prefix stringByAppendingString:stringOfImageData];
            [[ABStoreManager sharedManager] addImagesToArray:base64res];
            
        }
        if(curYoutubeObject!=nil)
        {
            [[ABStoreManager sharedManager] addYoutubeToActivity:curYoutubeObject];
            [[ABStoreManager sharedManager] addSocialImagePath:curYoutubeObject[@"img"]];
            [[ABStoreManager sharedManager] savePickedPastFromAssets:curYoutubeObject[@"img"]];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ActivityBuilder_4" bundle:nil];
            ActivityGeneralViewController *dreamShot = [storyboard instantiateViewControllerWithIdentifier:@"ActivityGeneralViewController"];
            [self presentViewController:dreamShot animated:YES completion:^{
                
            }];
        }
        else
        {
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            
            // Request to save the image to camera roll
            [library writeImageToSavedPhotosAlbum:[tmpView.image CGImage] orientation:ALAssetOrientationUp completionBlock:^(NSURL *assetURL, NSError *error){
                if (error) {
                    NSLog(@"error");
                } else {
                    NSLog(@"url %@", assetURL);
                    if(tmpView.image!=nil && clearedPlaceholder==NO)
                    {
                        [[ABStoreManager sharedManager] savePickedPastFromAssets:[NSString stringWithFormat:@"%@",assetURL]];
                        
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ActivityBuilder_4" bundle:nil];
                        ActivityGeneralViewController *dreamShot = [storyboard instantiateViewControllerWithIdentifier:@"ActivityGeneralViewController"];
                        [self presentViewController:dreamShot animated:YES completion:^{
                            
                        }];
                        
                    }
                    
                    
                }
            }];
            
        }
    }
}
- (void)removeImage:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        NSLog(@"Deleted");
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}
@end
