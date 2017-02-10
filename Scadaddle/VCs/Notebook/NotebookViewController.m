//
//  NotebookViewController.m
//  Notebook
//
//  Created by Roman Bigun on 5/18/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsGlobalLocationServer.h"
#import "NotebookViewController.h"
#import "emsAPIHelper.h"
#import "emsRightMenuVC.h"
#import "emsLeftMenuVC.h"
#import "ScadaddlePopup.h"
#import "emsProfileVC.h"
#import "emsChatVC.h"
#import "emsScadProgress.h"
#import "FBHelper.h"
//#import "emsLoginVC.h"
#import "FBWebLoginViewController.h"

#define kDurationLongTime 1
@interface NotebookViewController ()
{

    NSMutableArray * dataArray;
    NSMutableArray * buttonsArray;
    NSArray *blockedArray;
  __block NSMutableArray * dataArrayByFilter;
    ScadaddlePopup *popup;
    int scrollViewContentOffsetY;
    int currentStartIndex;
    BOOL isFooterSettled;
    emsScadProgress * subView;
    BOOL isShowSearch;
}
@property(nonatomic,retain)IBOutlet UITableView *itemsTable;
@property(nonatomic,weak)IBOutlet UIView *viewWhithTableView;
@property(nonatomic,weak)IBOutlet UIView *viewWhithTextField;
@property(nonatomic,weak)IBOutlet UIButton *cancelBtn;
@property(nonatomic,weak)IBOutlet UITextField *searchField;
@property(nonatomic,weak)IBOutlet UIButton * searchButton;
@property(nonatomic) BOOL isShowSearch;
@end

@implementation NotebookViewController

@synthesize activityHeader = _activityHeader;
@synthesize activityFooter = _activityFooter;

#define FOOTERFRAME CGRectMake(81.0f, table.contentSize.height-50, 157.0f, 157.0f)
#define HEADERFRAME CGRectMake(81.0f, -102.0f, 157.0f, 157.0f);

@synthesize queryString;

-(void)viewWillAppear:(BOOL)animated{
    
    [self progress];
}
-(void)startProgress
{
    subView = [[emsScadProgress alloc] initWithFrame:self.view.frame screenView:self.view andSize:CGSizeMake(320, 580)];
    [self.view addSubview:subView];
    
    subView.alpha = 0;
    [UIView animateWithDuration:0.1 animations:^{
        subView.alpha = 1;
    }];

}
-(void)progress{//used in threads

    [self startProgress];
}

-(void)stopSubview{
    
    [UIView animateWithDuration:0.5 animations:^{
        subView.alpha = 0;
    } completion:^(BOOL finished) {
        [subView removeFromSuperview];
        subView=nil;
    }];
}
- (void)handleSearch:(UITextField *)searchBar {
    
    NSLog(@"User searched for %@", searchBar.text);
    self.queryString = searchBar.text;
    [searchBar resignFirstResponder];
    [self configureDatasourceAccordingToSearchRequest:YES];
    
    
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    NSLog(@"User canceled search");
    [searchBar resignFirstResponder];
    [self configureDatasourceAccordingToSearchRequest:NO];
    
}
/*!
 @discussion  Search for Users inside the Notebook 
 @param 'restore' uses for search YES->search NO->void search string
 @res reload table
 */
-(void)configureDatasourceAccordingToSearchRequest:(BOOL)restore
{
    if(restore){
        [params setObject:self.queryString forKey:@"text"];
    }
    else
    {
        [params removeObjectForKey:@"text"];
        
    }
    [self progress];
    [params setObject:kRequestNotebookMainPage forKey:@"target"];
    NSArray *dataArrayN = [[NSArray alloc] initWithArray:[Server notebookMainPage:params][@"users"]];
    if(dataArrayN.count>0)
    {
        [dataArray removeAllObjects];
        [dataArray addObjectsFromArray:dataArrayN];
        self.queryString = @"";
        [params removeObjectForKey:@"text"];
        [self.itemsTable reloadData];
    }
    
    [self stopSubview];
}
#pragma mark-
#pragma mark header/footer indicators
/*!
 * @discussion  PushUp/PullDown actions status indicators
 * Header Indicator
 */
