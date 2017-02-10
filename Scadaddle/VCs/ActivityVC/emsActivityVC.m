//
//  emsActivityVC.m
//  Scadaddle
//
//  Created by developer on 23/05/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsActivityVC.h"
#import "emsActivityCell.h"
#import "emsActivityEvent.h"
#import "emsRightMenuVC.h"
#import "emsLeftMenuVC.h"
#import "emsAPIHelper.h"
#import "ABStoreManager.h"
#import "ActivityDetailViewController.h"
#import "ScadaddlePopup.h"
#import "ActivityGeneralViewController.h"
#import "emsScadProgress.h"
#import "FBHelper.h"
//#import "emsLoginVC.h"
#import "FBWebLoginViewController.h"
@interface emsActivityVC ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UIButton *myOwnActivityBtn;
@property (nonatomic, weak) IBOutlet UIButton *followingActivityBtn;
@property (nonatomic, weak) IBOutlet UIButton *acceptedActivityBtn;
@property (nonatomic, weak) IBOutlet UIView *noContentView;
@property (nonatomic, weak) IBOutlet UIButton *byDistanceBtn;
@property (nonatomic, weak) IBOutlet UIButton *byDateBtn;
@property (nonatomic, weak) IBOutlet UIButton *myNameBtn;


@property (nonatomic, weak) IBOutlet UITableView *table;
@property (nonatomic, retain)NSMutableArray *buttonsArray;
@property (nonatomic, retain)NSMutableArray *additionButtonsArray;
@property (nonatomic, retain)NSMutableArray *myActivities;
@property (nonatomic, retain)NSMutableArray *followersActivities;
@property (nonatomic, retain)NSMutableArray *activitiesArray;
@property (nonatomic, retain)NSIndexPath *indexPathToDelete;
@property (nonatomic, retain)NSMutableArray *activitiesArrayPredicated;

@property (nonatomic, strong)IBOutlet UISearchBar *mySearchBar;
@property(nonatomic,weak)IBOutlet UIView *shtorka;
@property(nonatomic,weak)IBOutlet UIButton *searchBtn;
@property (nonatomic, strong) NSString *currentTipe;
@property (nonatomic, strong) NSString *currentOrder;
@property (nonatomic) BOOL isFirst;

@property(nonatomic,weak)IBOutlet UIView *viewWhisTableView;
@property(nonatomic,weak)IBOutlet UIView *viewWhisTextFiald;
@property(nonatomic,weak)IBOutlet UIButton *cancelBtn;
@property(nonatomic,weak)IBOutlet UITextField *searchField;
@property(nonatomic,weak)IBOutlet UIButton * searchButton;
@property(nonatomic) BOOL isShowSearch;

@end
@implementation emsActivityVC
{
    
    ScadaddlePopup *popup;
    int currentType;
    NSDictionary *tmp;
    NSString *direction;
    emsScadProgress * subView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self progress:^{
        
    }];
    _indexPathToDelete = [[NSIndexPath alloc] init];
    
    
}
-(void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:YES];
    
   //Check for search bar if it is visible or not

    if (self.isShowSearch) {
        [self cancelSearchAction];
    }
    
    for (UIButton *btn1 in self.additionButtonsArray) {
        [btn1 setSelected:NO];
    }
    UIButton *btn1 =(UIButton *)[self.additionButtonsArray objectAtIndex:0];
    [btn1 setSelected:YES];
    for (UIButton *btn in self.buttonsArray) {
        [btn setSelected:NO];
    }
    
    
     //Setup tabs. Pinpoint what exactly tab should be displayed to the user
   
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"activity"] isEqualToString:@"activity_own"])
    {
        currentType = myOwnActivity;
        UIButton *btn =(UIButton *)[self.buttonsArray objectAtIndex:0];
        [btn setSelected:YES];
    }
    else if([[[NSUserDefaults standardUserDefaults] objectForKey:@"activity"] isEqualToString:@"activity_follow"])
    {
       currentType = followActivity;
        UIButton *btn =(UIButton *)[self.buttonsArray objectAtIndex:1];
        [btn setSelected:YES];
    }
    else if([[[NSUserDefaults standardUserDefaults] objectForKey:@"activity"] isEqualToString:@"activity_accepted"])
    {
        currentType = acceptedActivity;
        UIButton *btn =(UIButton *)[self.buttonsArray objectAtIndex:2];
        [btn setSelected:YES];
    }
    
    self.myActivities  = [[NSMutableArray alloc] init];
    
    [self setUpArray];//Load Activities according to current Tab
    [self setUpButtons];//Create array of buttons for manipulation in the future
    [self stopSubview];//Dismiss progress bar
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachability:) name:@"EMSReachableChanged" object:nil];
}
/**
 * @discussion: Fire progress indicator
 */
