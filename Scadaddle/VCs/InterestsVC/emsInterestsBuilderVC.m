//
//  emsInterestsVC.m
//  Scadaddle
//
//  Created by developer on 30/03/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsInterestsBuilderVC.h"
#import "emsInterestsCell.h"
#import "Interest.h"
#import "emsProfileVC.h"
#import "emsDeviceDetector.h"
#import "emsAPIHelper.h"
#import "ObjectHandler.h"
#import "UserDataManager.h"
#import "SocialsManager.h"
#import "CreateInterestViewController.h"
#import "emsDeviceManager.h"
#import "ABStoreManager.h"
#import "FriendsViewController.h"
#import "ScadaddlePopup.h"
#import "emsEditProfileVC.h"
#import "emsMainScreenVC.h"
#import "emsScadProgress.h"
#import "SCLocationViewController.h"
@interface emsInterestsBuilderVC ()<UITableViewDelegate,UITableViewDataSource>{
    
    
    ScadaddlePopup * popup;
    NSMutableArray *interestsIds;//interestId[btn.tag],section
    NSMutableArray *interestsActivityIds;//interestId[btn.tag],section
    NSMutableArray *interestsToSelect;
    NSMutableArray *incomeInterests;
    int indexCounter;
    int indexCounterActivities;
    NSInteger totalNumberOfInterests;
    NSInteger uploadCountOfInterests;
    BOOL hideLoadMoreButton ;
    NSArray * tmpSelect;
    BOOL defaultInterestUnchecked;
    BOOL defaultCreatedInterestSelectedOnce;
    BOOL editMode_checkCHoosenInterestOwn;
    BOOL editMode_checkCHoosenInterestFacebook;
    BOOL editMode_checkCHoosenInterestPreloaded;
    BOOL editMode_checkCHoosenInterestPublic;
    
    
    
    
    NSString *aiToRemove;
    
    //--Popup-------------------------
    
    NSThread *scadaddlePopupThread;
    
    //--------------------------------
    
    //-EditeProfile
    NSMutableArray *editProfileSelectedInterests;
    
    emsScadProgress * subView;
}
@property (nonatomic, weak) IBOutlet UILabel *editProfileLabel;
@property (nonatomic, weak) IBOutlet UIButton *doneBtn;
@property(nonatomic,weak)IBOutlet UIView *viewWhithTextField;
@property(nonatomic,weak)IBOutlet UIView *viewWhithTableView;
@property(nonatomic,weak)IBOutlet UIButton *cancelBtn;
@property(nonatomic,weak)IBOutlet UITextField *searchField;
@property(nonatomic,weak)IBOutlet UIButton * searchButton;
@property(nonatomic) BOOL isShowSearch;
@end

@implementation emsInterestsBuilderVC

@synthesize queryString;


-(void)viewWillAppear:(BOOL)animated{
    
}

-(void)progress{
    subView = [[emsScadProgress alloc] initWithFrame:self.view.frame screenView:self.view andSize:CGSizeMake(320, 580)];
    [self.view addSubview:subView];
    subView.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        subView.alpha = 1;
    }];
    
}
-(void)stopSubview{
    
    [UIView animateWithDuration:0.5 animations:^{
        subView.alpha = 0;
    } completion:^(BOOL finished) {
        [subView removeFromSuperview];
        subView = nil;
    }];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self handleSearch:searchBar];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    //   [self handleSearch:searchBar];
}

