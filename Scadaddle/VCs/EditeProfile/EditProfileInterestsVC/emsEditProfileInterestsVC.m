//
//  emsEditProfileInterestsVC.m
//  Scadaddle
//
//  Created by developer on 06/10/15.
//  Copyright © 2015 Roman Bigun. All rights reserved.
//

#import "emsEditProfileInterestsVC.h"
#import "emsScadProgress.h"
#import "emsInterestsCell.h"
#import "emsDeviceDetector.h"
#import "CreateInterestViewController.h"
#import "ScadaddlePopup.h"
#import "emsAPIHelper.h"
#import "emsDeviceDetector.h"
#import "emsDeviceManager.h"
#import "Interest.h"
#import "UserDataManager.h"
#import "ABStoreManager.h"
@interface emsEditProfileInterestsVC ()<UITableViewDelegate,UITableViewDataSource>{
    
    emsScadProgress * subView;
    ScadaddlePopup * popup;
}
// -arrays
@property(retain)NSMutableArray *interestsArray;
@property(retain)NSMutableArray *yourOwnInterestsArray;
@property(retain)NSMutableArray *fasebookInterestsArray;
@property(retain)NSMutableArray *publicInterestsArray;
@property(retain)NSMutableArray *preloadedInterestsArray;
@property(retain)NSMutableArray *selectedInterests;
@property(retain)NSMutableArray *fbInterests;
@property(retain)NSMutableArray *whatInterestsAreSelected;
@property(retain)NSMutableArray *arrayForCheckedInterests;
@property (nonatomic, weak) IBOutlet UILabel *editProfileLabel;
@property (nonatomic, weak) IBOutlet UIButton *doneBtn;
@property (nonatomic, weak)IBOutlet UITableView *table;

@end

@implementation emsEditProfileInterestsVC


/*!
 * @return selected intrests
 */

-(id)initWithData:(NSArray *)selectInterests
{
    self = [super init];
    if(self)
    {
        self.whatInterestsAreSelected = [[NSMutableArray alloc] initWithArray:selectInterests];
    }
    
    return self;
}
/*!
 * @discussion Show progress view ander superView
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
 *
 *@discussion Remove progress view from superView
 *
 */

-(void)stopSubview{
    
    [UIView animateWithDuration:0.5 animations:^{
        subView.alpha = 0;
    } completion:^(BOOL finished) {
        [subView removeFromSuperview];
        subView = nil;
    }];
}

/*!
 *
 *
 *  @discussion Sets UI elements
 *
 */

- (void)setUI{
    self.doneBtn .layer.cornerRadius = 2;
    self.doneBtn.layer.masksToBounds = YES;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self setUpInterests];
    
    self.selectedInterests =  self.whatInterestsAreSelected;
    
    [self calculateArrays];
    
    
    if (self.interestType == editSpectatorInterests) {
        
        self.editProfileLabel.text = @"Edit Spectator Interests";
    }
    
    if (self.interestType == editActivityInterests) {
        
        self.editProfileLabel.text = @"Edit Participant Interests";
    }
    
    if ([[ABStoreManager sharedManager] newAddedInrerestID]) {
        [self selectNewInteres];
    }
    
    [self.table reloadData];
    [self setUI];
    [self stopSubview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [self progress];
}

/*!
 *
 *  @discussion:Sets selected new incoming interest
 *
 */

-(void)selectNewInteres{
    
    for (Interest *interest in self.arrayForCheckedInterests) {
        
        NSInteger numSelectedId = [interest.interestID integerValue];
        NSInteger numId  = [[[ABStoreManager sharedManager] newAddedInrerestID] integerValue] ;
        if (numSelectedId ==  numId) {
            interest.selected = YES;
            [self.selectedInterests addObject:interest.interestID];
            [[ABStoreManager sharedManager] setNewAddedInrerestID:nil];
        }
        
    }
    
}

/*!
 *
 *  @discussion Sets all arrays(publicInterestsArray/preloadedInterestsArray/preloadedInterestsArray/fasebookInterestsArray)
 *
 */

