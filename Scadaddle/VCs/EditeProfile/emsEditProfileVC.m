//
//  emsEditProfileVC.m
//  Scadaddle
//
//  Created by developer on 06/07/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsEditProfileVC.h"
#import "emsInterestsScroll.h"
#import "emsEditProfileCell.h"
#import "emsProfileVC.h"
#import "ABStoreManager.h"
#import "emsInterestsVC.h"
#import "MediaPickerViewController.h"
#import "emsEditProfileScroll.h"
#import "emsAPIHelper.h"
#import "UserDataManager.h"
#import "ScadaddlePopup.h"
#import "EditProfileImage.h"
#import "emsScadProgress.h"
#import "emsScadProgress.h"
#import "emsEditProfileInterestsVC.h"

#define DESCRIPTION_SYMBOLS 100
#define StringFromInteger(integer) [NSString stringWithFormat:@"%lu",integer]

@interface emsEditProfileVC ()<UITextViewDelegate,InterestsScrollDelegate,EditProfileScrollDelegate>{
    IBOutlet UIView *detailImageView;
    ScadaddlePopup *popup;
    NSThread *scadaddlePopupThread;
    emsScadProgress * subView;
    BOOL detailImageShow;
}
@property(retain,nonatomic)NSMutableDictionary *apiDictionary;
@property (nonatomic, weak) IBOutlet UITextView *aboutUserTextView;
@property (nonatomic, weak) IBOutlet UILabel *characterCountLabl;
@property(retain,nonatomic) NSMutableArray * userDataArray;
@property(retain,nonatomic) NSMutableArray *allActivities;
@property (nonatomic, weak) IBOutlet UILabel *pointLeftLbl;
@property (nonatomic, weak) IBOutlet UIImageView *detailImage;
@property (nonatomic, weak) IBOutlet UIButton *deleteImageBtn;
@property (nonatomic, weak) IBOutlet UIButton *restoreImageBtn;
@property (nonatomic, weak) IBOutlet UIButton *saveBtn;
@property (nonatomic, weak) IBOutlet UIButton *takeMainBtn;
@property (nonatomic) NSString *mainImageID;
@property(retain,nonatomic) NSMutableArray *imagesForDeleting;
@property(nonatomic) int indexForDeleting;
@property(nonatomic) emsEditProfileScroll * editProfileScroll;
@property(retain,nonatomic) NSMutableArray *parseDIctionaryArray;
@property(retain,nonatomic) NSMutableArray *selectedInterestsActivity;
@property(retain,nonatomic) NSMutableArray *selectedInterestSpectator;
@end


@implementation emsEditProfileVC
/*!
 *@discussion Show progress view ander superView
 *
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
 *@discussion Remove progress view from superView
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
-(id)initWithData:(NSDictionary *)userData
{
    self = [super init];
    if(self)
    {
        
        if (userData != nil) {
            
            [[ABStoreManager sharedManager] editProfileDictiomary:userData];
            self.mainImageID = @"";
        }
        self.userDataArray = [[NSMutableArray alloc] init];
        self.imagesForDeleting = [[NSMutableArray alloc] init];
        self.selectedInterestsActivity = [[NSMutableArray alloc] init];
        self.selectedInterestSpectator = [[NSMutableArray alloc] init];
        self.parseDIctionaryArray = [[NSMutableArray alloc] init];
        
    }
    return self;
    
}

/*!
 *
 *  @discussion Method sets main data
*/
-(void)parseDictionary{
    
    
    NSArray *tmpArr = [self.parseDIctionaryArray copy];
    
    for ( EditProfileImage *editProfileImage  in tmpArr) {
        if([editProfileImage.path246x246  isEqualToString:@"photo_bg_small"]){
            [self.parseDIctionaryArray removeObject:editProfileImage];
        }
    }
    tmpArr = nil;
    
    for (int i =[self.parseDIctionaryArray count]; i <[self.apiDictionary[@"files"] count]; i++) {
        
        NSDictionary *dictionary =  [self.apiDictionary[@"files"] objectAtIndex:i];
        EditProfileImage *editProfileImage = [[EditProfileImage alloc] init];
        editProfileImage.isPrimary = [dictionary[@"isPrimary"] stringValue];
        editProfileImage.path1242x554 = dictionary[@"path1242x554"];
        editProfileImage.path246x246 = dictionary[@"path246x246"];
        editProfileImage.path600x370 = dictionary[@"path600x370"];
        editProfileImage.path940x454 = dictionary[@"path940x454"];
        editProfileImage.imageId = [dictionary[@"id"] stringValue];
        if ([[dictionary valueForKey:@"type"] isEqualToString:@"video"]) {
            editProfileImage.isVideo = YES;
        }
        
        [self.parseDIctionaryArray addObject:editProfileImage];
    }
    
}

