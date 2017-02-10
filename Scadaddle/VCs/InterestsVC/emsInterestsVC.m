//
//  emsInterestsVC.m
//  Scadaddle
//
//  Created by developer on 30/03/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsInterestsVC.h"
#import "emsInterestsCell.h"
#import "emsAPIHelper.h"
#import "CreateInterestViewController.h"
#import "ABStoreManager.h"
#import "emsScadProgress.h"
#import "emsRegistrationVC.h"
#import "emsMainScreenVC.h"
#import "UserDataManager.h"
@interface emsInterestsVC ()<UITableViewDelegate,UITableViewDataSource>{
    
    
    BOOL hideLoadMoreButton ;
    emsScadProgress * subView;
    NSMutableArray *spectatorSelectedInterests;
    NSMutableArray *activitySelectedInterests;
    
}
@property (nonatomic, weak) IBOutlet UILabel *editProfileLabel;
@property (nonatomic, weak) IBOutlet UIButton *doneBtn;
@end

@implementation emsInterestsVC

@synthesize queryString;


-(void)viewWillAppear:(BOOL)animated{
    
}
-(void)progressThread
{

    

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
-(void)flurrySessionDidCreateWithInfo:(NSDictionary *)info
{
    
    
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self progress];
    spectatorSelectedInterests = [NSMutableArray new];
    activitySelectedInterests = [NSMutableArray new];
    ////[Flurry setDelegate:self];
    //[Flurry logEvent:@"Interests[ViewDidLoad]"];
    self.table.delegate=self;
    

    if (self.hideBackButton) {
        self.backBtn.hidden = YES;
    }
    
    
    
}
-(void)viewDidAppear:(BOOL)animated
{
    
    // [self startUpdating];
    isSpectatorInterest = YES;
    [super viewDidAppear:YES];
    [self setUpInterests];
    [self setUI];
    
    NSArray *tmp = [[NSArray alloc] init];
    if([[[ABStoreManager sharedManager] ongoingActivity][vInterests] count]>0)
    {
        tmp = [[ABStoreManager sharedManager] ongoingActivity][vInterests];
        
    }
    
    NSArray *tmpAct = [[NSArray alloc] init];
    if([[[ABStoreManager sharedManager] ongoingActivity][@"interestActivity"] count]>0)
    {
        tmpAct = [[ABStoreManager sharedManager] ongoingActivity][@"interestActivity"];
        
    }
    
    for(int i=0;i<tmpAct.count;i++)
    {
        
        [activitySelectedInterests addObject:[tmpAct[i] isKindOfClass:[NSDictionary class]]?tmpAct[i][@"Iid"]:tmpAct[i]];
        
        
    }
    
    for(int i=0;i<tmp.count;i++)
    {
        
        [spectatorSelectedInterests addObject:[tmp[i] isKindOfClass:[NSDictionary class]]?tmp[i][@"Iid"]:tmp[i]];
        
        
    }
    
}
-(void)configureInterests:(BOOL)search
{
    [self.yourOwnInterestsArray removeAllObjects];
    [self.selectedInterests removeAllObjects];
    [self.publicInterestsArray removeAllObjects];
    [self.preloadedInterestsArray removeAllObjects];
    [self.fbInterests removeAllObjects];
    [self.fasebookInterestsArray removeAllObjects];
    
    
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
            if([[NSString stringWithFormat:@"%@",[obj valueForKey:@"public"]] intValue]==1 && [[NSString stringWithFormat:@"%@",[obj valueForKey:@"interesttype"]] intValue]!=3 && [[NSString stringWithFormat:@"%@",[obj valueForKey:@"interesttype"]] intValue]!=0)
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
        
        static dispatch_once_t task;
        dispatch_once(&task, ^{
            
            for(int i=0;i<self.preloadedInterestsArray.count;i++)
            {
                
                [spectatorSelectedInterests addObject:[NSString stringWithFormat:@"%@",self.preloadedInterestsArray[i][@"id"]]];
                [[ABStoreManager sharedManager] addInterestToArray:[NSString stringWithFormat:@"%@",self.preloadedInterestsArray[i][@"id"]]];
                [[ABStoreManager sharedManager] saveInterest];
                
                [activitySelectedInterests addObject:[NSString stringWithFormat:@"%@",self.preloadedInterestsArray[i][@"id"]]];
                [[ABStoreManager sharedManager] addActivityInterestToArray:[NSString stringWithFormat:@"%@",self.preloadedInterestsArray[i][@"id"]]];
                [[ABStoreManager sharedManager] saveActivityInterest];
                
                
                
            }
            
        });
        [self.table  reloadData];
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
    
    
    emsInterestsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    
    if (!cell) {
        
        NSArray* xibCell = [[NSBundle mainBundle] loadNibNamed:@"emsInterestsCell" owner:self options:nil];
        cell = [xibCell objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    //#error editMode_checkCHoosenInterest setTo NO after work is complete
    if(isSpectatorInterest)
    {
    if(indexPath.section == 0)
    {
        long cId = [self.yourOwnInterestsArray[indexPath.row][@"id"] integerValue];
        long ncInterestId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"newInterestId"] integerValue];
        
        if(cId == ncInterestId)
        {
            
            [spectatorSelectedInterests addObject:[NSString stringWithFormat:@"%li",ncInterestId]];
            [[ABStoreManager sharedManager] addInterestToArray:[NSString stringWithFormat:@"%li",ncInterestId]];
            [[ABStoreManager sharedManager] saveInterest];
            [self setSelected:self.yourOwnInterestsArray[indexPath.row] andCellBtn:cell.selectBtn];
            [activitySelectedInterests addObject:[NSString stringWithFormat:@"%li",ncInterestId]];
            [[ABStoreManager sharedManager] addActivityInterestToArray:[NSString stringWithFormat:@"%li",ncInterestId]];
            [[ABStoreManager sharedManager] saveActivityInterest];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"newInterestId"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
        
        for(int i=0;i<spectatorSelectedInterests.count;i++)
        {
            long iId = [spectatorSelectedInterests[i] integerValue];
            
            
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
        
        for(int i=0;i<spectatorSelectedInterests.count;i++)
        {
            long iId = [spectatorSelectedInterests[i] integerValue];
            NSLog(@"%ld=%ld",iId,cId);
            if(iId==cId && cId!=0)
            {
                [self setSelected:self.fasebookInterestsArray[indexPath.row] andCellBtn:cell.selectBtn];
                
                
            }
            else
            {
                NSString *fId = [NSString stringWithFormat:@"%@",spectatorSelectedInterests[i]];
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
        for(int i=0;i<spectatorSelectedInterests.count;i++)
        {
            long iId = [spectatorSelectedInterests[i] integerValue];
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
        
        
        for(int i=0;i<spectatorSelectedInterests.count;i++)
        {
            long iId = [spectatorSelectedInterests[i] integerValue];
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
    }
    else//Activity Interests
    {
        
        
        if(indexPath.section == 0)
        {
            long cId = [self.yourOwnInterestsArray[indexPath.row][@"id"] integerValue];
            
            
            
            for(int i=0;i<activitySelectedInterests.count;i++)
            {
                long iId = [activitySelectedInterests[i] integerValue];
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
            
            for(int i=0;i<activitySelectedInterests.count;i++)
            {
                long iId = [activitySelectedInterests[i] integerValue];
                NSLog(@"%ld=%ld",iId,cId);
                if(iId==cId && cId!=0)
                {
                    [self setSelected:self.fasebookInterestsArray[indexPath.row] andCellBtn:cell.selectBtn];
                    
                    
                }
                else
                {
                    NSString *fId = [NSString stringWithFormat:@"%@",activitySelectedInterests[i]];
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
            for(int i=0;i<activitySelectedInterests.count;i++)
            {
                long iId = [activitySelectedInterests[i] integerValue];
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
            
            
            for(int i=0;i<activitySelectedInterests.count;i++)
            {
                long iId = [activitySelectedInterests[i] integerValue];
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

    
    
    }
    
   
    
    return cell;
    
    
}
-(void)setSelected:(NSDictionary*)data andCellBtn:(UIButton*)btn
{
    
    [btn setImage:[UIImage imageNamed:@"chek_interests"] forState:UIControlStateNormal];
    
}
-(IBAction)selectButton:(UIButton*)sender{
    
    if(isSpectatorInterest)
    {
    if ([sender.imageView.image isEqual:[UIImage imageNamed:@"chek_interests"]])
    {
        
        [sender setImage:[UIImage imageNamed:@"non_check"] forState:UIControlStateNormal];
        
        for(int i=0;i<spectatorSelectedInterests.count;i++)
        {
            if(sender.tag==0)
            {
                
                CGPoint buttonOriginInTableView = [sender convertPoint:CGPointZero toView:self.table];
                NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:buttonOriginInTableView];
                emsInterestsCell *cell = [self.table cellForRowAtIndexPath:indexPath];
                if([[NSString stringWithFormat:@"%@",spectatorSelectedInterests[i]] isEqualToString:cell.facebookID])
                {
                    [[ABStoreManager sharedManager] removeInterest:spectatorSelectedInterests[i]];
                    [[ABStoreManager sharedManager] saveInterest];
                    [spectatorSelectedInterests removeObjectAtIndex:i];
                    
                }
                
            }
            else
            {
                if([[NSString stringWithFormat:@"%@",spectatorSelectedInterests[i]] isEqualToString:[NSString stringWithFormat:@"%ld",(long)sender.tag]])
                {
                    
                    [[ABStoreManager sharedManager] removeInterest:spectatorSelectedInterests[i]];
                    [spectatorSelectedInterests removeObjectAtIndex:i];
                    
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
            [spectatorSelectedInterests addObject:[NSString stringWithFormat:@"%@",cell.facebookID]];
            [[ABStoreManager sharedManager] addInterestToArray:[NSString stringWithFormat:@"%@",cell.facebookID]];
            [[ABStoreManager sharedManager] saveInterest];
            
        }
        else
        {
            [spectatorSelectedInterests addObject:[NSString stringWithFormat:@"%ld",(long)sender.tag]];
            [[ABStoreManager sharedManager] addInterestToArray:[NSString stringWithFormat:@"%ld",(long)sender.tag]];
            [[ABStoreManager sharedManager] saveInterest];
        }
        
    }
    
   }//Activity Interests
   else
   {
   
       if ([sender.imageView.image isEqual:[UIImage imageNamed:@"chek_interests"]])
       {
           
           [sender setImage:[UIImage imageNamed:@"non_check"] forState:UIControlStateNormal];
           
           for(int i=0;i<activitySelectedInterests.count;i++)
           {
               if(sender.tag==0)
               {
                   
                   CGPoint buttonOriginInTableView = [sender convertPoint:CGPointZero toView:self.table];
                   NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:buttonOriginInTableView];
                   emsInterestsCell *cell = [self.table cellForRowAtIndexPath:indexPath];
                   if([[NSString stringWithFormat:@"%@",activitySelectedInterests[i]] isEqualToString:cell.facebookID])
                   {
                       [[ABStoreManager sharedManager] removeActivityInterest:activitySelectedInterests[i]];
                       [[ABStoreManager sharedManager] saveInterest];
                       [activitySelectedInterests removeObjectAtIndex:i];
                       
                   }
                   
               }
               else
               {
                   if([[NSString stringWithFormat:@"%@",activitySelectedInterests[i]] isEqualToString:[NSString stringWithFormat:@"%ld",(long)sender.tag]])
                   {
                       
                       [[ABStoreManager sharedManager] removeActivityInterest:activitySelectedInterests[i]];
                       [activitySelectedInterests removeObjectAtIndex:i];
                       
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
               [activitySelectedInterests addObject:[NSString stringWithFormat:@"%@",cell.facebookID]];
               [[ABStoreManager sharedManager] addActivityInterestToArray:[NSString stringWithFormat:@"%@",cell.facebookID]];
               [[ABStoreManager sharedManager] saveActivityInterest];
               
           }
           else
           {
               [activitySelectedInterests addObject:[NSString stringWithFormat:@"%ld",(long)sender.tag]];
               [[ABStoreManager sharedManager] addActivityInterestToArray:[NSString stringWithFormat:@"%ld",(long)sender.tag]];
               [[ABStoreManager sharedManager] saveActivityInterest];
           }
           
       }
   
   
   }
    [self.table reloadData];
    
    
}
-(IBAction)activiteAction{
    [self.spectatorBtn setBackgroundImage:[UIImage imageNamed:@"Spectator_Interests"] forState:UIControlStateNormal];
    [self.activityBtn setBackgroundImage:[UIImage imageNamed:@"Activity_interests_hover"] forState:UIControlStateNormal];
    isSpectatorInterest = NO;
    [self.table reloadData];
}

-(IBAction)spectatorAction{
    [self.activityBtn setBackgroundImage:[UIImage imageNamed:@"Activity_interests"] forState:UIControlStateNormal];
    [self.spectatorBtn setBackgroundImage:[UIImage imageNamed:@"Spectator_Interests_hover"] forState:UIControlStateNormal];
    isSpectatorInterest = YES;
    [self.table reloadData];
  
}
-(IBAction)back{
    
    [self presentViewController:[[emsRegistrationVC alloc] init] animated:YES completion:^{
        
        
    }];
    
}

-(void)startThread
{
    
    [NSThread detachNewThreadSelector:@selector(startUpdating) toTarget:self withObject:nil];
    
}
-(IBAction)profileAction{
    
    
    if(([[[ABStoreManager sharedManager] ongoingActivity][vInterests] count]>0 &&
        [[[ABStoreManager sharedManager] ongoingActivity][@"interestActivity"] count]>0))
    {
        
        [self progressWithBlock:^{
            
            
            //[self progress];
            
            if([[[ABStoreManager sharedManager] ongoingActivity][vInterests] count]>0)
            {
                [[UserDataManager sharedManager] addUserInterests:[[ABStoreManager sharedManager] ongoingActivity][vInterests]];
            }
            
            if([[[ABStoreManager sharedManager] ongoingActivity][@"interestActivity"] count]>0)
            {
                [[UserDataManager sharedManager] addActivityInterests:[[ABStoreManager sharedManager] ongoingActivity][@"interestActivity"]];
            }
            else if([[[ABStoreManager sharedManager] ongoingActivity][@"interestActivity"] count]==0 && [[[ABStoreManager sharedManager] ongoingActivity][vInterests] count]>0)
            {
                
                [[UserDataManager sharedManager] addActivityInterests:[[ABStoreManager sharedManager] ongoingActivity][vInterests]];
                
            }
            
            [Server registerUser];
            
            [self presentViewController:[[emsMainScreenVC alloc] init] animated:YES completion:^{
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"defaultInterestSelected"];
                [[ABStoreManager sharedManager] flushData];
                
                [self stopSubview];
            }];
            
            
#pragma mark Переходим в профайл
            
            
        }];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Save Profile" message:@"Please, select at least one interest on both tabs" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
      
        return;
        
    }

    
    
    
}
-(IBAction)addInterest
{
    
    if(self.yourOwnInterestsArray.count<10)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CreateInterest_6plus" bundle:nil];
        CreateInterestViewController *notebook = [storyboard instantiateViewControllerWithIdentifier:@"CreateInterestViewController"];
        [self presentViewController:notebook animated:YES completion:^{
            
        }];
    }
    else
    {
        //[self messagePopupWithTitle:@"You are not allowed to add more than 10 interests!" hideOkButton:NO];
        
        
    }
    
}
-(void)progressWithBlock:(void (^)())callback;{
    
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


@end
