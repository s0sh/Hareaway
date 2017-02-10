//
//  FriendsViewController.m
//  Scadaddle
//
//  Created by Roman Bigun on 5/26/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "FriendsViewController.h"
#import "ABStoreManager.h"
#import "emsAPIHelper.h"

#import "ScadaddlePopup.h"
#import "emsInterestsBuilderVC.h"
#import "emsInterestsVC.h"
#import "emsScadProgress.h"

@interface FriendsViewController ()
{
    NSArray *friendsArray;
    NSMutableArray *selArray;
    BOOL isSelected;
    ScadaddlePopup *popup;
    emsScadProgress * subView;
}
@end


@implementation FriendsViewController

-(void)progress1
{
    
    subView = [[emsScadProgress alloc] initWithFrame:self.view.frame screenView:self.view andSize:CGSizeMake(320, 580)];
    [self.view addSubview:subView];
    subView.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        subView.alpha = 1;
    }];
    
}
-(void)progress{
    [NSThread detachNewThreadSelector:@selector(progress1) toTarget:self withObject:nil];
}

-(void)stopSubview{
    
    [UIView animateWithDuration:0.5 animations:^{
        subView.alpha = 0;
    } completion:^(BOOL finished) {
        [subView removeFromSuperview];
        subView = nil;
    }];
    
}
-(void)startUpdating
{
    
    popup = [[ScadaddlePopup alloc] initWithFrame:self.view.frame withTitle:@"Getting Friends..." withProgress:YES andButtonsYesNo:NO forTarget:self andMessageType:-1];
    [self.view addSubview:popup];
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
 * @param title1 desired message to display on popup
 * @param duration time while disappearing
 * @param exit YES/NO YES to dismiss this controller
 */
-(void)dismissPopupActionWithTitle:(NSString*)title1 andDuration:(double)duration andExit:(BOOL)exit
{
    
    [popup updateTitleWithInfo:title1];
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
-(IBAction)dismissPopup
{
    
    [self dismissPopupActionWithTitle:@"" andDuration:0 andExit:NO];
    
    
}

- (void)viewDidLoad {
    
    [self progress1];
    [super viewDidLoad];
    self.table.delegate = self;
    self.table.dataSource = self;
    isSelected = NO;//No one was selected

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)back
{

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ActivityBuilder_4" bundle:nil];
        emsInterestsBuilderVC *notebook = [storyboard instantiateViewControllerWithIdentifier:@"InterestsBuilderVC"];
        [self presentViewController:notebook animated:YES completion:^{
            [self dismissPopup];
        }];
        
    
}
-(void)viewDidAppear:(BOOL)animated
{

    //Get friends from the Server and fill 'friendsArray' object

    [super viewDidAppear:YES];
    friendsArray = [NSArray arrayWithArray:[Server friends]];
    [self stopSubview];
    if(friendsArray.count==0)
    {
    
        self.noFriends.alpha=1;
    
    }
    else
    {
    
        self.noFriends.alpha=0;
        selArray = [[NSMutableArray alloc] init];
        if([[ABStoreManager sharedManager] editingMode])
        {
            if([[[ABStoreManager sharedManager] editingActivityData][@"activityFriends"] count]>0)
                [selArray addObjectsFromArray:[[ABStoreManager sharedManager] editingActivityData][@"activityFriends"]];
        }
        else
        {
            if([[[ABStoreManager sharedManager] ongoingActivity][@"activityFriends"] count]>0)
                [selArray addObjectsFromArray:[[ABStoreManager sharedManager] ongoingActivity][@"activityFriends"]];
            
        }
        
        [self.table reloadData];
    }
    
    

}
#pragma mark TableView delegete methods
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return friendsArray.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendsTableViewCell"];
    
    if (!cell) {
        
        NSArray* xibCell = [[NSBundle mainBundle] loadNibNamed:@"FriendsTableViewCell" owner:self options:nil];
        cell = [xibCell objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
    }
    cell.delegate = self;
    NSLog(@"%@",friendsArray[indexPath.row][@"friend"]);
    [cell configureCellItemsUsingData:friendsArray[indexPath.row][@"friend"]];
    for(NSString * str in selArray)
    {
        
        if([[NSString stringWithFormat:@"%@",str] isEqualToString:[NSString stringWithFormat:@"%@",friendsArray[indexPath.row][@"friend"][@"id"]]])
        {
        
            [cell.selectBtn setImage:[UIImage imageNamed:@"check_btn"] forState:UIControlStateNormal];
        
        }
    }
    return cell;
    
}
#pragma cell delegate
- (void)cellController:(FriendsTableViewCell*)cellController
        didPressButton:(NSString*)action userId:(NSString *)iId
{
    
    if([action isEqualToString:@"check"])
    {
        BOOL present = NO;
        for(NSString *tmp in selArray)
        {
            if([tmp isEqualToString:iId])
                present = YES;
            
        }
        if(!present)
        {
            [[ABStoreManager sharedManager] addFriendToActivity:iId];
            [[ABStoreManager sharedManager] saveFriends];
            [selArray addObject:iId];
        }
    }
    else if([action isEqualToString:@"uncheck"])
    {
        [[ABStoreManager sharedManager]removeFriendFromActivity:iId];
        [[ABStoreManager sharedManager] saveFriends];
        [selArray removeObject:iId];
    
    }
    
}
@end
