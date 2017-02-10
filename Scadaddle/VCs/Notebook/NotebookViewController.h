//
//  NotebookViewController.h
//  Notebook
//
//  Created by Roman Bigun on 5/18/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotebookTableViewCell.h"
#import "emsScadaddleActivityIndicator.h"



@interface NotebookViewController : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,CellControllerDelegate>
{

    int currentStatusMode;
    BOOL afterManipulation;
    NSMutableDictionary *params;
}
@property(nonatomic)FilterType filterType;
@property(nonatomic,weak)IBOutlet UIButton *btnFilterAll;
@property(nonatomic,weak)IBOutlet UIButton *searchBtn;
@property (nonatomic, strong)IBOutlet UISearchBar *mySearchBar;
@property (nonatomic, strong) NSString *queryString;
@property(nonatomic,weak)IBOutlet UILabel *notificationLbl;
@property(nonatomic,weak)IBOutlet UIImageView *notificationBg;
@property(nonatomic,weak)IBOutlet UIButton *btnFilterBlocks;
@property(nonatomic,weak)IBOutlet UIButton *btnFilterFriends;
@property(nonatomic,weak)IBOutlet UIButton *btnFilterIcebreaker;
@property(nonatomic,weak)IBOutlet UIButton *btnFilterFollowers;
@property(nonatomic,weak)IBOutlet UIView *shtorka;
@property(nonatomic,weak)IBOutlet UIView *noContents;
@property(nonatomic,weak)IBOutlet UIImageView *noContentsBG;
@property(nonatomic,weak)IBOutlet UIActivityIndicatorView *shtorkaIndicator;
@property (nonatomic, strong) emsScadaddleActivityIndicator *activityHeader;
@property (nonatomic, strong) emsScadaddleActivityIndicator *activityFooter;
-(void)clearData;
@end