-(void)progress:(void (^)())callback;{
    
if (subView == nil) {
    subView = [[emsScadProgress alloc] initWithFrame:self.view.frame screenView:self.view andSize:CGSizeMake(320, 580)];
    [self.view addSubview:subView];
    subView.alpha = 0;
        
        [UIView animateWithDuration:0.5 animations:^{
            subView.alpha = 1;
        } completion:^(BOOL finished) {
            
            callback();
            
        }];
     
  }
}
/**
 * @discussion: Hide progress indicator
 */
-(void)stopSubview{
    
    [UIView animateWithDuration:0.5 animations:^{
        subView.alpha = 0;
    } completion:^(BOOL finished) {
        [subView removeFromSuperview];
        subView = nil;
    }];
}

-(IBAction)dismissPopup{
// [popup removeFromSuperview];
}

/*!
 * @discussion  To add buttons to an objects array so to manupulate them statuses later on
 */
-(void)setUpButtons{
    self.buttonsArray = [[NSMutableArray alloc] init];
    self.additionButtonsArray = [[NSMutableArray alloc] init];
    [self.buttonsArray addObject:self.myOwnActivityBtn];
    [self.buttonsArray addObject:self.followingActivityBtn];
    [self.buttonsArray addObject:self.acceptedActivityBtn];
    [self.additionButtonsArray addObject:self.byDistanceBtn];
    [self.additionButtonsArray addObject:self.byDateBtn];
    [self.additionButtonsArray addObject:self.myNameBtn];
    
}

/*!
 * @discussion  Fire actions according to TAGs. Each tag corresponds to tab tag. E.g 0 for MyActivity tab etc..
 */
-(IBAction)selectBTN:(UIButton*)sender{
  [self progress:^{
      
      for (UIButton *btn in self.buttonsArray) {
          [btn setSelected:NO];
      }
      UIButton *btn =(UIButton *)[self.buttonsArray objectAtIndex:sender.tag];
      [btn setSelected:YES];
      
      if (self.isShowSearch) {
          [self cancelSearchAction];
      }
      switch (sender.tag) {
          case 0:
              [self myOwnActivities];
              break;
          case 1:
              [self followingActivities];
              break;
          case 2:
              [self acceptedActivities];
              break;
              
          default:
              break;
              
      }

  }];
    
}

/*!
 * @discussion  Fire filters according to TAGs. Each tag corresponds to filter tag. E.g 0 for ByDistance tab etc..
 */
-(IBAction)selectDescriptionBTN:(UIButton*)sender{
    
  [self progress:^{
      
    for (UIButton *btn in self.additionButtonsArray) {
        [btn setSelected:NO];
    }
    UIButton *btn =(UIButton *)[self.additionButtonsArray objectAtIndex:sender.tag];
    [btn setSelected:YES];
    if (self.isShowSearch) {
        [self cancelSearchAction];
    }
           switch (sender.tag) {
               case 0:
                   [self byDictanceAction];
                   break;
               case 1:
                   [self byDateAction];
                   break;
               case 2:
                   [self byNameAction];
                   break;
                   
               default:
                   break;
                   
        }
           
   }];
  
}

/*!
 * @discussion to download image by path 
 * @param coverUrl absolute path to image
 * @param imageName we use it as a unique key to save image in cache
 */
-(UIImage *)downloadImage:(NSString *)coverUrl andIndicator:(UIActivityIndicatorView*)indicator andImageName:(NSString*)imageName{
    UIImage *image = [UIImage new];
    
    NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:coverUrl]];
    image  = [UIImage imageWithData:imageData];
    [indicator stopAnimating];
    if(image)
    {
        [[[ABStoreManager sharedManager] imageCache] setObject:image forKey:imageName];
        
    }
    
    
    return image;
    
}