- (void)handleSearch:(UITextField *)searchBar {
    
    NSLog(@"User searched for %@", searchBar.text);
    self.queryString = searchBar.text;
    [searchBar resignFirstResponder];
    [self.yourOwnInterestsArray removeAllObjects];
    [self.selectedInterests removeAllObjects];
    [self.publicInterestsArray removeAllObjects];
    [self.preloadedInterestsArray removeAllObjects];
    [self.fbInterests removeAllObjects];
    [self.fasebookInterestsArray removeAllObjects];
    [self configureInterests:YES];
    
}
-(IBAction)cancelSearch:(id)sender
{

    NSLog(@"User canceled search");
    [sender resignFirstResponder];
    [self cancelSearchAction];
    [self configureInterests:NO];
    
    

}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    NSLog(@"User canceled search");
    [searchBar resignFirstResponder];
    [self configureInterests:NO];
}
-(void)flurrySessionDidCreateWithInfo:(NSDictionary *)info
{
    
   
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    ////[Flurry setDelegate:self];
    //[Flurry logEvent:@"Enter Interests[EditMode]"];
    
    self.searchField.delegate = self;
    incomeInterests = [NSMutableArray new];
      NSArray *tmp = [[NSArray alloc] init];
       if([[ABStoreManager sharedManager] editingMode])
       {
        if([[[ABStoreManager sharedManager] editingActivityData][vInterests] count]>0)
        {
            tmp = [[ABStoreManager sharedManager] editingActivityData][vInterests];
            
        }
        
        for(int i=0;i<tmp.count;i++)
        {
           
           [incomeInterests addObject:[tmp[i] isKindOfClass:[NSDictionary class]]?tmp[i][@"Iid"]:tmp[i]];
            
        }
       }
       else
       {
           if([[[ABStoreManager sharedManager] ongoingActivity][vInterests] count]>0)
           {
               tmp = [[ABStoreManager sharedManager] ongoingActivity][vInterests];
               
           }
           
           for(int i=0;i<tmp.count;i++)
           {
               
               [incomeInterests addObject:[tmp[i] isKindOfClass:[NSDictionary class]]?tmp[i][@"Iid"]:tmp[i]];
               
           }
       
       }
    
    
    [self setUI];
    
    self.table.delegate=self;
    tmpSelect = [[NSArray alloc] init];
    isSpectatorInterest = YES;
    totalNumberOfInterests = 20;
    uploadCountOfInterests = 10;
    interestsIds = [NSMutableArray new];
    interestsActivityIds = [NSMutableArray new];
    interestsToSelect = [NSMutableArray new];
    
    if (self.hideBackButton) {
        self.backBtn.hidden = YES;
    }
    
}
-(void)viewDidAppear:(BOOL)animated
{
    
    // [self startUpdating];
    isSpectatorInterest = YES;
    
    editMode_checkCHoosenInterestFacebook = YES;
    editMode_checkCHoosenInterestPreloaded = YES;
    editMode_checkCHoosenInterestOwn = YES;
    editMode_checkCHoosenInterestPublic = YES;
    [super viewDidAppear:YES];
    [self setUpInterests];
    [self setUI];
    
//  [self messagePopupWithTitle:@"We've discovered that your interests in a few things that we've found in your facebook. Are other things that you find more interesting, tell us more. You also could create new interest, if you couldn't find an existing interest - just click on the               icon." hideOkButton:NO];
    
}
-(void)configureInterests:(BOOL)search
{
    [self progress];
    
    [self.yourOwnInterestsArray removeAllObjects];
    [self.selectedInterests removeAllObjects];
    [self.publicInterestsArray removeAllObjects];
    [self.preloadedInterestsArray removeAllObjects];
    [self.fbInterests removeAllObjects];
    [self.fasebookInterestsArray removeAllObjects];
    
/*!
- Load interests from Server and Configure them according to type
 @types: own/facebook/preloaded/public
**/
    dispatch_async(dispatch_get_main_queue(), ^{
        
#pragma mark Конфигурируем интересы
        NSArray *tmp = [NSMutableArray arrayWithArray:search?[Server interestsSearchWithText:self.queryString]:[Server interests]];
#pragma mark Конфигурируем свои интересы
        [tmp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if([[NSString stringWithFormat:@"%@",[obj valueForKey:@"interesttype"]] intValue]==0)
                [self.yourOwnInterestsArray addObject:obj];
            if (idx == tmp.count) {
                *stop = YES;
            }
        }];
        [tmp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if([[NSString stringWithFormat:@"%@",[obj valueForKey:@"interesttype"]] intValue]==3)
            {
                
                [self.preloadedInterestsArray addObject:obj];
            }
            if (idx == tmp.count) {
                *stop = YES;
            }
        }];
        [tmp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if([[NSString stringWithFormat:@"%@",[obj valueForKey:@"public"]] intValue]==1 && [[NSString stringWithFormat:@"%@",[obj valueForKey:@"interesttype"]] intValue]!=0 && [[NSString stringWithFormat:@"%@",[obj valueForKey:@"interesttype"]] intValue]!=3)
                
                [self.publicInterestsArray addObject:obj];
            if (idx == tmp.count) {
                *stop = YES;
            }
        }];