-(void)selectIncominginterests{
    
    for (Interest *interest in self.arrayForCheckedInterests) {
        
        for (NSNumber *numberId in self.selectedInterests) {
            
            NSInteger numSelectedId = [interest.interestID integerValue];
            NSInteger numId  =[numberId integerValue] ;
            
            if (numSelectedId == numId) {
                interest.selected = YES;
            }
        }
    }
}

/*!
 *
 *  @discussion Sets all arrays(publicInterestsArray/preloadedInterestsArray/preloadedInterestsArray/fasebookInterestsArray)
 *
 */

-(void)calculateArrays{
    
    NSArray *tmpArray = [NSMutableArray arrayWithArray:[Server interests]];
    
    for (NSDictionary *dictionary in tmpArray) {
        
        Interest *interest = [Interest new];
        interest.fullInterestDictionary = dictionary;
        interest.interestID = [dictionary objectForKey:@"id"];
        
        
        if ([[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"interesttype"]] isEqualToString:@"0"]) {
            
            [self.yourOwnInterestsArray addObject:interest];
        }
        
        if ([[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"public"]] isEqualToString:@"1"]
            && ![[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"interesttype"]] isEqualToString:@"0"]
            && ![[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"interesttype"]]  isEqualToString:@"3"] )
        {
            [self.publicInterestsArray addObject:interest];
        }
        
        if ([[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"interesttype"]] isEqualToString:@"3"]) {
            
            [self.preloadedInterestsArray addObject:interest];
            
        }
        
        if ([[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"interesttype"]] isEqualToString:@"1"]) {
            
            [self.fasebookInterestsArray addObject:interest];
        }
        
        [self.arrayForCheckedInterests addObject:interest];
    }
    
    [self selectIncominginterests];
    
    
}
/*!
 *
 *  @discussion Sets all arrays
 *
 */


-(void)setUpInterests{
    
    self. arrayForCheckedInterests = [[NSMutableArray alloc] init];
    self.yourOwnInterestsArray = [[NSMutableArray alloc] init];
    self.selectedInterests = [[NSMutableArray alloc] init];
    self.publicInterestsArray = [[NSMutableArray alloc] init];
    self.preloadedInterestsArray = [[NSMutableArray alloc] init];
    self.fasebookInterestsArray = [[NSMutableArray alloc] init];
    [self configureInterests:NO];
    
}


/*!
 *
 *  @discussion:Method cleans all arrays
 *
 */

-(void)configureInterests:(BOOL)search
{
    [self.yourOwnInterestsArray removeAllObjects];
    [self.selectedInterests removeAllObjects];
    [self.publicInterestsArray removeAllObjects];
    [self.preloadedInterestsArray removeAllObjects];
    [self.fbInterests removeAllObjects];
    [self.fasebookInterestsArray removeAllObjects];
}

# pragma  Table view

/*!
 *
 *  @discussion Table view delegates
 *
 */


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

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    emsInterestsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    
    if (!cell) {
        
        NSArray* xibCell = [[NSBundle mainBundle] loadNibNamed:@"emsInterestsCell" owner:self options:nil];
        
        cell = [xibCell objectAtIndex:0];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.selectBtn.hidden = YES;
        
        cell.selectedImage.hidden = NO;
    }
    
    cell.selectedImage.image = [UIImage imageNamed:@"non_check"];
    
    if(indexPath.section == 0) // yourOwnInterests
    {
        Interest *interest = [self.yourOwnInterestsArray objectAtIndex:indexPath.row];
        
        if (interest.selected) {
            
            cell.selectedImage.image = [UIImage imageNamed:@"chek_interests"];
        }
        
        [cell configureCellItemsWithData:interest.fullInterestDictionary];
    }
    
    if(indexPath.section == 1) // fasebookInterests
    {
        Interest *interest = [self.fasebookInterestsArray objectAtIndex:indexPath.row];
        
        if (interest.selected) {
            
            cell.selectedImage.image = [UIImage imageNamed:@"chek_interests"];
        }
        
        [cell configureCellItemsWithData:interest.fullInterestDictionary];
    }
    
    if(indexPath.section == 2)//preloadedInterests
    {
        Interest *interest = [self.preloadedInterestsArray objectAtIndex:indexPath.row];
        
        if (interest.selected) {
            
            cell.selectedImage.image = [UIImage imageNamed:@"chek_interests"];
        }
        
        [cell configureCellItemsWithData:interest.fullInterestDictionary];
        
    }
    
    if(indexPath.section == 3) // publicInterests
    {
        Interest *interest = [self.publicInterestsArray objectAtIndex:indexPath.row];
        
        if (interest.selected) {
            
            cell.selectedImage.image = [UIImage imageNamed:@"chek_interests"];
        }
        
        
        [cell configureCellItemsWithData:interest.fullInterestDictionary];
    }
    
    return cell;
}