/*!
 * @discussion  check whether image with path @param path cached or not.
 * If cached. add image to target else returns NO to start download
 * @param path path to image
 */
-(BOOL)imageHandler:(NSString*)path
{
    if([[[ABStoreManager sharedManager] imageCache] objectForKey:path]!=nil)
    {
        return YES;
    }
    return NO;
}

/*!
 * @discussion  Creates Activities objects and reload data with new
 * Entities
 */
-(void)setupActivities:(NSString*)type andOrder:(NSString*)order
{

    self.currentTipe = type;
    self.currentOrder  = order;
    if([direction isEqualToString:@"asc"]){
       direction = @"desc";
    }else{
       direction = @"asc";
    }
  
    [self.myActivities removeAllObjects];
    [self.activitiesArrayPredicated removeAllObjects];
    self.noContentView.alpha=1;
    tmp = [NSDictionary dictionaryWithDictionary:[Server getActivitiesByType:type orderBy:order andDirection:direction]];
    self.myActivities  = [NSMutableArray arrayWithArray:tmp[@"activities"]];
    
    if(self.myActivities.count>0)
    {
        for (int i = 0; i<self.myActivities.count; i++) {
         
                               
                               emsActivityEvent *activityEvent = [[emsActivityEvent alloc] init];
                               if(![self imageHandler:self.myActivities[i][@"activityImg"]])
                               {
                                   
                                   activityEvent.image = [self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,self.myActivities[i][@"activityImg"]]
                                                                andIndicator:nil andImageName:self.myActivities[i][@"activityImg"]];
                               }
                               else
                               {
                                   
                                   activityEvent.image = [[[ABStoreManager sharedManager] imageCache] objectForKey:self.myActivities[i][@"activityImg"]];
                                   
                               }
                               if(![self imageHandler:self.myActivities[i][@"actPrimaryInterestsImg"]])
                               {
                                   activityEvent.interestImage =[self downloadImage:[NSString stringWithFormat:@"%@%@",SERVER_PATH,self.myActivities[i][@"actPrimaryInterestsImg"]]
                                                                       andIndicator:nil andImageName:self.myActivities[i][@"actPrimaryInterestsImg"]];
                               }
                               else
                               {
                                   
                                   activityEvent.interestImage = [[[ABStoreManager sharedManager] imageCache] objectForKey:self.myActivities[i][@"actPrimaryInterestsImg"]];
                                   
                               }
                               activityEvent.distance = [[NSString stringWithFormat:@"%@",self.myActivities[i][@"distance"]] intValue];
                               activityEvent.date = [NSString stringWithFormat:@"%@",self.myActivities[i][@"date"]];
                               activityEvent.title = [self.myActivities[i][@"title"] uppercaseString];
                               activityEvent.subtitle = self.myActivities[i][@"description"];
                               activityEvent.activityEventType = currentType;
                               
                             
                                                  [self.activitiesArrayPredicated addObject:activityEvent];
                                                  [self.table reloadData];
                                                  [self dismissPopup];
                                                  [self stopSubview];
                                                  
                          
            
            self.noContentView.alpha=0;
        }
    }
    else
    {
        self.noContentView.alpha=1;
        [self dismissPopup];
        [self stopSubview];
        [self.table reloadData];
    }
    
}

/*!
  * @discussion  fill in array of activities according to requested type
  * @types could be myOwnActivity/followActivity/kRequestAcceptedActivities
  * @ordered by name at first
  */
-(void)setUpArray{
    
    //[self progress];
    self.activitiesArrayPredicated = [[NSMutableArray alloc] init];
    if(currentType == myOwnActivity){
       [self setupActivities:kRequestAllActivities andOrder:@"name"];
    }
    if(currentType == followActivity){
        [self setupActivities:kRequestFollowingActivities andOrder:@"name"];
    }
    if(currentType == acceptedActivity){
        [self setupActivities:kRequestAcceptedActivities andOrder:@"name"];
    }
    
}
-(void)reachability:(NSNotification *)notification
{
    
    BOOL status = notification.userInfo[@"status"];
    {
        
        if(status==YES){
            [self stopSubview];
        }else if(status == NO){
            [self progress:^{
            
            }];
        }
    }
    
}