#pragma mark Конфигурируем Фэйсбук интересы
        
        [tmp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if([[NSString stringWithFormat:@"%@",[obj valueForKey:@"interesttype"]] intValue]==1)
                [self.fasebookInterestsArray addObject:obj];
            if (idx == tmp.count) {
                *stop = YES;
            }
        }];

        [self.table reloadData];
        [self stopSubview];
        
    });
    
}
-(void)setUpInterests{
    
    
    self.yourOwnInterestsArray = [[NSMutableArray alloc] init];
    self.selectedInterests = [[NSMutableArray alloc] init];
    self.publicInterestsArray = [[NSMutableArray alloc] init];
    self.preloadedInterestsArray = [[NSMutableArray alloc] init];
    self.fasebookInterestsArray = [[NSMutableArray alloc] init];
    [self configureInterests:NO];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
- (void)setUI{
    self.doneBtn .layer.cornerRadius = 2;
    self.doneBtn.layer.masksToBounds = YES;
    self.nextBtn .layer.cornerRadius = 2;
    self.nextBtn.layer.masksToBounds = YES;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIImageView *sectionImage = nil;
    
    if(section == 0)
    {
        if(self.yourOwnInterestsArray.count>0)
        {
            sectionImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 8)];
            sectionImage.image = [UIImage imageNamed:@"your_interests_text"];
            sectionImage.backgroundColor = [UIColor whiteColor];
        }
        
        
    }
    if(section == 1)
    {
        
        
        if(self.fasebookInterestsArray.count>0)
        {
            sectionImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 8)];
            sectionImage.image = [UIImage imageNamed:@"fb_"];
            sectionImage.backgroundColor = [UIColor whiteColor];
        }
        
        
    }
    if(section == 3)
    {
        if(self.publicInterestsArray.count>0)
        {
            sectionImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 8)];
            sectionImage.image = [UIImage imageNamed:@"public_interests_text"];
            sectionImage.backgroundColor = [UIColor whiteColor];
        }
        
        
    }
    if(section == 2)
    {
        if(self.preloadedInterestsArray.count>0)
        {
            sectionImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 8)];
            sectionImage.image = [UIImage imageNamed:@"preloaded_interests_text"];
            sectionImage.backgroundColor = [UIColor whiteColor];
        }
        
    }
    
    return sectionImage;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if(section == 0)
    {
        if(self.yourOwnInterestsArray.count>0)
        {
            return 8;
        }
        
        
    }
    if(section == 1)
    {
        
        
        if(self.fasebookInterestsArray.count>0)
        {
            return 8;
        }
        
        
    }
    if(section == 3)
    {
        if(self.publicInterestsArray.count>0)
        {
            return 8;
        }
        
    }
    if(section == 2)
    {
        if(self.preloadedInterestsArray.count>0)
        {
            return 8;
        }
        
        
    }
    
    return 0;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 74;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==2)
    {
        return  self.preloadedInterestsArray.count;
    }
    if(section==1)
    {
        return self.fasebookInterestsArray.count;
    }
    if(section==0)
    {
        return self.yourOwnInterestsArray.count;
    }
    if(section==3)
    {
        
        return self.publicInterestsArray.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    emsInterestsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InterestCell"];
    
    if (!cell) {
        
        
        NSArray* xibCell = [[NSBundle mainBundle] loadNibNamed:@"emsInterestsCell" owner:self options:nil];
        cell = [xibCell objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if(indexPath.section == 0)
    {
        long cId = [self.yourOwnInterestsArray[indexPath.row][@"id"] integerValue];
        
            for(int i=0;i<incomeInterests.count;i++)
            {
                long iId = [incomeInterests[i] integerValue];
                NSLog(@"%ld=%ld",iId,cId);
                if(iId==cId)
                {
                    [self setSelected:self.yourOwnInterestsArray[indexPath.row] andCellBtn:cell.selectBtn];
                    
                   
                }
                
            
        }
        
        [cell.selectBtn addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
        [cell configureCellItemsWithData:[self.yourOwnInterestsArray objectAtIndex:indexPath.row]];
        cell.selectBtn.tag = cell.interestID;
    }
    if(indexPath.section == 1)
    {
        
        long cId = [self.fasebookInterestsArray[indexPath.row][@"id"] integerValue];
        
            for(int i=0;i<incomeInterests.count;i++)
            {
                long iId = [incomeInterests[i] integerValue];
                NSLog(@"%ld=%ld",iId,cId);
                if(iId==cId && cId!=0)
                {
                    [self setSelected:self.fasebookInterestsArray[indexPath.row] andCellBtn:cell.selectBtn];
                    
                    
                }
                else
                {
                    NSString *fId = [NSString stringWithFormat:@"%@",incomeInterests[i]];
                    if([[NSString stringWithFormat:@"%@",self.fasebookInterestsArray[indexPath.row][@"id"]] isEqualToString:fId])
                    {
                       [self setSelected:self.fasebookInterestsArray[indexPath.row] andCellBtn:cell.selectBtn];
                    
                    }
                    
                    
                    
                
                }
                
            }
        
        
        if(cell.interestID == 0)
        {
            cell.cellIndexPath = indexPath;
            cell.facebookID = [NSString stringWithFormat:@"%@",self.fasebookInterestsArray[indexPath.row][@"id"]];
            cell.selectBtn.tag = 0;
        }
        else
        {
          cell.selectBtn.tag = cell.interestID;
        }
        
        [cell.selectBtn addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
        [cell configureCellItemsWithData:self.fasebookInterestsArray[indexPath.row]];
    }
    if(indexPath.section==2)
    {
        long cId = [self.preloadedInterestsArray[indexPath.row][@"id"] integerValue];
        
                    
            for(int i=0;i<incomeInterests.count;i++)
            {
                long iId = [incomeInterests[i] integerValue];
                NSLog(@"%ld=%ld",iId,cId);
                if(iId==cId)
                {
                    [self setSelected:self.preloadedInterestsArray[indexPath.row] andCellBtn:cell.selectBtn];
                    
                   
                }
                
        }
       
        
        [cell.selectBtn addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
        [cell configureCellItemsWithData:[self.preloadedInterestsArray objectAtIndex:indexPath.row]];
        cell.selectBtn.tag = cell.interestID;
        
    }
    if(indexPath.section == 3)
    {
        long cId = [self.publicInterestsArray[indexPath.row][@"id"] integerValue];
        
        
            for(int i=0;i<incomeInterests.count;i++)
            {
                long iId = [incomeInterests[i] integerValue];
                NSLog(@"%ld=%ld",iId,cId);
                if(iId==cId)
                {
                    [self setSelected:self.publicInterestsArray[indexPath.row] andCellBtn:cell.selectBtn];
                    
                    
                }
                
            
            }
        
        [cell configureCellItemsWithData:[self.publicInterestsArray objectAtIndex:indexPath.row]];
        [cell.selectBtn addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
        cell.selectBtn.tag = cell.interestID;
    }
   
    
    return cell;
    
    
}
-(IBAction)unckeckDefaultInterest
{
    
    defaultInterestUnchecked = YES;
    [[ABStoreManager sharedManager] removeActivityInterest:aiToRemove];
    [[ABStoreManager sharedManager] saveInterest];
    
}
-(void)setSelected:(NSDictionary*)data andCellBtn:(UIButton*)btn
{
    [btn setImage:[UIImage imageNamed:@"chek_interests"] forState:UIControlStateNormal];
    
}
# pragma  Select Interests

-(IBAction) showMoreAction:(UIButton*)sender{
    
    
    
    totalNumberOfInterests = totalNumberOfInterests + uploadCountOfInterests ;
    
    NSArray *tmp =  [Server publicInterests:[NSString stringWithFormat: @"%ld",totalNumberOfInterests]
                                   andLimit:[NSString stringWithFormat: @"%ld",uploadCountOfInterests]];
    
    if ([tmp count]) {
        
        for (NSDictionary *dic in tmp) {
            
            [self.publicInterestsArray addObject:dic];
        }
        
    }else{
        
        hideLoadMoreButton = YES;
    }
    
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionPush;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.fillMode = kCAFillModeForwards;
    transition.duration = 0.7;
    transition.subtype = kCATransitionFade;
    [[self.table layer] addAnimation:transition forKey:@"UITableViewReloadDataAnimationKey"];
    [self.table reloadData];
}

-(IBAction)selectButton:(UIButton*)sender{
    
    
    if ([sender.imageView.image isEqual:[UIImage imageNamed:@"chek_interests"]])
    {
        
        [sender setImage:[UIImage imageNamed:@"non_check"] forState:UIControlStateNormal];
        
        for(int i=0;i<incomeInterests.count;i++)
        {
            if(sender.tag==0)
            {
               
                CGPoint buttonOriginInTableView = [sender convertPoint:CGPointZero toView:self.table];
                NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:buttonOriginInTableView];
                emsInterestsCell *cell = [self.table cellForRowAtIndexPath:indexPath];
                if([[NSString stringWithFormat:@"%@",incomeInterests[i]] isEqualToString:cell.facebookID])
                {
                    [[ABStoreManager sharedManager] removeInterest:incomeInterests[i]];
                    [[ABStoreManager sharedManager] saveInterest];
                    [incomeInterests removeObjectAtIndex:i];
                    
                }
                
            }
            else
            {
                if([[NSString stringWithFormat:@"%@",incomeInterests[i]] isEqualToString:[NSString stringWithFormat:@"%ld",(long)sender.tag]])
                {
                   
                        [[ABStoreManager sharedManager] removeInterest:incomeInterests[i]];
                        [incomeInterests removeObjectAtIndex:i];
                    
                }
            }
        }
        
        
        
        
        
    }else if ([sender.imageView.image isEqual:[UIImage imageNamed:@"non_check"]])
    {
        [sender setImage:[UIImage imageNamed:@"chek_interests"] forState:UIControlStateNormal];
        if(sender.tag==0)
        {
        
            CGPoint buttonOriginInTableView = [sender convertPoint:CGPointZero toView:self.table];
            NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:buttonOriginInTableView];
            emsInterestsCell *cell = [self.table cellForRowAtIndexPath:indexPath];
            [incomeInterests addObject:[NSString stringWithFormat:@"%@",cell.facebookID]];
            [[ABStoreManager sharedManager] addInterestToArray:[NSString stringWithFormat:@"%@",cell.facebookID]];
            [[ABStoreManager sharedManager] saveInterest];
        
        }
        else
        {
            [incomeInterests addObject:[NSString stringWithFormat:@"%ld",(long)sender.tag]];
            [[ABStoreManager sharedManager] addInterestToArray:[NSString stringWithFormat:@"%ld",(long)sender.tag]];
            [[ABStoreManager sharedManager] saveInterest];
        }
        
    }
    
    [self.table reloadData];
    
}
-(IBAction)back{
    
    for(int i=0;i<incomeInterests.count;i++)
    {
        
        
        [[ABStoreManager sharedManager] removeInterest:incomeInterests[i]];
        
        
    }
    [[ABStoreManager sharedManager] addInterestToArray:incomeInterests];
    [[ABStoreManager sharedManager] saveInterest];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ActivityBuilder_4" bundle:nil];
    SCLocationViewController *notebook = [storyboard instantiateViewControllerWithIdentifier:@"SCLocationViewController"];
    [self presentViewController:notebook animated:YES completion:^{
        
    }];
    
    
    
}

-(void)startThread
{
    
    
    [NSThread detachNewThreadSelector:@selector(startUpdating) toTarget:self withObject:nil];
    
    
}
/*!
 @discussion Go And Create New Interest
 **/
-(IBAction)addInterest
{
    [popup removeFromSuperview];
    if(self.yourOwnInterestsArray.count<10)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[emsDeviceManager isIphone6plus]?@"CreateInterest_6plus":@"CreateInterest_6plus" bundle:nil];
        CreateInterestViewController *notebook = [storyboard instantiateViewControllerWithIdentifier:@"CreateInterestViewController"];
        [self presentViewController:notebook animated:YES completion:^{
            
        }];
    }
    else
    {
        [self messagePopupWithTitle:@"You are not allowed to add more than 10 interests!" hideOkButton:NO];
        
        
    }
    
}
/*!
 @discussion Saves selected interests and move go
 FriendsViewController
 **/
-(IBAction)goToFriends
{
    for(int i=0;i<incomeInterests.count;i++)
    {
        
            
            [[ABStoreManager sharedManager] removeInterest:incomeInterests[i]];
        
        
    }
    [[ABStoreManager sharedManager] addInterestToArray:incomeInterests];
    [[ABStoreManager sharedManager] saveInterest];
    
    if([[[ABStoreManager sharedManager] editingActivityData][vInterests] count]>0 || [[[ABStoreManager sharedManager] ongoingActivity][vInterests] count])
    {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ActivityBuilder_4" bundle:nil];
        FriendsViewController *notebook = [storyboard instantiateViewControllerWithIdentifier:@"Friends"];
        [self presentViewController:notebook animated:YES completion:^{
            
        }];
    }else{
        
        popup = [[ScadaddlePopup alloc] initWithFrame:self.view.frame withTitle:@"Please, select at least one interest!" withProgress:NO andButtonsYesNo:NO forTarget:self andMessageType:-1];
        [popup hideDisplayButton:NO];
        [self.view addSubview:popup];
        
    }
    
    
}
-(IBAction)dismissPopup
{
    
    [popup removeFromSuperview];
    
}
-(void)startUpdating
{
    // [self progress];
    //    popup = [[ScadaddlePopup alloc] initWithFrame:self.view.frame withTitle:@"Loading..." withProgress:YES andButtonsYesNo:NO forTarget:self andMessageType:-1];
    //    [self.view addSubview:popup];
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
    
    //[popup updateTitleWithInfo:title];
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
-(IBAction)backToEditProfile
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[ABStoreManager sharedManager] flushData];
        [[ABStoreManager sharedManager] setModeEditing:NO];
    }];
}


