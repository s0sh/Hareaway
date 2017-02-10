//
//  ActivityGeneralViewController.h
//  ActivityCreator
//
//  Created by Roman Bigun on 5/6/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseScroller.h"
//#import "Flurry.h"
@interface ActivityGeneralViewController : UIViewController</*FlurryDelegate*/UITextFieldDelegate,UITextViewDelegate,BaseScrollerDelegate>

@property(nonatomic,strong)IBOutlet UIScrollView *mainScroll;
@property(nonatomic,strong)IBOutlet UITextField *titleTextField;
@property(nonatomic,strong)IBOutlet UITextField *descriptionTextField;
@property(nonatomic,strong)IBOutlet UITextField *rewardInfoTextField;
@property(nonatomic,strong)IBOutlet UITextField *numberOfPlacesTextField;
@property(nonatomic,strong)IBOutlet UILabel *descriptionSymbolsLbl;
@property(nonatomic,strong)IBOutlet UILabel *max99Lable;
@property(nonatomic,strong)IBOutlet UILabel *rewardSymbolsLbl;
@property(nonatomic,strong)IBOutlet UILabel *captionLbl;
@property(nonatomic,strong)IBOutlet UIView *activityImageManBlackBackground;
@property(nonatomic,strong)IBOutlet UIView *activityImageManClearBackground;
@property(nonatomic,strong)IBOutlet UIImageView *activityImageDisplayView;
@property(nonatomic,weak)IBOutlet UIButton *backButton;
@property(nonatomic,weak)IBOutlet UIButton *deleteImageBtn;
@property(nonatomic,weak)IBOutlet UIButton *makeMainImageBtn;
@property(nonatomic,weak)IBOutlet UIButton *closeImageBtn;
@end