/*!
 * @discussion  Passes activity ID and go to the Activity Builder to
 * edit choosen Activity
 */
-(IBAction)editActivity:(UIButton*)sender
{
   
    [self progress:^{
        
    }];
    [[ABStoreManager sharedManager] setModeEditing:YES];//Should be set before load ActivityBuilder if you want to edit activity
    [[ABStoreManager sharedManager] settleEditingActivityID:[NSString stringWithFormat:@"%li",(long)sender.tag]];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ActivityBuilder_4" bundle:nil];
    ActivityGeneralViewController *dreamShot = [storyboard instantiateViewControllerWithIdentifier:@"ActivityGeneralViewController"];
    [self presentViewController:dreamShot animated:YES completion:^{
       [self stopSubview];
    }];
    
    
}

/*!
 * @discussion  Go to Activity Builder so to create new Activity
 */
-(IBAction)newActivity
{
 
    [self progress:^{
        
    }];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ActivityBuilder_4" bundle:nil];
    ActivityGeneralViewController *dreamShot = [storyboard instantiateViewControllerWithIdentifier:@"ActivityGeneralViewController"];
    [self presentViewController:dreamShot animated:YES completion:^{
         [self stopSubview];
    }];
    
}

/*!
 * @discussion  Follow activity button pressed.
 */
-(IBAction)followActivity:(UIButton*)sender
{
    [self progress:^{
        
    }];
    [Server followActivity:[NSString stringWithFormat:@"%ld",(long)sender.tag] callback:^{
        [self setupActivities:kRequestAcceptedActivities andOrder:@"name"];
        [self stopSubview];
    }];
    
}

/*!
 * @discussion  Convert unix timestamp into readable string format
 * @param timeObj unix timestamp
 */
-(NSString*)strDate:(NSString*)timeObj
{
    
    double unixTimeStamp =[timeObj doubleValue];
    NSTimeInterval _interval=unixTimeStamp;
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:_interval];
    NSDateFormatter *formatter= [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    return [formatter stringFromDate:date];
    
}

/*!
 * @discussion  to ask user to choose whether he want to remove/hide current activity
 */
