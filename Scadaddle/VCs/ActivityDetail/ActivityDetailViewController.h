//
//  ActivityDetailViewController.h
//  Scadaddle
//
//  Created by Roman Bigun on 6/22/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MemberTableViewCell.h"
@interface ActivityDetailViewController : UIViewController<CellControllerDelegate,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
{


    MKAnnotationView *pinView;
    __block NSString *whereAmI;
    __block CLPlacemark *placemark;
}
@property (nonatomic, retain) UIDocumentInteractionController *documentController;
@property (strong, nonatomic) IBOutlet UIView *footerDinamicView;
@property (weak, nonatomic) IBOutlet UIView *placesLeftView;
@property(nonatomic,retain) UIScrollView *activityPhotoScroll;
@property(nonatomic,retain) UIScrollView *interestsScroll;
@property(nonatomic,retain)IBOutlet UIView *passedView;
@property(nonatomic,retain)IBOutlet UIView * left;
@property(nonatomic,retain)IBOutlet UILabel * pCount;
@property(nonatomic,retain)IBOutlet UIView *right;
@property(nonatomic,retain)IBOutlet UILabel *member;
@property(nonatomic,retain)IBOutlet UIImageView *passedImage;
@property(nonatomic,retain)IBOutlet UIScrollView *mainScroll;
@property(nonatomic,retain)IBOutlet MKMapView *locationMap;
@property(nonatomic,retain)IBOutlet UITableView *membersTable;
@property(nonatomic,retain)IBOutlet UITableView *scheduledTable;
@property(nonatomic,retain)IBOutlet UILabel *distanseLbl;
@property(nonatomic,retain)IBOutlet UILabel *nameLbl;
@property(nonatomic,retain)IBOutlet UILabel *aboutLbl;
@property(nonatomic,retain)IBOutlet UILabel *locationLbl;
@property(nonatomic,retain)IBOutlet UILabel *placesLbl;
@property(nonatomic,retain)IBOutlet UIImageView *interestImage;
@property(nonatomic,retain)IBOutlet UIImageView *authorImage;
@property(nonatomic,retain)IBOutlet UILabel *authorNameLbl;
@property(nonatomic,retain)IBOutlet UIButton *gPlusBtn;
@property(nonatomic,retain)IBOutlet UIButton *twitterBtn;
@property(nonatomic,retain)IBOutlet UIButton *facebookBtn;
@property(nonatomic,retain)IBOutlet UIButton *instagramBtn;
@property(nonatomic,retain)IBOutlet UILabel *topLeftLbl;
@property(nonatomic,retain)IBOutlet UILabel *topRightLbl;
-(void)clearData;
-(id)initWithData:(NSDictionary*)incomeData;
@end