-(void)viewDidDisappear:(BOOL)animated{
    
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[emsInterestsScroll class]]) {
            [view removeFromSuperview];
        }
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [self progress];
}
-(void)viewDidAppear:(BOOL)animated{
    
    [[ABStoreManager sharedManager] setDoneEditing:NO];
    [[ABStoreManager sharedManager] setEditProfileMode:YES];
    self.apiDictionary = [[NSMutableDictionary alloc] initWithDictionary:[[ABStoreManager sharedManager] getEditProfileDictiomary]];
    _allActivities = [NSMutableArray new];
    [self parseDictionary];
    [self initActivitiesAndUserData:self.apiDictionary[@"files"] ];
    NSString * points = [NSString stringWithFormat:@"%@",self.apiDictionary[@"casting"][@"need"]];
    self.pointLeftLbl.text =points;
    self.aboutUserTextView .layer.cornerRadius = 2;
    self.aboutUserTextView.layer.masksToBounds = YES;
    self.characterCountLabl .layer.cornerRadius = 2;
    self.characterCountLabl.layer.masksToBounds = YES;
    self.characterCountLabl.text =  StringFromInteger(DESCRIPTION_SYMBOLS-[self.apiDictionary[@"about"] length]);
    self.aboutUserTextView.text = self.apiDictionary[@"about"] ;
    emsInterestsScroll *interestsScroll  = [[emsInterestsScroll alloc] initWithFrame:CGRectMake(0, 160,323, 115) andData:self.apiDictionary[@"interestSpectator"] andAnimation:@"r" andUsingType:editProfileScrolls];
    
    interestsScroll.interestsrEditingType = spactatorEditingIterests ;
    interestsScroll.delegate = (id)self;
    [interestsScroll moveInterests];
    [self.view addSubview:interestsScroll];
    
    /*!
     *adding emsInterestsScroll
     */
    
    emsInterestsScroll *interestsScrollSpactator  = [[emsInterestsScroll alloc] initWithFrame:CGRectMake(0, 234,323, 115) andData:self.apiDictionary[@"interestActivity"]andAnimation:@"l" andUsingType:editProfileScrolls];
    interestsScrollSpactator.interestsrEditingType =activityEditingInterests ;
    interestsScrollSpactator.delegate = (id)self;
    [interestsScrollSpactator moveInterests];
    [self.view addSubview:interestsScrollSpactator];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    if (self.editProfileScroll ==nil) {
        
        self.editProfileScroll  = [[emsEditProfileScroll alloc]
                                   initWithFrame:CGRectMake(0, 78,260,70)
                                   andData:self.parseDIctionaryArray];
        self.editProfileScroll.delegate = (id)self;
        [self.view addSubview:self.editProfileScroll];
    }
    [self.editProfileScroll reloadData:self.parseDIctionaryArray];
    self.saveBtn .layer.cornerRadius = 2;
    self.saveBtn.layer.masksToBounds = YES;
    
    
    [self.selectedInterestsActivity removeAllObjects];
    [self.selectedInterestSpectator removeAllObjects];
    
    for (NSDictionary *dictionary in self.apiDictionary[@"interestActivity"]) {
        
        [self.selectedInterestsActivity addObject: @([dictionary[@"id"] intValue])];
    }
    
    for (NSDictionary *dictionary in self.apiDictionary[@"interestSpectator"]) {
        
        [self.selectedInterestSpectator addObject:@([dictionary[@"id"] intValue])];
    }
    
    [self stopSubview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAllArrays];
}
-(void)initAllArrays{
    
    
    
}