- (emsScadaddleActivityIndicator *)activityHeader
{
    if (!_activityHeader) {
        _activityHeader = [[emsScadaddleActivityIndicator alloc] initWithActivityIndicatorStyle:FishActivityIndicatorViewStyleNormal];
        _activityHeader.hidesWhenStopped = NO;
    }
    return _activityHeader;
}
/*!
 * @discussion  Footer Indicator
 */
- (emsScadaddleActivityIndicator *)activityFooter
{
    if (!_activityFooter) {
        _activityFooter = [[emsScadaddleActivityIndicator alloc] initWithActivityIndicatorStyle:FishActivityIndicatorViewStyleNormal];
        _activityFooter.hidesWhenStopped = NO;
    }
    return _activityFooter;
}
/*!
 * @discussion  to animate header indicator
 */
- (void)actionHeader
{
    if (!self.activityHeader.isAnimating) {
        [self startAnimationHeader];
        [self.activityHeader startAnimating];
    }
}
/*!
 * @discussion  to animate footer indicator
 */
- (void)actionFooter
{
    if (!self.activityFooter.isAnimating) {
        [self startAnimationFooter];
        [self.activityFooter startAnimating];
    }
}
/*!
 * @discussion  start worker for actionHeader method
 */
-(void)startAnimationHeader{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.7];
    self.itemsTable.contentInset = UIEdgeInsetsMake(45, 0, 0, 0);
    [UIView commitAnimations];
    //[self performSelector:@selector(stopHeader) withObject:nil afterDelay:5];
}
/*!
 * @discussion  start worker for actionFooter method
 */
-(void)startAnimationFooter{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.itemsTable.contentInset = UIEdgeInsetsMake(0, 0, 75, 0);
    [UIView commitAnimations];
    //[self performSelector:@selector(stopFooter) withObject:nil afterDelay:5];
}
/*!
 * @discussion  stop worker for actionHeader method
 */
-(void)stopHeader{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    self.itemsTable.contentInset = UIEdgeInsetsMake(0, 0.0f, 0.0f, 0.0f);
    [UIView commitAnimations];
    [self.activityHeader stopAnimating];
    self.activityHeader.progress =0;
    [self performSelector:@selector(reloadTableView) withObject:nil afterDelay:5];
}
/*!
 * @discussion  stop worker for actionFooter method
 */