-(void)delUserAction:(UIButton*)sender{
    
    _indexPathToDelete = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    if(currentType != myOwnActivity)
    {
        UIAlertView *warning = [[UIAlertView alloc] initWithTitle:@"Hide Activity"
                                                          message:@"Are you sure you want to hide this activity?"
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Ok", nil];
        [warning show];
    }
    else
    {
    
        UIAlertView *warning = [[UIAlertView alloc] initWithTitle:@"Remove Activity"
                                                          message:@"Are you sure you want to remove this activity?"
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Ok", nil];
        [warning show];
        
    }
    
}

/*!
 * @discussion  One option allowed at this moment -> removeActivity
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        [self removeActivity];
    }
}

/*!
 * @discussion  if this is my own activity - delete it. Otherwise - unfollow.
 */
-(void)removeActivity
{
    [self progress:^{
        
    }];
    if(currentType == myOwnActivity)
    {
        if([Server removeActivity:[[self.myActivities objectAtIndex:_indexPathToDelete.row] valueForKey:@"aId"]])
        {
            if(self.myActivities.count>0)
                [self.myActivities removeObjectAtIndex:_indexPathToDelete.row];
            if(self.activitiesArrayPredicated.count>0)
                [self.activitiesArrayPredicated removeObjectAtIndex:_indexPathToDelete.row];
            [self dismissPopup];
            [self stopSubview];
            [self.table reloadData];
            
        }
    }else
    {
        [Server unfollowActivity:[[self.myActivities objectAtIndex:_indexPathToDelete.row] valueForKey:@"aId"]  callback:^{
            
            if(self.myActivities.count>0)
                [self.myActivities removeObjectAtIndex:_indexPathToDelete.row];
            if(self.activitiesArrayPredicated.count>0)
                [self.activitiesArrayPredicated removeObjectAtIndex:_indexPathToDelete.row];
            [self dismissPopup];
            [self stopSubview];
            [self.table reloadData];
            
        }];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

/*!
 * @discussion  Goes to Activity Details page
 */
-(void)userInfoAction:(UIButton*)sender
{
    
    [self progress:^{
        
    }];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:[NSNumber numberWithUnsignedInteger:kPIActivityesScreen]
                  forKey:@"fromScreen"];
        [prefs synchronize];
        
        [self presentViewController:[[ActivityDetailViewController alloc]
                                     initWithData:[self.myActivities objectAtIndex:sender.tag]]
                                      animated:YES completion:^{
            [self stopSubview];
        }];
}


-(IBAction)myOwnActivities{
    currentType = myOwnActivity;
    [self progress:^{
        
    }];
    [self setupActivities:kRequestAllActivities andOrder:@"name"];
    [[NSUserDefaults standardUserDefaults] setValue:@"activity_own" forKey:@"activity"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
-(IBAction)followingActivities{
  
    currentType = followActivity;
    [self setupActivities:kRequestFollowingActivities andOrder:@"name"];
    [[NSUserDefaults standardUserDefaults] setValue:@"activity_follow" forKey:@"activity"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
-(IBAction)acceptedActivities{
    currentType = acceptedActivity;
    [self setupActivities:kRequestAcceptedActivities andOrder:@"name"];
    [[NSUserDefaults standardUserDefaults] setValue:@"activity_accepted" forKey:@"activity"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(NSArray *)activityPredicate{
    return [self.activitiesArrayPredicated  filteredArrayUsingPredicate:
            [NSPredicate predicateWithFormat:@"activityEventType == 0"]];
}
-(NSArray *)singlePredicate{
    return [self.activitiesArrayPredicated  filteredArrayUsingPredicate:
            [NSPredicate predicateWithFormat:@"activityEventType == 1"]];
}
-(NSArray *)datePredicate{
    return [self.activitiesArrayPredicated sortedArrayUsingDescriptors:
            @[[[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES] ]]; ;
}
-(NSArray *)distancePredicate{
    return [self.activitiesArrayPredicated sortedArrayUsingDescriptors:
            @[[[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES] ]] ;
}
-(NSArray *)namePredicate{
    return [self.activitiesArrayPredicated sortedArrayUsingDescriptors:
            @[[[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES] ]] ;
}

-(IBAction)byDictanceAction{
    switch (currentType) {
        case myOwnActivity:
            [self setupActivities:kRequestAllActivities andOrder:@"distance"];
            break;
        case followActivity:
            [self setupActivities:kRequestFollowingActivities andOrder:@"distance"];
            break;
        case acceptedActivity:
            [self setupActivities:kRequestAcceptedActivities andOrder:@"distance"];
            break;
        default:
            break;
    }
}
-(IBAction)byNameAction{
    switch (currentType) {
        case myOwnActivity:
            [self setupActivities:kRequestAllActivities andOrder:@"name"];
            break;
        case followActivity:
            [self setupActivities:kRequestFollowingActivities andOrder:@"name"];
            break;
        case acceptedActivity:
            [self setupActivities:kRequestAcceptedActivities andOrder:@"name"];
            break;
        default:
            break;
    }
    
}
-(IBAction)byDateAction{
    switch (currentType) {
        case myOwnActivity:
            [self setupActivities:kRequestAllActivities andOrder:@"date"];
            break;
        case followActivity:
            [self setupActivities:kRequestFollowingActivities andOrder:@"date"];
            break;
        case acceptedActivity:
            [self setupActivities:kRequestAcceptedActivities andOrder:@"date"];
            break;
        default:
            break;
    }
    
}
-(void)reloadTable:(NSArray *)arr{
    [self.activitiesArrayPredicated removeAllObjects];
    [self.activitiesArrayPredicated addObjectsFromArray:arr];
    [self.table reloadData];
    
}

-(IBAction)showSearchBar
{
    if (self.isShowSearch == NO) {
        self.isShowSearch = YES;
        [UIView animateWithDuration:.3 animations:^{
          self.viewWhisTableView.frame = CGRectMake( self.viewWhisTableView.frame.origin.x,
                                                    self.viewWhisTableView.frame.origin.y + 44,
                                                    self.viewWhisTableView.frame.size.width,
                                                    self.viewWhisTableView.frame.size.height);
       
        } completion:^(BOOL finished) {
                [UIView animateWithDuration:.3 animations:^{
                      self.viewWhisTextFiald.frame = CGRectMake( self.viewWhisTextFiald.frame.origin.x - 320,
                                                                self.viewWhisTextFiald.frame.origin.y,
                                                                self.viewWhisTextFiald.frame.size.width,
                                                                self.viewWhisTextFiald.frame.size.height);
                } completion:^(BOOL finished) {
                    [self.table reloadData];
                }];
        }];
    }
}

/*!
 * @discussion  Cancel Search without reloading table
 */
-(IBAction)cancelSearchAction
{
    self.isShowSearch = NO;
    self.searchField.text = @"";
    [self.searchField resignFirstResponder];
    
    [UIView animateWithDuration:.3 animations:^{
    self.viewWhisTextFiald.frame = CGRectMake( self.viewWhisTextFiald.frame.origin.x + 320,
                                              self.viewWhisTextFiald.frame.origin.y,
                                              self.viewWhisTextFiald.frame.size.width,
                                              self.viewWhisTextFiald.frame.size.height);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:.3 animations:^{
          self.viewWhisTableView.frame = CGRectMake(self.viewWhisTableView.frame.origin.x,
                                                    self.viewWhisTableView.frame.origin.y - 44,
                                                    self.viewWhisTableView.frame.size.width,
                                                    self.viewWhisTableView.frame.size.height);
            
        } completion:^(BOOL finished) {}];
        
    }];
}

/*!
 @discussion  Cancel search and reload table
 */
-(IBAction)cancelSearchActionWhishReloading
{
    self.isShowSearch = NO;
    self.searchField.text = @"";
    [self.searchField resignFirstResponder];
    
    [UIView animateWithDuration:.3 animations:^{
        
        self.viewWhisTextFiald.frame = CGRectMake(self.viewWhisTextFiald.frame.origin.x + 320,
                                                  self.viewWhisTextFiald.frame.origin.y ,
                                                  self.viewWhisTextFiald.frame.size.width,
                                                  self.viewWhisTextFiald.frame.size.height);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:.3 animations:^{
            self.viewWhisTableView.frame = CGRectMake(self.viewWhisTableView.frame.origin.x,
                                                      self.viewWhisTableView.frame.origin.y - 44,
                                                      self.viewWhisTableView.frame.size.width,
                                                      self.viewWhisTableView.frame.size.height);
            
        } completion:^(BOOL finished) {
            [self searchActivicies:@""];
        }];
        
    }];
}

/*!
 * @discussion  User tapped 'Search' button. Start searching with subtext 
 * @see self.searchField.text
 */
-(IBAction)cearchAction{
   [self.searchField resignFirstResponder];
   [self handleSearch:self.searchField.text];
   
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
   [self handleSearch:textField.text];
    [textField resignFirstResponder];
    
    return YES;
}
- (void)handleSearch:(NSString *)searchString {
    
      [self searchActivicies:searchString];

}
-(void)configureDatasourceAccordingToSearchRequest:(BOOL)restore
{
  
}

/*!
 * @discussion to find activity by substring
 * @param searchString substring to search with
 */
-(void)searchActivicies:(NSString*)searchString
{
    [self progress:^{
        
    }];
    
    [self.myActivities removeAllObjects];
    [self.activitiesArrayPredicated removeAllObjects];
    self.noContentView.alpha=1;
    [Server searchActivities:self.currentTipe
                     orderBy:self.currentOrder
                andDirection:@"desc"
             andSearchString:searchString
     
                    callback:^(NSDictionary * res) {
                        
                        self.myActivities  = [NSMutableArray arrayWithArray:res[@"activities"]];
                        
                        if(self.myActivities.count>0){
                            for (int i = 0; i<self.myActivities.count; i++) {
                                
                                emsActivityEvent *activityEvent = [[emsActivityEvent alloc] init];
                                if(![self imageHandler:self.myActivities[i][@"activityImg"]])
                                {
                                    
                                    activityEvent.image = [self downloadImage:
                                                           [NSString stringWithFormat:@"%@%@",
                                                            SERVER_PATH,
                                                            self.myActivities[i][@"activityImg"]]
                                                                 andIndicator:nil
                                                                 andImageName:self.myActivities[i][@"activityImg"]];
                                }
                                else{
                                    activityEvent.image = [[[ABStoreManager sharedManager] imageCache] objectForKey:self.myActivities[i][@"activityImg"]];
                                    
                                }
                                if(![self imageHandler:self.myActivities[i][@"actPrimaryInterestsImg"]])
                                {
                                    activityEvent.interestImage =[self downloadImage:
                                                                  [NSString stringWithFormat:@"%@%@",
                                                                   SERVER_PATH,
                                                                   self.myActivities[i][@"actPrimaryInterestsImg"]]
                                                                        andIndicator:nil
                                                                        andImageName:self.myActivities[i][@"actPrimaryInterestsImg"]];
                                }
                                else
                                {
                                    
                                    activityEvent.interestImage = [[[ABStoreManager sharedManager] imageCache] objectForKey:self.myActivities[i][@"actPrimaryInterestsImg"]];
                                    
                                }
                                activityEvent.distance = [[NSString stringWithFormat:@"%@",self.myActivities[i][@"distance"]] intValue];
                                activityEvent.date = [NSString stringWithFormat:@"%@",self.myActivities[i][@"date"]];
                                activityEvent.title = [self.myActivities[i][@"title"] uppercaseString];
                                activityEvent.subtitle = self.myActivities[i][@"description"];
                                activityEvent.activityEventType = currentType;
                                [self.activitiesArrayPredicated addObject:activityEvent];
                                [self.table reloadData];
                                [self dismissPopup];
                                [self stopSubview];
                                
                                self.noContentView.alpha=0;
                            }
                        }
                        else
                        {
                            self.noContentView.alpha=1;
                            [self dismissPopup];
                            [self stopSubview];
                            [self.table reloadData];
                        }
                        
                    }];
    
}
-(void)notificationSelected:(Notification *)notification
{
    [[self.childViewControllers lastObject] willMoveToParentViewController:nil];
    [[[self.childViewControllers lastObject] view] removeFromSuperview];
    [[self.childViewControllers lastObject] removeFromParentViewController];
    
    NSLog(@"notification %lu", (unsigned long)notification);
    
}


/*!
 * @discussion  to display Notification table
 */
-(IBAction)showRightMenu{
    
    emsRightMenuVC *emsRightMenu = [ [emsRightMenuVC alloc] initWithDelegate:self];
    NSLog(@"emsLeftMenu %@",emsRightMenu.delegate);
    [[NSUserDefaults standardUserDefaults] setValue:@"activity_own" forKey:@"activity"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*!
 * @discussion  to display main menu
 */
#pragma mark -leftMenudelegate
-(IBAction)showLeftMenu{
    emsLeftMenuVC *emsLeftMenu =[[emsLeftMenuVC alloc]initWithDelegate:self ];
    NSLog(@"emsLeftMenu %@",emsLeftMenu.delegate);
    [[NSUserDefaults standardUserDefaults] setValue:@"activity_own" forKey:@"activity"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)actionPresed:(ActionsType)actionsTypel complite:(void (^)())complite{
    
    NSLog(@"actionsTypel %lu", (unsigned long)actionsTypel);
    
    
    if (actionsTypel == quitAction) {
        
        [self progressForQuit:^{
           
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FBWebLogin" bundle:nil];
            FBWebLoginViewController *notebook = [storyboard instantiateViewControllerWithIdentifier:@"FBWebLogin"];
            [self presentViewController:notebook animated:YES completion:^{
                [self stopSubviewForQuit];
                [[self.childViewControllers lastObject] willMoveToParentViewController:nil];
                [[[self.childViewControllers lastObject] view] removeFromSuperview];
                [[self.childViewControllers lastObject] removeFromParentViewController];
                
            }];
        }];
        
    }
    complite();
}

/*!
 * @discussion  remove all subviews
 */
-(void)clearData{
    
    for (UIView *view in self.view.subviews) {
        [view removeFromSuperview];
    }
}
/*!
 * @discussion  to start progress indicator
 */
-(void)progressForQuit:(void (^)())callback;{
    
    if (subView == nil) {
        subView = [[emsScadProgress alloc] initWithFrame:self.view.frame screenView:self.view andSize:CGSizeMake(320, 580)];
        [self.view addSubview:subView];
        subView.alpha = 0;
        
        [UIView animateWithDuration:0.5 animations:^{
            subView.alpha = 1;
        } completion:^(BOOL finished) {
            callback();
        }];
        
    }
}

/*!
 * @discussion  to stop progress indicator
 */
-(void)stopSubviewForQuit{
    
    [UIView animateWithDuration:0.5 animations:^{
        subView.alpha = 0;
    } completion:^(BOOL finished) {
        [subView removeFromSuperview];
        subView = nil;
    }];
}
#pragma mark -TableView delegate methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(self.activitiesArrayPredicated.count>0)
        return 2;
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==0)
        return  [self.activitiesArrayPredicated count];
    if(section==1 && self.activitiesArrayPredicated.count>0)
        return 1;
    
    return 0;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0)
        return 158;
    
    return self.isShowSearch?110:70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *cellIdentifier = [NSString stringWithFormat:@"cell%ld",(long)indexPath.row];
    emsActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        
        NSArray* xibCell = [[NSBundle mainBundle] loadNibNamed:@"emsActivityCell" owner:self options:nil];
        cell = [xibCell objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    if(indexPath.section==0)
    {
        emsActivityEvent *activityEvent = [self.activitiesArrayPredicated objectAtIndex:indexPath.row];
        cell.activityDescription.text = activityEvent.subtitle;
        cell.activityTitle.text = activityEvent.title;
        cell.activityDistance.text = [NSString stringWithFormat:@"%d yd",activityEvent.distance];
        cell.activityImage.image =activityEvent.image;
        cell.interestImage.image = activityEvent.interestImage;
        cell.deleteBtn.tag = (integer_t)indexPath.row;
        cell.infoBtn.tag = (integer_t)indexPath.row;
        cell.activityDateLbl.text  = [self strDate:[NSString stringWithFormat:@"%@",activityEvent.date]];
        
        if(currentType == acceptedActivity)
        {
            cell.deleteBtn.tag = [[NSString stringWithFormat:@"%@",[[self.myActivities objectAtIndex:indexPath.row] objectForKey:@"aId"]] integerValue];
            [cell.deleteBtn addTarget:self action:@selector(followActivity:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            
            [cell.deleteBtn addTarget:self action:@selector(delUserAction:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        
        [cell.infoBtn addTarget:self action:@selector(userInfoAction:) forControlEvents:UIControlEventTouchUpInside];
        
        if(currentType != myOwnActivity)
        {
            
            [cell.editBtn setHidden:YES];
            cell.infoBtn.frame = CGRectMake(cell.infoBtn.frame.origin.x+cell.infoBtn.frame.size.width,
                                            cell.infoBtn.frame.origin.y,
                                            cell.infoBtn.frame.size.width ,
                                            cell.infoBtn.frame.size.height);
            cell.deleteBtn.frame = CGRectMake(cell.deleteBtn.frame.origin.x+cell.deleteBtn.frame.size.width,
                                              cell.deleteBtn.frame.origin.y,
                                              cell.deleteBtn.frame.size.width,
                                              cell.deleteBtn.frame.size.height);
            
            
        }
        else
        {
            
            cell.editBtn.tag = [[NSString stringWithFormat:@"%@",
                                 [[self.myActivities objectAtIndex:indexPath.row] objectForKey:@"aId"]]
                                integerValue];
            [cell.editBtn addTarget:self action:@selector(editActivity:)
                   forControlEvents:UIControlEventTouchUpInside];
            
        }
        
    }
    else
    {
        cell.infoBtn.alpha=0;
        cell.deleteBtn.alpha=0;
        cell.editBtn.alpha=0;
        cell.activityImage.alpha=0;
        cell.alfaImage.alpha=0;
        cell.gradientCircle.alpha=0;
    }
    return cell;
}

@end