/*
 *  @discussion textView delegate
*/
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSInteger textLength = 0;
    
    textLength = [textView.text length] + [text length] - range.length;
    
    if((DESCRIPTION_SYMBOLS-textLength)!=-1){
        
        self.characterCountLabl.text = StringFromInteger(DESCRIPTION_SYMBOLS-textLength);
        return YES;
    }
    else{
        self.characterCountLabl.text=@"0";
        textView.text = [textView.text substringToIndex:[textView.text length] - 1];
        return YES;
    }
    
    
}

/*!
 *  @discussion textField delegate
*/

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self.aboutUserTextView resignFirstResponder];
    
    return YES;
}
/*!
 *
 *  @discussion Method resigns TextView
*/


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.aboutUserTextView isFirstResponder] && [touch view] != self.aboutUserTextView) {
        [self.aboutUserTextView resignFirstResponder];
        [self scrollMainToUp:0];
    }
    [super touchesBegan:touches withEvent:event];
}

/*!
 *  @discussion keyboard delagate
*/
-(void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    
    CGSize keyboardSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [self scrollMainToUp:keyboardSize.height ];
}
- (void)keyboardWasShown:(NSNotification *)notification
{
    CGRect keyboardRect = [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [self scrollMainToUp:keyboardRect.size.height ];
}


/*!
 *  @discussion Method sets new origin to main scroll
*/
- (void)scrollMainToUp:(int)up{
    
    [UIView animateWithDuration:.2 animations:^{
        [self.view setFrame:CGRectMake(self.view.bounds.origin.x,
                                       self.view.bounds.origin.y- up,
                                       self.view.bounds.size.width,
                                       self.view.bounds.size.height)];
    }];
}







- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

/*!
 *
 *  @discussion Method dismisses self
*/

-(IBAction)back{
    
    [[ABStoreManager sharedManager]  flushData];
    
    [self presentViewController:[[emsProfileVC alloc] init] animated:YES completion:^{
        [self clearData];
    }];
    
}

/*!
 * 
 *  @discussion Method sets user data
*/

-(void)initActivitiesAndUserData:(NSArray *)userImagesArray
{
    
    for(int i = [userImagesArray count];i<4;i++)
    {
        [_allActivities addObject:@"photo_bg_small"];
        
        EditProfileImage *editProfileImage = [[EditProfileImage alloc] init];
        
        editProfileImage.path246x246 = @"photo_bg_small";
        
        [self.parseDIctionaryArray addObject:editProfileImage];
        
    }
    
}

/*!
 *
 *  @discussion Method if array count  < 4 add custom images in images array
*/

-(void)deletingImagesAarray:(NSArray *)userImagesArray
{
    for(int i = (int)[userImagesArray count];i<4;i++)
    {
        [_allActivities addObject:@"photo_bg_small"];
    }
}


/*!
 *
 *  @discussion Method  gets image from MediaPickerViewController
*/
-(IBAction)addImages{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ActivityBuilder_4" bundle:nil];
    MediaPickerViewController *notebook = [storyboard instantiateViewControllerWithIdentifier:@"MediaPicker"];
    notebook.mediaPickerType = MediaPickerTypeEditeProfile;
    
    [self presentViewController:notebook animated:YES completion:^{
        
    }];
    
}

/*!
 *
 *  @discussion Method  presents emsEditProfileInterestsVC
*/
-(void)addSpectatorInterests{
    
    emsEditProfileInterestsVC *vc = [[emsEditProfileInterestsVC alloc] initWithData: self.selectedInterestSpectator];
    
    vc.interestType = editSpectatorInterests;
    
    [self presentViewController:vc animated:YES completion:^{
        
    }];
    
}

/*!
 *
 *  @discussion Method  presents emsEditProfileInterestsVC
*/

-(void)addActivityInterests{
    
    emsEditProfileInterestsVC *vc = [[emsEditProfileInterestsVC alloc] initWithData:self. selectedInterestsActivity];
    
    vc.interestType = editActivityInterests;
    
    [self presentViewController:vc animated:YES completion:^{
        
        
    }];
}



/*!
 *
 *  @discussion Method sets image as selectad
*/
-(void)selectrdImage:(NSString *)image andIndex:(int)imageIndex{
    
    EditProfileImage *editProfileImage = [self.parseDIctionaryArray objectAtIndex:imageIndex];
    
    detailImageShow = YES;
    
    self.indexForDeleting = imageIndex;
    
    detailImageView.frame = CGRectMake(0, 0 , 320, 580);
    
    [self.view addSubview: detailImageView];
    
    self.detailImage.image = [UIImage imageNamed:@"placeholder"];
    
    [self downloadImage:image andIndicator:nil addToImageView: self.detailImage];
    
    [self showDetailImage:[editProfileImage.isPrimary boolValue] andDeleted:editProfileImage.isDeleted andVideo:editProfileImage.isVideo];
    
}


/*!
 *
 *  @discussion Method sets image detail screen
*/

-(void)showDetailImage:(BOOL)isMaineImage andDeleted:(BOOL)deleted andVideo:(BOOL)isVideo{
    
    if (!deleted && isVideo) {
        self.deleteImageBtn.hidden =NO;
        self.restoreImageBtn.hidden = YES;
        self.takeMainBtn.hidden = YES;
    }
    else if (deleted) {
        self.deleteImageBtn.hidden = YES;
        self.restoreImageBtn.hidden = NO;
    }
    
    else if (deleted && isVideo) {
        self.deleteImageBtn.hidden = YES;
        self.restoreImageBtn.hidden = NO;
    }
    
    else if (isMaineImage) {
        self.deleteImageBtn.hidden = YES;
        self.takeMainBtn.hidden = YES;
        self.restoreImageBtn.hidden = YES;
    }else{
        self.deleteImageBtn.hidden = NO;
        self.takeMainBtn.hidden = NO;
        self.restoreImageBtn.hidden = YES;
    }
    detailImageView.hidden = NO;
    detailImageView.alpha = 0 ;
    [UIView animateWithDuration:.5 animations:^{
        detailImageView.alpha = 1 ;
        
    } completion:^(BOOL finished) {
        
    }];
    
}
/*!
 *  
 *  @discussion Method hides image dettail screen
*/
-(IBAction)hideImage{
    
    [UIView animateWithDuration:.5 animations:^{
        detailImageView.alpha = 0 ;
    } completion:^(BOOL finished) {
        [detailImageView removeFromSuperview];
        self.detailImage.image = nil;
    }];
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
                targetView.image = [UIImage imageNamed:@"placeholder"];
            }
            if (image == nil) {
                
                targetView.image = [UIImage imageNamed:@"placeholder"];
                
            }else{
                targetView.image = image;
                [indicator stopAnimating];
            }
        });
    });
    
}




