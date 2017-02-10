//
//  MediaPickerViewController.h
//  ActivityCreator
//
//  Created by Roman Bigun on 5/7/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

typedef NS_ENUM(NSUInteger, MediaPickerType) {
    MediaPickerTypeActivity = 0,
    MediaPickerTypeEditeProfile
};

@interface MediaPickerViewController : UIViewController<IGRequestDelegate>
{
     UIImagePickerController *imgPicker;
     CGFloat previousScale;

}
@property (nonatomic, assign) MediaPickerType mediaPickerType;
@property(nonatomic,weak)IBOutlet UIButton *chooseInstagramBtn;
@property(nonatomic,weak)IBOutlet UIButton *doneBtn;
@property(nonatomic,weak)IBOutlet UIButton *chooseFacebookBtn;
@property(nonatomic,weak)IBOutlet UIButton *chooseFromGaleryBtn;
@property(nonatomic,weak)IBOutlet UIButton *makeFromCamera;
@property(nonatomic,weak)IBOutlet UIView *cropperBackground;
@property(nonatomic,weak)IBOutlet UIView *cropperTop;
@property(nonatomic,weak)IBOutlet UIView *cropperBottom;
@property(nonatomic,weak)IBOutlet UIButton *cropperDone;
@property(nonatomic,weak)IBOutlet UIButton *clearImageBtn;
@property(nonatomic,weak)IBOutlet UIImageView *cropperPhotoFrame;
@property(nonatomic,retain)UIImage *curImage;
@property(nonatomic,retain)NSDictionary *curYoutubeObject;
@property(nonatomic,weak)IBOutlet UIButton *editProfileBack;
@property(nonatomic,weak)IBOutlet UIButton *youtubePlayBtn;
@property(nonatomic,weak)IBOutlet UILabel *litleIabel;
@property(nonatomic,weak)IBOutlet UIButton *cropperCancel;
@property(nonatomic,weak)IBOutlet UIView *buttonsBgView;
@property(nonatomic,weak)IBOutlet UIImageView *scadLabel;
@property(nonatomic,weak)IBOutlet UILabel *captionLabel;
@property(nonatomic,weak)IBOutlet UILabel *titleLbl;
@property(nonatomic,weak)IBOutlet UIButton *faceBookButtonForChat;
@property(nonatomic,weak)IBOutlet UIButton *youtubeBtnGo;
@property(nonatomic,weak)IBOutlet UIButton *instagramForChatBtn;
-(id)initWithData:(UIImage*)currentImage;
@end