-(void)stopFooter{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    self.itemsTable.contentInset = UIEdgeInsetsMake(0, 0.0f, 0.0f, 0.0f);
    [UIView commitAnimations];
    [self.activityFooter stopAnimating];
    
}
/************************************End Activity Indicators*************************/
-(void)reloadTableView{
    [self.itemsTable reloadData];
    [self chengeFooterFrame];
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.activityFooter.frame =CGRectMake(81.0f, self.itemsTable.contentSize.height-50, 157.0f, 157.0f);
    self.activityHeader.frame = HEADERFRAME;
}
-(void)chengeFooterFrame{
    if ([dataArray count]>=4) {
        self.activityFooter.frame =CGRectMake(81.0f, (self.itemsTable.contentSize.height-50) , 157.0f, 157.0f);
    }else{
        [self.activityFooter removeFromSuperview];
        self.activityFooter = nil;
    }
    
}
-(void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    
    if (!self.activityHeader.isAnimating) {
        self.activityHeader.progress = -(scrollView.contentOffset.y /100);
    }
    
    if (!self.activityFooter.isAnimating){
        self.activityFooter.progressFooter = (scrollView.contentOffset.y /100);
    }
    
}
-(void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate{
    
    scrollViewContentOffsetY = scrollView.contentOffset.y;
    
    if (scrollView.contentOffset.y <= -75){
        [self actionHeader];
    }
    
    if (scrollView.contentOffset.y >=( self.itemsTable.contentSize.height - self.itemsTable.frame.size.height+45)){
        [self actionFooter];
    }
}
-(int)getItemsCountForStatusId:(int)statusId
{
//    __block int tmpCounter = 0;
//    
//    [dataArrayByFilter removeAllObjects];
//    [dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        if([[obj valueForKey:@"status"] intValue]==statusId)
//        {
//            tmpCounter++;
//            [dataArrayByFilter addObject:obj];
//        }
//        if (idx == dataArray.count) {
//            *stop = YES;
//        }
//    }];
//    
//    NSLog(@"Rows count = %i",tmpCounter);
//    return tmpCounter;
    
    return dataArray.count;

}
/*!
 * @discussion  check whether we should display notification badge or not
 */
-(void)showNotifications:(BOOL)show
{

    [UIView animateWithDuration:1.5f animations:^{
        
        _notificationBg.alpha = show==YES?1:0;
        _notificationLbl.alpha = show==YES?1:0;
        
    } completion:^(BOOL finished) {
        
    }];
   
}
#pragma cell delegate
/*!
 * @discussion  to handle cell buttons pressed actions
 * @see cellController:didPressButton:userId: delegate method in
 * NotebookTableViewCell class
 */
- (void)cellController:(NotebookTableViewCell*)cellController
        didPressButton:(NSString*)action userId:(NSString *)iId
{
     afterManipulation = YES;
    [self progress];
    if([action isEqualToString:@"friendshipRequest"])
    {
        
        
        [Server followUser:iId callback:^{
            [self refreshTableForStatusMode:currentStatusMode];
            [self stopSubview];
        }];
        
        
        
    }
    if([action isEqualToString:@"iceBreaker"])
    {
        
        [Server friendshipRequest:iId];
        [self refreshTableForStatusMode:currentStatusMode];
        [self stopSubview];
        
    }
    if([action isEqualToString:@"addFriend"])
    {
        
        [Server addFriend:iId status:1];
        [self refreshTableForStatusMode:currentStatusMode];
        [self stopSubview];
    }
    if([action isEqualToString:@"remove"])
    {
        
        
        [Server deleteUser:iId callback:^{
            [self refreshTableForStatusMode:currentStatusMode];
            [self stopSubview];
        }];
        
        
    }
    if([action isEqualToString:@"removeFromFriend"])
    {
        
        
        [Server addFriend:iId status:0];
        [self refreshTableForStatusMode:currentStatusMode];
        [self stopSubview];
        
        
    }
    if([action isEqualToString:@"block"])
    {
        
        [Server blockFriend:iId type:YES callback:^{
            [self refreshTableForStatusMode:currentStatusMode];
            [self stopSubview];
        }];
        
        
    }
    if([action isEqualToString:@"unblock"])
    {
        
        [Server blockFriend:iId type:NO callback:^{
            [self refreshTableForStatusMode:currentStatusMode];
            [self stopSubview];
        }];
        
        
    }
    
    if([action isEqualToString:@"chat"])
    {
        // [self messagePopupWithTitle:@"Coming soon..." hideOkButton:NO];
        
        [Server getChat:iId callback:^(NSDictionary *dictionary) {
            
            NSString *errorStr = [NSString stringWithFormat:@"%@",dictionary[@"errorCode"]];
            
            if ([errorStr isEqualToString:@"0"]) {
                
                [self presentViewController:[[emsChatVC alloc] initDictionary:dictionary] animated:YES completion:^{
                    
                    [self stopSubview];
                }];
            }
        }];
    }
    if([action isEqualToString:@"info"])
    {
        
        emsProfileVC *reg = [[emsProfileVC alloc] initWithNibName:@"emsProfileVC" bundle:nil];
        reg.profileUserId = iId;
        [self presentViewController:reg animated:YES completion:^{
            [self stopSubview];
        }];
    }
    
}
/*!
 * @discussion  to check for icebreaker notifications. get them from the server.
 *  If there are at least one displey badge with count
 */
-(void)setupNotifications
{
   
    [params setObject:kRequestNotebookIce forKey:@"target"];
    NSArray *dataArrayN = [[NSArray alloc] initWithArray:[Server notebookMainPage:params][@"users"]];
    u_long notifCount = dataArrayN.count;
    if(notifCount>0)
    {
        self.notificationLbl.text = [NSString stringWithFormat:@"%@",[Server notebookMainPage:params][@"requestCount"]];
        [self showNotifications:YES];
        
    }
    else
    {
        [self showNotifications:NO];
        
    }
    
}
/*!
 * @discussion  load more elements if needed
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(currentStatusMode == kFTAll){
        [params setObject:kRequestNotebookMainPage forKey:@"target"];
    }
    if(currentStatusMode == kFTIcebreaker){
        [params setObject:kRequestNotebookIce forKey:@"target"];
    }
    if(currentStatusMode == kFTFriends){
        [params setObject:kRequestNotebookFriends forKey:@"target"];
    }
    if(currentStatusMode == kFTFollowings){
        [params setObject:kRequestNotebookFollowings forKey:@"target"];
    }
    if(currentStatusMode == kFTBlockedUsers){
        [params setObject:kRequestNotebookBlocks forKey:@"target"];
    }
    
    if (-75 >= scrollViewContentOffsetY){
        
        currentStartIndex +=5;
        [params setObject:[NSString stringWithFormat:@"%i",0] forKey:@"limitFrom"];
        [params setObject:[NSString stringWithFormat:@"%i",currentStartIndex] forKey:@"limitTo"];
        
        NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:[Server notebookMainPage:params][@"users"]];
        if(tmp>0)
            dataArray = tmp;
        
        if(dataArray.count>0)
        {
            
            [self.itemsTable addSubview:self.activityHeader];
            if(dataArray.count>3 && !isFooterSettled)
            {
                
                [self.itemsTable addSubview:self.activityFooter];
                isFooterSettled = YES;
            }
            
        }

        
    }
    
    if (scrollView.contentOffset.y >=( self.itemsTable.contentSize.height - self.itemsTable.frame.size.height+45)){
        currentStartIndex +=5;
        [params setObject:[NSString stringWithFormat:@"%i",0] forKey:@"limitFrom"];
        [params setObject:[NSString stringWithFormat:@"%i",currentStartIndex] forKey:@"limitTo"];
        NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:[Server notebookMainPage:params][@"users"]];
        if(tmp>0)
            dataArray = tmp;
        
        if(dataArray.count>0)
        {
            
            [self.itemsTable addSubview:self.activityHeader];
            if(dataArray.count>3 && !isFooterSettled)
            {
                
                [self.itemsTable addSubview:self.activityFooter];
                isFooterSettled = YES;
            }
            
        }

    }
    
    [self stopFooter];
    [self stopHeader];
    [self.itemsTable reloadData];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setUpButtons];
    self.searchField.delegate = self;
    self.queryString = [NSString new];
    params = [NSMutableDictionary new];
    dataArrayByFilter = [[NSMutableArray alloc] init];
    currentStatusMode = kFTAll;
    self.itemsTable.delegate = self;
    self.itemsTable.dataSource = self;
    self.isShowSearch = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
}
/*!
 * @discussion  to fire progress indicator
 */
-(void)popupThread
{
    [self progress];

}
-(void)viewDidAppear:(BOOL)animated
{
 
    if (self.isShowSearch) {
        [self cancelSearchAction];
    }
    currentStartIndex = 0;
    [self setupNotifications];
    [super viewDidAppear:YES];
   
    params = [NSMutableDictionary new];
    [params setObject:self.queryString forKey:@"text"];
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"notebook"] isEqualToString:@"all"])
    {
        currentStatusMode = kFTAll;
        
        
    }
    else if([[[NSUserDefaults standardUserDefaults] objectForKey:@"notebook"] isEqualToString:@"followings"])
    {
        currentStatusMode = kFTFollowings;
        
        
    }
    else if([[[NSUserDefaults standardUserDefaults] objectForKey:@"notebook"] isEqualToString:@"ice"])
    {
        currentStatusMode = kFTIcebreaker;
        
        
    }
    else if([[[NSUserDefaults standardUserDefaults] objectForKey:@"notebook"] isEqualToString:@"friends"])
    {
        currentStatusMode = kFTFriends;
        
    }
    else if([[[NSUserDefaults standardUserDefaults] objectForKey:@"notebook"] isEqualToString:@"block"])
    {
        currentStatusMode = kFTBlockedUsers;
        
        
    }
    else
    {
    
        currentStatusMode = kFTAll;
        
        
    }
    
    [self refreshTableForStatusMode:currentStatusMode];
    
    if(dataArray.count>0)
    {
        
        [self.itemsTable addSubview:self.activityHeader];
        if(dataArray.count>3)
        {
            
            [self.itemsTable addSubview:self.activityFooter];
            isFooterSettled = YES;
        }
        
    }
    
    
    [self setupNotifications];
    
    if(dataArray.count==0)
    {
        self.noContents.alpha=1;
        [self.noContentsBG setImage:[UIImage imageNamed:@"no_connects"]];
        
    }
    else
    {
        self.noContents.alpha=0;
    }

    [self stopSubview];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachability:) name:@"EMSReachableChanged" object:nil];
}
-(void)reachability:(NSNotification *)notification
{
    
    BOOL status = notification.userInfo[@"status"];
    {
        
        if(status==YES){
            [self stopSubview];
        }else if(status == NO){
            [self progress];
        }
        
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row==dataArray.count-1)
        return 200;
    return 160;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
     return  dataArray.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NotebookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotebookTableViewCell"];
    
   if (!cell) {
        
       NSArray* xibCell = [[NSBundle mainBundle] loadNibNamed:@"NotebookTableViewCell" owner:self options:nil];
       cell = [xibCell objectAtIndex:0];
       cell.selectionStyle = UITableViewCellSelectionStyleNone;
       
    }
    NSIndexPath *p = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    [[dataArray objectAtIndex:p.row] setValue:p forKey:@"indexPath"];
    [cell configureCellItemsAccordingToType:(int)[dataArray[p.row][@"status"] intValue] usingData:dataArray[p.row]];
    cell.delegate = self;
    


    
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(IBAction)likeUserAction:(UIButton*)sender{
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
   
    if(sender.tag==0)
    {
    
        return;
    
    }
   
    [self.itemsTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]  withRowAnimation:UITableViewRowAnimationRight];
    [self.itemsTable performSelector:@selector(reloadData) withObject:nil afterDelay:0.35];
    
}
-(IBAction)delUserAction:(UIButton*)sender{

}
/*!
 * @discussion fire this method when user taps on tabs :)
 * @param mode is actually what exactly user want to see on the view e.g all/followings/friends/icebreaker/blocked
 * @result reload table with new datasource
 */