/*!
 *
 *  @discussion Method deletes image
*/

-(IBAction)deleteImage:(id)sender{
    
    EditProfileImage *editProfileImage = [self.parseDIctionaryArray objectAtIndex:self.indexForDeleting];
    editProfileImage.isDeleted = YES;
    [self deletingImagesAarray:_allActivities];
    NSArray * arr =  [[ABStoreManager sharedManager] getEditProfileDictiomary][@"files"];
    [arr objectAtIndex:self.indexForDeleting];
    [self.imagesForDeleting addObject:[arr objectAtIndex:self.indexForDeleting][@"id"]];
    [self.editProfileScroll reloadData:self.parseDIctionaryArray];
    [self hideImage];
    
}

/*!
 *  
 *  @discussion Method sets  picture as an avatar
*/
-(IBAction)takeMain:(id)sender{
    
    for (EditProfileImage *editProfileImage  in self.parseDIctionaryArray ) {
        editProfileImage.isPrimary = @"0";
        if ([editProfileImage.imageId isEqualToString:[NSString stringWithFormat:@"%@", [self.apiDictionary[@"files"] objectAtIndex:self.indexForDeleting][@"id"]]]) {
            editProfileImage.isPrimary = @"1";
            editProfileImage.isDeleted = NO;
        }
    }
    self.mainImageID = [NSString stringWithFormat:@"%@", [self.apiDictionary[@"files"] objectAtIndex:self.indexForDeleting][@"id"]];
    [self hideImage];
    [self.editProfileScroll reloadData:self.parseDIctionaryArray];
}

