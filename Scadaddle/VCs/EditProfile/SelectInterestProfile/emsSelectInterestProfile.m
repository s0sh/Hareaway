//
//  emsSelectInterestProfile.m
//  Scadaddle
//
//  Created by developer on 26/05/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsSelectInterestProfile.h"
#import "emsInterestsVC.h"
#import "emsInterestsCell.h"
#import "Interest.h"
#import "emsProfileVC.h"
#import "emsDeviceDetector.h"
#import "Constants.h"
//#import "emsEditImageVC.h"


@interface emsSelectInterestProfile ()<UITableViewDelegate,UITableViewDataSource>{
    
IBOutlet UITableView *table;
    
}

@property (nonatomic, weak) IBOutlet UIButton *nextBtn;
@property (nonatomic, weak) IBOutlet UIButton *spectatorBtn;
@property (nonatomic, weak) IBOutlet UIButton *activityBtn;
@property(retain)NSMutableArray *interestsArray;
@property(retain)NSMutableArray *yourOwnInterestsArray;
@property(retain)NSMutableArray *fasebookInterestsArray;
@property(retain)NSMutableArray *publicInterestsArray;
@property(retain)NSMutableArray *preloadedInterestsArray;

@end


@implementation emsSelectInterestProfile

-(void)viewDidDisappear:(BOOL)animated{
    
//    for (UIView *view in self.view.subviews) {// временный dealloc
//        [view removeFromSuperview];
//        
//    }
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
    [self setUpInterests];
}