-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    Interest *interest;
    
    if(indexPath.section == 0) // yourOwnInterests
    {
        interest = [self.yourOwnInterestsArray objectAtIndex:indexPath.row];
        
        [self selectInterest:interest];
        
    }
    
    if(indexPath.section == 1) // fasebookInterests
    {
        Interest *interest = [self.fasebookInterestsArray objectAtIndex:indexPath.row];
        
        [self selectInterest:interest];
    }
    
    if(indexPath.section == 2)//preloadedInterests
    {
        Interest *interest = [self.preloadedInterestsArray objectAtIndex:indexPath.row];
        
        [self selectInterest:interest];
    }
    
    if(indexPath.section == 3) // publicInterests
    {
        Interest *interest = [self.publicInterestsArray objectAtIndex:indexPath.row];
        
        [self selectInterest:interest];
    }
    
    
    
}


/*!
 *
 *  @discussion Method sets selected / unselected interest by click
 *
 */


-(void)selectInterest:(Interest *)selectadInterest {
    
    Interest *interest = selectadInterest;
    
    interest.selected =  !interest.selected;
    
    if ( interest.selected ) {
        
        [self.selectedInterests addObject:interest.interestID];
        
    }else{
        
        if([self.selectedInterests indexOfObject:interest.interestID] != NSNotFound) // бережем ноги
            
            [self.selectedInterests removeObject:interest.interestID];
    }
    
    [self.table reloadData];
    
}
/*!
 *  @discussion Method dismisses self
 *
 */

-(IBAction)back{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

/*!
 *  @discussion Method  presents  CreateInterestViewController
 *
 */

-(IBAction)addInterest
{
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
 *  @discussion Sets Popup Custom Progress bar with blured background and Scadaddle
*/
-(void)messagePopupWithTitle:(NSString*)title hideOkButton:(BOOL)show
{
    
    popup = [[ScadaddlePopup alloc] initWithFrame:self.view.frame withTitle:title withProgress:NO andButtonsYesNo:NO forTarget:self andMessageType:-1];
    [popup hideDisplayButton:show];
    [self.view addSubview:popup];
    
}

-(void)dismissPopupActionWithTitle:(NSString*)title andDuration:(double)duration andExit:(BOOL)exit
{
    
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
/*!
 *  @discussion Method collects selected interests and send to server
*/

-(IBAction)collectInterests{
    
    NSMutableDictionary *dic  =[[NSMutableDictionary alloc] init];
    
    if (_interestType == editSpectatorInterests) {
        [dic setObject: self.selectedInterests forKey:@"userInterests"];
        [dic setObject:[[UserDataManager sharedManager] serverToken] forKey:@"restToken"];
        if ([[dic objectForKey:@"userInterests"] count] == 0) {
            
            popup = [[ScadaddlePopup alloc] initWithFrame:self.view.frame withTitle:@"Please, select at least one interest " withProgress:NO andButtonsYesNo:YES forTarget:self andMessageType:-1];
            [popup hideDisplayButton:NO];
            [self.view addSubview:popup];
            
            return;
        }
    }
    
    if (_interestType == editActivityInterests) {
        [dic setObject:self.selectedInterests forKey:@"activityInterests"];
        [dic setObject:[[UserDataManager sharedManager] serverToken] forKey:@"restToken"];
        
        if ([[dic objectForKey:@"activityInterests"] count] == 0) {
            popup = [[ScadaddlePopup alloc] initWithFrame:self.view.frame withTitle:@"Please, select at least one interest" withProgress:NO andButtonsYesNo:YES forTarget:self andMessageType:-1];
            [self.view addSubview:popup];
            
            return;
            
        }
    }
    [Server postProfileInfoandUserID:dic callback:^(NSDictionary *dictionary) {
        
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
        
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