/*!
 *
 *  @discussion Method saves changes and dismiss self
*/
-(IBAction)doneEditing:(id)sender{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.aboutUserTextView.text forKey:@"aboutMe" ];
    [dict setObject:[[UserDataManager sharedManager] serverToken] forKey:@"restToken"];
    
    if (![self.mainImageID isEqualToString:@""]&& self.mainImageID != nil) {
        [dict setObject:self.mainImageID forKey:@"primaryUserImgId"];//
    }
    if ([self.imagesForDeleting count]) {
        [dict setObject:self.imagesForDeleting forKey:@"toRemoveUserImgIds"];//
    }
    
    [Server postProfileInfoandUserID:dict callback:^(NSDictionary *dictionary) {
        
        [[ABStoreManager sharedManager] setEditProfileMode:NO];
        
        [[ABStoreManager sharedManager]  flushData];
        
        [self presentViewController:[[emsProfileVC alloc] init] animated:YES completion:^{
            [self clearData];
        }];
        
    }];
}


/*!
 *@discussion Method cancels image deleting *
*/

-(IBAction)cancelDeletingActionandIndex:(int)imageIndex{
    
    EditProfileImage *editProfileImage = [self.parseDIctionaryArray objectAtIndex:self.indexForDeleting];
    editProfileImage.isDeleted = NO;
    [self.imagesForDeleting removeObject:@([editProfileImage.imageId intValue]) ];
    [self.editProfileScroll reloadData:self.parseDIctionaryArray];
    
    [self hideImage];
}









/*!
 *  @discussion Sets Popup Custom Progress bar with blured background and Scadaddle
 *
*/
-(void)updationLocationThread
{
    
    popup = [[ScadaddlePopup alloc] initWithFrame:self.view.frame withTitle:@"Loading location..." withProgress:YES andButtonsYesNo:NO forTarget:self andMessageType:-1];
    [self.view addSubview:popup];
    
}
-(void)startUpdatingLocation
{
    //   [NSThread detachNewThreadSelector:@selector(updationLocationThread) toTarget:self withObject:nil];
    
}
-(void)startUpdating
{
    
    popup = [[ScadaddlePopup alloc] initWithFrame:self.view.frame withTitle:@"Loading..." withProgress:YES andButtonsYesNo:NO forTarget:self andMessageType:-1];
    [self.view addSubview:popup];
    
}
-(void)dismissPopupAction
{
    [UIView animateWithDuration:0.01 animations:^{
        
        popup.alpha=0.9;
    } completion:^(BOOL finished) {
        
        [popup removeFromSuperview];
        
    }];
    
    
}
-(IBAction)dismissPopup
{
    
    [self dismissPopupAction];
}
/*!
 *@discussion Method called to clean class instances
 *
*/
-(void)clearData{
    
    for (UIView *view in self.view.subviews) {// временный dealloc
        [view removeFromSuperview];
    }
    self.editProfileScroll = nil;
    
    [_apiDictionary removeAllObjects];
    [_parseDIctionaryArray removeAllObjects];
    [_selectedInterestsActivity removeAllObjects];
    [_selectedInterestSpectator removeAllObjects];
    
}

@end