-(void)updationLocationThread
{
    
    popup = [[ScadaddlePopup alloc] initWithFrame:self.view.frame withTitle:@"Loading location..." withProgress:YES andButtonsYesNo:NO forTarget:self andMessageType:-1];
    [self.view addSubview:popup];
    
}
-(void)startUpdatingLocation
{
    [NSThread detachNewThreadSelector:@selector(updationLocationThread) toTarget:self withObject:nil];
    
}

-(void)dismissPopupAction
{
    [popup removeFromSuperview];
    
}

#pragma mark New Search functions
-(IBAction)searchAction{
    
    [self.searchField resignFirstResponder];
    [self handleSearch:self.searchField];
    //self.searchField.text = @"";
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self handleSearch:textField];
    
    [textField resignFirstResponder];
    
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{}
-(void)textFieldDidBeginEditing:(UITextField *)textField{}
-(IBAction)showSearchBar
{
    if (self.isShowSearch == NO) {
        
        self.isShowSearch = YES;
        self.viewWhithTextField.frame = CGRectMake( self.viewWhithTextField.frame.origin.x + 320,  self.viewWhithTextField.frame.origin.y ,  self.viewWhithTextField.frame.size.width,  self.viewWhithTextField.frame.size.height);
        [UIView animateWithDuration:.3 animations:^{
            self.table.frame = CGRectMake( self.table.frame.origin.x,  self.table.frame.origin.y + 52,  self.table.frame.size.width,  self.table.frame.size.height);
            self.viewWhithTextField.frame = CGRectMake( self.viewWhithTextField.frame.origin.x-320,  self.viewWhithTextField.frame.origin.y ,  self.viewWhithTextField.frame.size.width,  self.viewWhithTextField.frame.size.height);
        }];
    }
}

-(void)cancelSearchAction
{
    self.isShowSearch = NO;
    self.searchField.text = @"";
    [self.searchField resignFirstResponder];
    [UIView animateWithDuration:.3 animations:^{
        
        self.table.frame = CGRectMake( self.table.frame.origin.x,  self.table.frame.origin.y - 52,  self.table.frame.size.width,  self.table.frame.size.height);
        
    }];
}


@end