-(void)setUpInterests{
    self.yourOwnInterestsArray = [[NSMutableArray alloc] init];
    self.fasebookInterestsArray = [[NSMutableArray alloc] init];
    self.publicInterestsArray = [[NSMutableArray alloc] init];
    self.preloadedInterestsArray = [[NSMutableArray alloc] init];
    self.interestsArray = [[NSMutableArray alloc] init];
    
    for (int i = 0;i<20;i++) {
        
        Interest *interest = [Interest new];
        interest.interestTitle = @"test1";
        interest.interestType = yourOwnInterests;
        interest.interestImage = [UIImage imageNamed:@"seawalking_interests"];
        
        [self.yourOwnInterestsArray addObject:interest];
    }
    
    for (int i = 0;i<20;i++) {
        
        Interest *interest = [Interest new];
        interest.interestTitle = @"test1";
        interest.interestType = yourOwnInterests;
        interest.interestImage = [UIImage imageNamed:@"holesale_event_interests"];
        
        [self.fasebookInterestsArray addObject:interest];
    }
    
    for (int i = 0;i<20;i++) {
        
        Interest *interest = [Interest new];
        interest.interestTitle = @"test1";
        interest.interestType = yourOwnInterests;
        interest.interestImage = [UIImage imageNamed:@"alpinizm_interests"];
        
        [self.publicInterestsArray addObject:interest];
    }
    
    for (int i = 0;i<20;i++) {
        
        Interest *interest = [Interest new];
        interest.interestTitle = @"test1";
        interest.interestType = yourOwnInterests;
        interest.interestImage = [UIImage imageNamed:@"surfing_interests"];
        
        [self.preloadedInterestsArray addObject:interest];
    }
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)setUI{
    
    self.nextBtn .layer.cornerRadius = 2;
    self.nextBtn.layer.masksToBounds = YES;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIImageView *sectionImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 8)];
    if(section == 0) sectionImage.image = [UIImage imageNamed:@"your_interests_text"];
    if(section == 1) sectionImage.image = [UIImage imageNamed:@"fb_"];
    if(section == 2 )sectionImage.image = [UIImage imageNamed:@"preloaded_interests_text"];
    if(section == 3) sectionImage.image = [UIImage imageNamed:@"public_interests_text"];
    return sectionImage;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 8;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0) return [self.yourOwnInterestsArray count];
    if(section == 1) return [self.fasebookInterestsArray count];
    if(section == 2 ) return [self.preloadedInterestsArray count];
    if(section == 3)  return [self.publicInterestsArray count]+1;// last button
    else return  0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    emsInterestsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    
    if (!cell) {
        
        NSArray* xibCell = [[NSBundle mainBundle] loadNibNamed:@"emsInterestsCell" owner:self options:nil];
        
        cell = [xibCell objectAtIndex:0];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    Interest *interest ;
    
    if(indexPath.section == 0){
        
        interest = [self.yourOwnInterestsArray objectAtIndex:indexPath.row];
        
        cell.avatarImage.image =interest.interestImage;
        
        if (interest.selected) {
            [cell.selectBtn setImage:[UIImage imageNamed:@"chek_interests"] forState:UIControlStateNormal];
        }else{
            [cell.selectBtn setImage:[UIImage imageNamed:@"non_chek_interests"] forState:UIControlStateNormal];
        }
        cell.selectBtn.tag = indexPath.row;
        
        [cell.selectBtn addTarget:self action:@selector(yourOwnInterestSelect:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    if(indexPath.section == 1){
        
        interest = [self.fasebookInterestsArray objectAtIndex:indexPath.row];
        
        cell.avatarImage.image =interest.interestImage;
        
        if (interest.selected) {
            [cell.selectBtn setImage:[UIImage imageNamed:@"chek_interests"] forState:UIControlStateNormal];
        }else{
            [cell.selectBtn setImage:[UIImage imageNamed:@"non_chek_interests"] forState:UIControlStateNormal];
        }
        cell.selectBtn.tag = indexPath.row;
        
        [cell.selectBtn addTarget:self action:@selector(fasebookInterestsSelect:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    if(indexPath.section == 2) {
        
        interest = [self.preloadedInterestsArray objectAtIndex:indexPath.row];
        
        cell.avatarImage.image =interest.interestImage;
        
        if (interest.selected) {
            [cell.selectBtn setImage:[UIImage imageNamed:@"chek_interests"] forState:UIControlStateNormal];
        }else{
            [cell.selectBtn setImage:[UIImage imageNamed:@"non_chek_interests"] forState:UIControlStateNormal];
        }
        
        cell.selectBtn.tag = indexPath.row;
        
        [cell.selectBtn addTarget:self action:@selector(preloadedInterestsSelect:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    if(indexPath.section == 3 ){
        if (indexPath.row == [self.publicInterestsArray count]) {
            
            NSArray* xibCell = [[NSBundle mainBundle] loadNibNamed:@"emsInterestsCell" owner:self options:nil];
            
            cell = [xibCell objectAtIndex:1];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [cell.showMoreBtn addTarget:self action:@selector(showMoreAction:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            
            interest = [self.publicInterestsArray objectAtIndex:indexPath.row];
            
            cell.avatarImage.image =interest.interestImage;
            
            if (interest.selected) {
                [cell.selectBtn setImage:[UIImage imageNamed:@"chek_interests"] forState:UIControlStateNormal];
            }else{
                [cell.selectBtn setImage:[UIImage imageNamed:@"non_chek_interests"] forState:UIControlStateNormal];
            }
            cell.selectBtn.tag = indexPath.row;
            
            [cell.selectBtn addTarget:self action:@selector(publicInterestsArraySelect:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    [self cornerIm:cell.avatarImage];
    
    return cell;
}





# pragma  Select Interests

-(IBAction) showMoreAction:(UIButton*)sender{
    
    for (int i = 0;i<=10;i++) {
        Interest *interest = [Interest new];
        
        interest.interestTitle = @"test4";
        interest.interestType = preloadedInterests;
        interest.interestImage = [UIImage imageNamed:@"surfing_interests"];
        [self.preloadedInterestsArray addObject:interest];
    }
    
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionPush;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.fillMode = kCAFillModeForwards;
    transition.duration = 0.7;
    transition.subtype = kCATransitionFade;
    [[table layer] addAnimation:transition forKey:@"UITableViewReloadDataAnimationKey"];
    [table reloadData];
    
}

-(IBAction) yourOwnInterestSelect:(UIButton*)sender{
    
    Interest *interest =[self.yourOwnInterestsArray objectAtIndex:sender.tag];
    
    if ([sender.imageView.image isEqual:[UIImage imageNamed:@"chek_interests"]]) {
        
        [sender setImage:[UIImage imageNamed:@"non_chek_interests"] forState:UIControlStateNormal];
        
        [self.interestsArray removeObject:interest];
        
        interest.selected = NO;
        
        return;
        
    } if ([sender.imageView.image isEqual:[UIImage imageNamed:@"non_chek_interests"]]) {
        
        [sender setImage:[UIImage imageNamed:@"chek_interests"] forState:UIControlStateNormal];
        
        [self.interestsArray addObject:interest];
        
        interest.selected = YES;
        
        return;
    }
}


-(IBAction) fasebookInterestsSelect:(UIButton*)sender{
    
    Interest *interest =[self.fasebookInterestsArray objectAtIndex:sender.tag];
    
    if ([sender.imageView.image isEqual:[UIImage imageNamed:@"chek_interests"]]) {
        
        [sender setImage:[UIImage imageNamed:@"non_chek_interests"] forState:UIControlStateNormal];
        
        [self.interestsArray removeObject:interest];
        
        interest.selected = NO;
        
        return;
        
    } if ([sender.imageView.image isEqual:[UIImage imageNamed:@"non_chek_interests"]]) {
        
        [sender setImage:[UIImage imageNamed:@"chek_interests"] forState:UIControlStateNormal];
        
        [self.interestsArray addObject:interest];
        
        interest.selected = YES;
        
        return;
    }
    
}


-(IBAction) preloadedInterestsSelect:(UIButton*)sender{
    
    Interest *interest =[self.preloadedInterestsArray objectAtIndex:sender.tag];
    
    if ([sender.imageView.image isEqual:[UIImage imageNamed:@"chek_interests"]]) {
        
        [sender setImage:[UIImage imageNamed:@"non_chek_interests"] forState:UIControlStateNormal];
        
        [self.interestsArray removeObject:interest];
        
        interest.selected = NO;
        
        return;
        
    } if ([sender.imageView.image isEqual:[UIImage imageNamed:@"non_chek_interests"]]) {
        
        [sender setImage:[UIImage imageNamed:@"chek_interests"] forState:UIControlStateNormal];
        
        [self.interestsArray addObject:interest];
        
        interest.selected = YES;
        
        return;
    }
    
}

-(IBAction) publicInterestsArraySelect:(UIButton*)sender{
    
    Interest *interest =[self.publicInterestsArray objectAtIndex:sender.tag];
    
    if ([sender.imageView.image isEqual:[UIImage imageNamed:@"chek_interests"]]) {
        
        [sender setImage:[UIImage imageNamed:@"non_chek_interests"] forState:UIControlStateNormal];
        
        [self.interestsArray removeObject:interest];
        
        interest.selected = NO;
        
        return;
    } if ([sender.imageView.image isEqual:[UIImage imageNamed:@"non_chek_interests"]]) {
        
        [sender setImage:[UIImage imageNamed:@"chek_interests"] forState:UIControlStateNormal];
        
        [self.interestsArray addObject:interest];
        
        interest.selected = YES;
        
        return;
    }
}



-(IBAction)back{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void)cornerIm:(UIImageView*)imageView{
    imageView .layer.cornerRadius = imageView.frame.size.height/2;
    imageView.layer.masksToBounds = YES;
}







-(IBAction)editImageVCAction{
    
   
}

@end
