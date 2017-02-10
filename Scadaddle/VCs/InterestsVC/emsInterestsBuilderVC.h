//
//  emsInterestsVC.h
//  Scadaddle
//
//  Created by developer on 30/03/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "Flurry.h"

@interface emsInterestsBuilderVC : UIViewController<UISearchBarDelegate,UITextFieldDelegate>

{

    NSCache *_imageCache;
    BOOL isSpectatorInterest;

}
@property (nonatomic, strong)IBOutlet UISearchBar *mySearchBar;
@property (nonatomic, strong) NSString *queryString;
@property (nonatomic, weak)IBOutlet UITableView *table;
@property (nonatomic, weak) IBOutlet UIButton *nextBtn;
@property (nonatomic, weak) IBOutlet UIButton *spectatorBtn;
@property (nonatomic, weak) IBOutlet UIButton *activityBtn;
@property(nonatomic,weak)IBOutlet UIView *shtorka;
@property(nonatomic,weak)IBOutlet UIActivityIndicatorView *shtorkaIndicator;
@property(retain)NSMutableArray *interestsArray;
@property(retain)NSMutableArray *yourOwnInterestsArray;
@property(retain)NSMutableArray *fasebookInterestsArray;
@property(retain)NSMutableArray *publicInterestsArray;
@property(retain)NSMutableArray *preloadedInterestsArray;
@property(retain)NSMutableArray *selectedInterests;
@property(retain)NSMutableArray *fbInterests;
-(IBAction)dismissPopup;
@property(retain,nonatomic)NSMutableDictionary *fbInterestsCategories;
@property(nonatomic) BOOL hideBackButton;
@property (nonatomic, weak) IBOutlet UIButton *backBtn;
@end