-(void)refreshTableForStatusMode:(int)mode
{
    
    currentStartIndex =0;
    [params setObject:[NSString stringWithFormat:@"%i",currentStartIndex] forKey:@"limitFrom"];
    [params setObject:[NSString stringWithFormat:@"%i",currentStartIndex+10] forKey:@"limitTo"];
    
    [dataArray removeAllObjects];
    
    if(mode == kFTAll){
        
        [self.btnFilterAll setBackgroundImage:[UIImage imageNamed:@"activity_menu_hover_main"] forState:UIControlStateNormal];
        [self.btnFilterFollowers setBackgroundImage:[UIImage imageNamed:@"following_menu_ice"] forState:UIControlStateNormal];
        [self.btnFilterFriends setBackgroundImage:[UIImage imageNamed:@"friends_menu_ice"] forState:UIControlStateNormal];
        [self.btnFilterBlocks setBackgroundImage:[UIImage imageNamed:@"block_menu_ice"] forState:UIControlStateNormal];
        [self.btnFilterIcebreaker setBackgroundImage:[UIImage imageNamed:@"ice_breacker_menu_ice"] forState:UIControlStateNormal];
        currentStatusMode = kFTAll;
        [[NSUserDefaults standardUserDefaults] setValue:@"all" forKey:@"notebook"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [params setObject:kRequestNotebookMainPage forKey:@"target"];
        dataArray = [[NSMutableArray alloc] initWithArray:[Server notebookMainPage:params][@"users"]];
        if(dataArray.count==0)
        {
           self.noContents.alpha=1;
           [self.noContentsBG setImage:[UIImage imageNamed:@"no_connects"]];
           
        
        }
        else
        {
            self.noContents.alpha=0;
            if(dataArray.count>4)
            {
                if(!isFooterSettled)
                [self.itemsTable addSubview:self.activityFooter];
                isFooterSettled=YES;
            
            }
            else
            {
                isFooterSettled=NO;
                [self.activityFooter removeFromSuperview];
            
            }
                
        }
        
    }
    else if (mode == kFTFollowings){
        
        [self.btnFilterAll setBackgroundImage:[UIImage imageNamed:@"activity_menu_main"] forState:UIControlStateNormal];
        [self.btnFilterFollowers setBackgroundImage:[UIImage imageNamed:@"following_menu_hover_ice"] forState:UIControlStateNormal];
        [self.btnFilterFriends setBackgroundImage:[UIImage imageNamed:@"friends_menu_ice"] forState:UIControlStateNormal];
        [self.btnFilterBlocks setBackgroundImage:[UIImage imageNamed:@"block_menu_ice"] forState:UIControlStateNormal];
        [self.btnFilterIcebreaker setBackgroundImage:[UIImage imageNamed:@"ice_breacker_menu_ice"] forState:UIControlStateNormal];
        currentStatusMode = kFTFollowings;
        [[NSUserDefaults standardUserDefaults] setValue:@"followings" forKey:@"notebook"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [params setObject:kRequestNotebookFollowings forKey:@"target"];
        dataArray = [[NSMutableArray alloc] initWithArray:[Server notebookMainPage:params][@"users"]];
        if(dataArray.count==0)
        {
            self.noContents.alpha=1;
            [self.noContentsBG setImage:[UIImage imageNamed:@"no_followings"]];
            
        }
        else
        {
            self.noContents.alpha=0;
            if(dataArray.count>4)
            {
                if(!isFooterSettled)
                    [self.itemsTable addSubview:self.activityFooter];
                isFooterSettled=YES;
                
            }
            else
            {
                isFooterSettled=NO;
                [self.activityFooter removeFromSuperview];
                
            }
        }
        
    }
    else if (mode == kFTIcebreaker){
        [self.btnFilterAll setBackgroundImage:[UIImage imageNamed:@"activity_menu_main"] forState:UIControlStateNormal];
        [self.btnFilterFollowers setBackgroundImage:[UIImage imageNamed:@"following_menu_ice"] forState:UIControlStateNormal];
        [self.btnFilterFriends setBackgroundImage:[UIImage imageNamed:@"friends_menu_ice"] forState:UIControlStateNormal];
        [self.btnFilterBlocks setBackgroundImage:[UIImage imageNamed:@"block_menu_ice"] forState:UIControlStateNormal];
        [self.btnFilterIcebreaker setBackgroundImage:[UIImage imageNamed:@"ice_breacker_menu_hover_ice"] forState:UIControlStateNormal];
        currentStatusMode = kFTIcebreaker;
        [[NSUserDefaults standardUserDefaults] setValue:@"ice" forKey:@"notebook"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [params setObject:kRequestNotebookIce forKey:@"target"];
        dataArray = [[NSMutableArray alloc] initWithArray:[Server notebookMainPage:params][@"users"]];
        if(dataArray.count==0)
        {
            self.noContents.alpha=1;
            [self.noContentsBG setImage:[UIImage imageNamed:@"no_ice_breakers"]];
            
        }
        else
        {
            self.noContents.alpha=0;
            if(dataArray.count>4)
            {
                if(!isFooterSettled)
                    [self.itemsTable addSubview:self.activityFooter];
                isFooterSettled=YES;
                
            }
            else
            {
                isFooterSettled=NO;
                [self.activityFooter removeFromSuperview];
                
            }
        }
        
        [self setupNotifications];
        
    }
    else if (mode == kFTFriends){
        [self.btnFilterAll setBackgroundImage:[UIImage imageNamed:@"activity_menu_main"] forState:UIControlStateNormal];
        [self.btnFilterFollowers setBackgroundImage:[UIImage imageNamed:@"following_menu_ice"] forState:UIControlStateNormal];
        [self.btnFilterFriends setBackgroundImage:[UIImage imageNamed:@"friends_menu_hover_ice"] forState:UIControlStateNormal];
        [self.btnFilterBlocks setBackgroundImage:[UIImage imageNamed:@"block_menu_ice"] forState:UIControlStateNormal];
        [self.btnFilterIcebreaker setBackgroundImage:[UIImage imageNamed:@"ice_breacker_menu_ice"] forState:UIControlStateNormal];
        currentStatusMode = kFTFriends;
        
        [[NSUserDefaults standardUserDefaults] setValue:@"friends" forKey:@"notebook"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [params setObject:kRequestNotebookFriends forKey:@"target"];
        dataArray = [[NSMutableArray alloc] initWithArray:[Server notebookMainPage:params][@"users"]];
        if(dataArray.count==0)
        {
            self.noContents.alpha=1;
            [self.noContentsBG setImage:[UIImage imageNamed:@"no_friends"]];
            
        }
        else
        {
            self.noContents.alpha=0;
            if(dataArray.count>4)
            {
                if(!isFooterSettled)
                    [self.itemsTable addSubview:self.activityFooter];
                isFooterSettled=YES;
                
            }
            else
            {
                isFooterSettled=NO;
                [self.activityFooter removeFromSuperview];
                
            }
        }
        
    }
    else if (mode == kFTBlockedUsers){
        [self.btnFilterAll setBackgroundImage:[UIImage imageNamed:@"activity_menu_main"] forState:UIControlStateNormal];
        [self.btnFilterFollowers setBackgroundImage:[UIImage imageNamed:@"following_menu_ice"] forState:UIControlStateNormal];
        [self.btnFilterFriends setBackgroundImage:[UIImage imageNamed:@"friends_menu_ice"] forState:UIControlStateNormal];
        [self.btnFilterBlocks setBackgroundImage:[UIImage imageNamed:@"block_menu_hover_ice"] forState:UIControlStateNormal];
        [self.btnFilterIcebreaker setBackgroundImage:[UIImage imageNamed:@"ice_breacker_menu_ice"] forState:UIControlStateNormal];
        currentStatusMode = kFTBlockedUsers;
        
        [[NSUserDefaults standardUserDefaults] setValue:@"block" forKey:@"notebook"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [params setObject:kRequestNotebookBlocks forKey:@"target"];
        dataArray = [[NSMutableArray alloc] initWithArray:[Server notebookMainPage:params][@"users"]];
        if(dataArray.count==0)
        {
            self.noContents.alpha=1;
            [self.noContentsBG setImage:[UIImage imageNamed:@"no_blocks"]];
            
        }
        else
        {
            self.noContents.alpha=0;
            if(dataArray.count>4)
            {
                if(!isFooterSettled)
                    [self.itemsTable addSubview:self.activityFooter];
                isFooterSettled=YES;
                
            }
            else
            {
                isFooterSettled=NO;
                [self.activityFooter removeFromSuperview];
                
            }
        }
        
    }
    self.filterType = currentStatusMode;
    [self.itemsTable reloadData];

}
/*!
 * @discussion  add buttons to array
 */
-(void)setUpButtons{
    buttonsArray = [[NSMutableArray alloc] init];
    [buttonsArray addObject:self.btnFilterAll];
    [buttonsArray addObject:self.btnFilterFollowers];
    [buttonsArray addObject:self.btnFilterIcebreaker];
    [buttonsArray addObject:self.btnFilterFriends];
    [buttonsArray addObject:self.btnFilterBlocks];
    
}

/*! Press tab
 * @discussion fire this method when user taps on tabs :)
 * @param mode is actually what exactly user want to see on the view e.g all/followings/friends/icebreaker/blocked
 * @result reload table with new datasource
 * @note each tab has its own tag which corresponds to appropriate data type
 * e.g blocked users have tag with number 3 etc
 */

-(IBAction)refreshTableForDataWithMode:(UIButton*)mode
{
   
    [self progress];//fire progress indicator
    [self refreshTableForStatusMode:mode.tag];
    [self stopSubview];//stop progress indicator
    
}

#pragma Mark rightMenuDelegate

-(void)notificationSelected:(Notification *)notification
{
    [[self.childViewControllers lastObject] willMoveToParentViewController:nil];
    [[[self.childViewControllers lastObject] view] removeFromSuperview];
    [[self.childViewControllers lastObject] removeFromParentViewController];
    
    NSLog(@"notification %lu", (unsigned long)notification);
    
}


#pragma Mark leftMenudelegate

//-(void)actionPresed:(ActionsType)actionsTypel complite:(void (^)())complite{
//    
//    NSLog(@"actionsTypel %lu", (unsigned long)actionsTypel);
//    complite();
//}

/*!
 * @discussion  Logout from Facebook/Scadaddle
 */
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
 * @discussion  open Notification menu
 */

-(IBAction)showRightMenu{
    
    emsRightMenuVC *emsRightMenu = [ [emsRightMenuVC alloc] initWithDelegate:self];
    NSLog(@"emsLeftMenu %@",emsRightMenu.delegate);
}
/*!
 * @discussion  open Main menu
 */
-(IBAction)showLeftMenu{
    
    emsLeftMenuVC *emsLeftMenu =[[emsLeftMenuVC alloc]initWithDelegate:self ];
    NSLog(@"emsLeftMenu %@",emsLeftMenu.delegate);
    
}
/*!
 * @discussion  remove all subviews
 */
-(void)clearData{
    
    for (UIView *view in self.view.subviews) {
        [view removeFromSuperview];
    }
    
}
- (void)keyboardWillShow:(NSNotification *)notification {
   // [self showSBar];
    
}
/*!
 * @discussion  tap on search button opens search bar
 */
-(IBAction)showSearchBar
{
    if (self.isShowSearch == NO) {
        
        self.isShowSearch = YES;
        self.viewWhithTextField.frame = CGRectMake( self.viewWhithTextField.frame.origin.x + 320,  self.viewWhithTextField.frame.origin.y ,  self.viewWhithTextField.frame.size.width,  self.viewWhithTextField.frame.size.height);
        [UIView animateWithDuration:.3 animations:^{
            self.itemsTable.frame = CGRectMake( self.itemsTable.frame.origin.x,  self.itemsTable.frame.origin.y + 52,  self.itemsTable.frame.size.width,  self.itemsTable.frame.size.height);
            self.viewWhithTextField.frame = CGRectMake( self.viewWhithTextField.frame.origin.x-320,  self.viewWhithTextField.frame.origin.y ,  self.viewWhithTextField.frame.size.width,  self.viewWhithTextField.frame.size.height);
        }];
    }
}
/*!
 * @discussion  'Cancel' button tapped
 */
-(void)cancelSearchAction
{
    self.isShowSearch = NO;
    self.searchField.text = @"";
    [self.searchField resignFirstResponder];
    [params removeObjectForKey:@"text"];
    [UIView animateWithDuration:.3 animations:^{
        
        self.itemsTable.frame = CGRectMake( self.itemsTable.frame.origin.x,  self.itemsTable.frame.origin.y - 52,  self.itemsTable.frame.size.width,  self.itemsTable.frame.size.height);
        
    }];
}
/*!
 * @discussion  start searching with to find substring self.searchField.text
 */
-(IBAction)cearchAction{
    [self.searchField resignFirstResponder];
    [self handleSearch:self.searchField];
    //self.searchField.text = @"";
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self handleSearch:textField];
    
    [textField resignFirstResponder];
    
    return YES;
}
/*! Quit button tapped
 * @discussion  to fire progress indicator while quitting.
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
-(void)stopSubviewForQuit{
    
    [UIView animateWithDuration:0.5 animations:^{
        subView.alpha = 0;
    } completion:^(BOOL finished) {
        [subView removeFromSuperview];
        subView = nil;
    }];
}


@end
