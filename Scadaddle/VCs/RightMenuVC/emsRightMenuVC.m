//
//  emsRightMenuVC.m
//  Scadaddle
//
//  Created by developer on 14/04/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "emsRightMenuVC.h"
#import "emsRightMenuCell.h"
#import "User.h"
#import "Notification.h"
#import "DSViewController.h"
#import "IceCreamViewController.h"
#import "emsDeviceManager.h"
#import "Constants.h"
#import "ABStoreManager.h"
#import "emsAPIHelper.h"
#import "emsProfileVC.h"
#import "NotebookViewController.h"
#import "ActivityDetailViewController.h"
#import "emsAPIHelper.h"
#import "emsChatVC.h"
@interface emsRightMenuVC ()<UITableViewDelegate,UITableViewDataSource>


@property (nonatomic, weak) IBOutlet UIButton *firstBtn;
@property (nonatomic, weak) IBOutlet UIButton *secondBtn;
@property (nonatomic, weak) IBOutlet UIButton *thirdBtn;
@property (nonatomic, weak) IBOutlet UIButton *fourthBtn;
@property (nonatomic, weak) IBOutlet UIButton *fifthBtn;
@property (nonatomic, weak) IBOutlet UILabel *notifCount;
@property (nonatomic, weak) IBOutlet UITableView *table;
@property (nonatomic, weak) IBOutlet UIImageView *bgViewR;
@property (nonatomic, retain)NSMutableArray *buttonsArray;
@property (nonatomic, retain)NSMutableArray *notificationArray;
@property (nonatomic, retain)NSMutableArray *notificationArrayPredicated;
@end

@implementation emsRightMenuVC


-(void)dealloc{
    [self.view removeFromSuperview];
    self.delegate = nil;
    NSLog(@"dealloc %@",self);
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (BOOL)tableView:(UITableView *)tableview canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    if ( indexPath.row == 0 ){
        return NO;
    }
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
/*!
 @discussion  For the case if user will be prompted to delete notification 
 item manually [Swipe left->Delete button]
 **/
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [Server removeNotification:[self.notificationArray objectAtIndex:indexPath.row][@"id"] callback:^{
        if(currentType==all){
            [self setUpArray: @"/all"];
        }else if(currentType==notebook){
            [self setUpArray: @"/notebook"];
        }else if(currentType==tv){
            [self setUpArray: @"/dreamshot"];
        }else if(currentType==s_system){
            [self setUpArray: @"/system"];
        }else if(currentType==chat){
            [self setUpArray: @"/chat"];
        }
        
    }];
    
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [self setUpArray:@"/all"];
    [self.table reloadData];
}


-(void)setUpSelf{
    
    self.view.frame = CGRectMake( self.view.frame.origin.x, self.delegate.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:0.1 animations:^{
        self.view.frame  = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.bgViewR.alpha = 1;
        }];
    }];

}
-(id)initWithDelegate:(UIViewController *)delegateVC{

    self = [super init];
    if (self) {

        self.delegate = (UIViewController<rightMenuDelegate>*)delegateVC;
        [delegateVC addChildViewController:self];
        [delegateVC.view addSubview:self.view];
        
    }
    return self;
    
}
-(UIImage*)downloadImage:(NSString *)coverUrl andImageName:(NSString*)imageName{
    __block UIImage *image = [UIImage new];
   
        NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:coverUrl]];
       image  = [UIImage imageWithData:imageData];
            if(image)
            {
                [[[ABStoreManager sharedManager] imageCache] setObject:image forKey:imageName];
                
                
            }
    
    return image;
    
}
/*!
 * @discussion  check whether image with path @param path cached or not.
 * If cached. add image to target else returns NO to start download
 */
-(UIImage*)imageHandler:(NSString*)path
{
    if(path.length>6)//  !@"(null)"
    {
        UIImage *image = [[[ABStoreManager sharedManager] imageCache] objectForKey:path];
        if(image)
        {
            
            return image;
        }
    }
    return nil;
}
/*!
 * @discussion remove all notifications from Server and reload table
 */
-(IBAction)clearAllNotifications
{
    
    
    [Server removeNotification:@"" callback:^{
    
        [self setUpArray:@"/all"];
        [self.table reloadData];
    
    }];


}
/*!
 * @discussion  creates notification objects for using it inside the table
 * @param where what exactly entity it belongs to e.g /notebook
 */
-(void)setUpArray:(NSString*)where{

    self.notificationArray = [[NSMutableArray alloc] initWithArray:[Server notifications:where]];
    self.notificationArrayPredicated  = [[NSMutableArray alloc] init];
    
    for (int i = 0; i <self.notificationArray.count; i++) {
        Notification * notification = [[Notification alloc] init];
        notification.notificationUser = [[User alloc] init];
        NSLog(@"%@",self.notificationArray[i][@"userImg"]);
        notification.notificationClass = self.notificationArray[i][@"class"];
        notification.notificationText = self.notificationArray[i][@"text"];
        notification.notificationMessageText = self.notificationArray[i][@"text"];
        if([self.notificationArray[i][@"class"] isEqualToString:@"memberUser_activity"] || [self.notificationArray[i][@"class"] isEqualToString:@"stop_memberUser_activity"] ||
           [self.notificationArray[i][@"class"] isEqualToString:@"start_follow_activity"] || [self.notificationArray[i][@"class"] isEqualToString:@"stop_follow_activity"])
        {
           notification.notificationUser.userId =[NSString stringWithFormat:@"%@",self.notificationArray[i][@"aid"]];
        }
        else
        {
           notification.notificationUser.userId =[NSString stringWithFormat:@"%@",self.notificationArray[i][@"uId"]];
        }
        
        notification.notificationUser.name = [NSString stringWithFormat:@"%@",self.notificationArray[i][@"name"]];
        notification.notificationType = [self.notificationArray[i][@"id"] integerValue];
        notification.notificationID = [NSString stringWithFormat:@"%@",self.notificationArray[i][@"id"]];
        notification.notificationDate = [NSString stringWithFormat:@"%@",self.notificationArray[i][@"created"]];
        [self.notificationArrayPredicated addObject:notification];
       
    }
    
    self.notifCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)[self.notificationArray count]];
    
   [self.table reloadData];
}

-(void)setUpButtons{
    self.buttonsArray = [[NSMutableArray alloc] init];
    [self.buttonsArray addObject:self.firstBtn ];
    [self.buttonsArray addObject:self.secondBtn];
    [self.buttonsArray addObject:self.thirdBtn ];
    [self.buttonsArray addObject:self.fourthBtn];
    [self.buttonsArray addObject:self.fifthBtn ];
}
-(IBAction)selectPredicate:(UIButton*)sender{

    for (UIButton *btn in self.buttonsArray) {
        [btn setSelected:NO];
    }
    UIButton *btn =(UIButton *)[self.buttonsArray objectAtIndex:sender.tag];
    [btn setSelected:YES];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpButtons];
//    [self setUpArray];
    [self setUpSelf];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
  
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  [self.notificationArrayPredicated count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    

    NSString *cellIdentifier = [NSString stringWithFormat:@"cell%ld",(long)indexPath.row];
    
    emsRightMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        NSLog(@"indexPath.row %ld",(long)indexPath.row);
    }
    
    if (!cell) {
        
        NSArray* xibCell = [[NSBundle mainBundle] loadNibNamed:@"emsRightMenuCell" owner:self options:nil];
        
        cell = [xibCell objectAtIndex:0];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self cornerIm:cell.avatarImage];
       // [self cornerIm:cell.interestImage];
    }
    
    Notification * notification = [self.notificationArrayPredicated objectAtIndex:indexPath.row];
    
    
    if (notification.notificationMessageText.length) {
        
        cell.messageText.text = notification.notificationMessageText;
        CGRect lblFrame = cell.natificatorTime.frame;
        lblFrame.origin.y = lblFrame.origin.y+3;
        cell.natificatorTime.frame= lblFrame;
        
        CGRect clockFrame = cell.clock.frame;
        clockFrame.origin.y = clockFrame.origin.y+3;
        cell.clock.frame= clockFrame;
    }
    
                
            if(self.notificationArray[indexPath.row][@"userImg"]!=nil)
            {
                if([self imageHandler:self.notificationArray[indexPath.row][@"userImg"]]==nil)
                {
                cell.avatarImage.image = [self downloadImage:
                                         [NSString stringWithFormat:@"%@%@",
                                         SERVER_PATH,self.notificationArray[indexPath.row][@"userImg"]]
                                         andImageName:self.notificationArray[indexPath.row][@"userImg"]];
                }
                else
                {
                
                    cell.avatarImage.image = [[[ABStoreManager sharedManager] imageCache]
                                             objectForKey:[self.notificationArray objectAtIndex:indexPath.row]
                                             [@"userImg"]];
                
                }
            }
                 /*
                 
                 user has started to follow you                           start_follow
                 user has stopped to follow you                           stop_follow
                 user has sent you a new ice break request                sent_request
                 user has declined your ice break request                 declined_request
                 user has accepted your ice break request                 accept_request
                 user has blocked you                                     start_block_you
                 user has removed you from Blocks                         stop_block
                 user has removed you from Friends                        stop_friend_you
                 user has started to follow activity                      start_follow_activity
                 user has stopped to follow activity                      stop_follow_activity
                 user has become a member of activity                     memberUser_activity
                 user has declined activity participation                 stop_memberUser_activity
                 
                */
                
               if([self.notificationArray[indexPath.row][@"class"] isEqualToString:@"sent_request"]){
                  cell.interestImage.image = [UIImage imageNamed:@"ice_req"];
               }
               if([self.notificationArray[indexPath.row][@"class"] isEqualToString:@"start_follow"]){
                   cell.interestImage.image = [UIImage imageNamed:@"follow_start"];
               }
               if([self.notificationArray[indexPath.row][@"class"] isEqualToString:@"stop_follow"]){
                   cell.interestImage.image = [UIImage imageNamed:@"follow_stop"];
               }
               if([self.notificationArray[indexPath.row][@"class"] isEqualToString:@"accept_request"]){
                   cell.interestImage.image = [UIImage imageNamed:@"ice_req_accepted"];
               }
               if([self.notificationArray[indexPath.row][@"class"] isEqualToString:@"start_follow_activity"]){
                   cell.interestImage.image = [UIImage imageNamed:@"act_follow_start"];
               }
               if([self.notificationArray[indexPath.row][@"class"] isEqualToString:@"stop_follow_activity"]){
                   cell.interestImage.image = [UIImage imageNamed:@"act_follow_stop"];
               }
               if([self.notificationArray[indexPath.row][@"class"] isEqualToString:@"start_block_you"]){
                   cell.interestImage.image = [UIImage imageNamed:@"blocked"];
               }
               if([self.notificationArray[indexPath.row][@"class"] isEqualToString:@"stop_block"]){
                   cell.interestImage.image = [UIImage imageNamed:@"block_remove"];
               }
               if([self.notificationArray[indexPath.row][@"class"] isEqualToString:@"stop_friend_you"]){
                   cell.interestImage.image = [UIImage imageNamed:@"friend_remove"];
               }
               if([self.notificationArray[indexPath.row][@"type"] isEqualToString:@"chat"]){
                   cell.interestImage.image = [UIImage imageNamed:@"chat"];
               }
               if([self.notificationArray[indexPath.row][@"class"] isEqualToString:@"memberUser_activity"]){
                    cell.interestImage.image = [UIImage imageNamed:@"your_act_member_become"];
               }
               if([self.notificationArray[indexPath.row][@"class"] isEqualToString:@"remove_profile"]){
                    cell.interestImage.image = [UIImage imageNamed:@"prof_del"];
               }
               if([self.notificationArray[indexPath.row][@"class"] isEqualToString:@"stop_memberUser_activity"]){
                    cell.interestImage.image = [UIImage imageNamed:@"act_decline"];
               }
               if([self.notificationArray[indexPath.row][@"class"] isEqualToString:@"create_activity_accept_friends"]){
                    cell.interestImage.image = [UIImage imageNamed:@"act_member_invite"];
               }
               if([self.notificationArray[indexPath.row][@"class"] isEqualToString:@"change_activity"]){
                    cell.interestImage.image = [UIImage imageNamed:@"act_edit"];
               }
    
    
    
            cell.natificatorName.text =  notification.notificationText;
            cell.natificatorStatus.text = notification.notificationText;
            cell.userButton.tag = indexPath.row;
            [cell.userButton addTarget:self action:@selector(selectUser:) forControlEvents:UIControlEventTouchUpInside];
            cell.natificatorTime.text =[self strDate:[NSDate dateWithTimeIntervalSince1970:[notification.notificationDate integerValue]]];
    
    
    
           return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    
}
-(NSString*)strDate:(id)timeObj
{
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterFullStyle;
    df.doesRelativeDateFormatting = YES;
    NSString *text = [df stringFromDate:timeObj];
    return text;
    
}

-(void)selectUser:(UIButton *)btn{
    
    
    [UIView animateWithDuration:0.4 animations:^{
        self.bgViewR.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 animations:^{
            self.view.frame =CGRectMake( self.view.frame.origin.x, self.delegate.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        } completion:^(BOOL finished) {
            
            Notification * notification = [self.notificationArrayPredicated objectAtIndex:btn.tag];
            NSString *notifType = [self.notificationArray objectAtIndex:btn.tag][@"type"];
            if([notifType isEqualToString:@"activity"] && ([self.notificationArray[btn.tag][@"class"] isEqualToString:@"memberUser_activity"] || [self.notificationArray[btn.tag][@"class"] isEqualToString:@"create_activity_accept_friends"] || [self.notificationArray[btn.tag][@"class"] isEqualToString:@"change_activity"]))
            {
                
                ActivityDetailViewController *reg = [[ActivityDetailViewController alloc] initWithData:@{@"aId":[self.notificationArray objectAtIndex:btn.tag][@"aid"]}];
                [self.delegate presentViewController:reg animated:YES completion:^{
                    
                }];
            }
            else if([notifType isEqualToString:@"activity"])
            {
                
                emsProfileVC *reg = [[emsProfileVC alloc] initWithNibName:@"emsProfileVC" bundle:nil];
                reg.profileUserId = [self.notificationArray objectAtIndex:btn.tag][@"uId"];
                [self.delegate presentViewController:reg animated:YES completion:^{
                    
                }];
                return;
            }
            else if([notifType isEqualToString:@"notebook"])
            {
            
                if([notification.notificationClass isEqualToString:@"start_follow"])
                {
                
                    emsProfileVC *reg = [[emsProfileVC alloc] initWithNibName:@"emsProfileVC" bundle:nil];
                    reg.profileUserId = [self.notificationArray objectAtIndex:btn.tag][@"uId"];
                    [self.delegate presentViewController:reg animated:YES completion:^{
                    
                        [Server removeNotification:[self.notificationArray objectAtIndex:btn.tag][@"id"] callback:^{
                            return;
                        }];

                        
                    }];
                    
                
                
                }
                if([notification.notificationClass isEqualToString:@"start_block_you"]||[notification.notificationClass isEqualToString:@"stop_block_you"]||[notification.notificationClass isEqualToString:@"accept_request"])
                {
                
                    [[NSUserDefaults standardUserDefaults] setValue:@"friends" forKey:@"notebook"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                
                }
                else if([notification.notificationClass isEqualToString:@"sent_request"])
                {
                    
                    [[NSUserDefaults standardUserDefaults] setValue:@"ice" forKey:@"notebook"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                }
                else if([notification.notificationClass isEqualToString:@"stop_friend_you"])
                {
                    
                    [[NSUserDefaults standardUserDefaults] setValue:@"followings" forKey:@"notebook"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    
                }
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Notebook_6plus" bundle:nil];
                NotebookViewController *notebook = [storyboard instantiateViewControllerWithIdentifier:@"NotebookViewController"];
                [self.delegate presentViewController:notebook animated:YES completion:^{
                    
                }];

            }
            else if([notifType isEqualToString:@"system"])
            {
                
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SystemFromNotifications"
                                                                    object:self
                                                                  userInfo:@{@"userId":notification.notificationUser.userId}];
                
            }
            else if([notifType isEqualToString:@"chat"])
            {
                
                [Server getChat:notification.notificationUser.userId callback:^(NSDictionary *dictionary) {
                    NSString *errorStr = [NSString stringWithFormat:@"%@",dictionary[@"errorCode"]];
                    if ([errorStr isEqualToString:@"0"]) {
                        [self.delegate presentViewController:[[emsChatVC alloc] initDictionary:dictionary] animated:YES completion:^{
                         
                        }];
                    }
                }];
            
            }
            else if([notifType isEqualToString:@"dreamshot"])
            {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DreamshotFromNotifications"
                                                                    object:self
                                                                  userInfo:@{@"userId":notification.notificationUser.userId}];
                
            }
            
            [Server removeNotification:[self.notificationArray objectAtIndex:btn.tag][@"id"] callback:^{
                if(currentType==all){
                    [self setUpArray: @"/all"];
                }else if(currentType==notebook){
                    [self setUpArray: @"/notebook"];
                }else if(currentType==tv){
                    [self setUpArray: @"/dreamshot"];
                }else if(currentType==s_system){
                    [self setUpArray: @"/system"];
                }else if(currentType==chat){
                    [self setUpArray: @"/chat"];
                }
                
            }];
            
        }];
    }];
}
-(void)cornerIm:(UIImageView*)imageView{
    imageView .layer.cornerRadius = imageView.frame.size.height/2;
    imageView.layer.masksToBounds = YES;
}
-(void)hideRightmenu:(void (^)())complite{
    
    [UIView animateWithDuration:0.4 animations:^{
        self.bgViewR.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 animations:^{
            
            self.view.frame =CGRectMake( self.view.frame.origin.x, self.delegate.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        } completion:^(BOOL finished) {
            complite();
        }];
    }];
    
}



-(IBAction)hideRightHard{
    
    [UIView animateWithDuration:0.4 animations:^{
        self.bgViewR.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 animations:^{
            self.view.frame =CGRectMake( self.view.frame.origin.x, self.delegate.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        } completion:^(BOOL finished) {
            
        }];
    }];
    
}
-(IBAction)allAction{
    currentType = all;
    [self setUpArray:@"/all"];
   
}
-(IBAction)dreamShot{
    currentType = tv;
    [self setUpArray:@"/dreamshot"];
    
}
-(IBAction)system{
    currentType = s_system;
    [self setUpArray:@"/system"];
    
}
-(IBAction)message{
    currentType = chat;
    [self setUpArray:@"/chat"];
   
}
-(IBAction)follower{
    currentType = notebook;
    [self setUpArray:@"/notebook"];
    
}

-(void)userPresed:(User *)user{

    if([self.delegate respondsToSelector:@selector(userSelected:)])
    {
        [self.delegate userSelected:user];
    }
}

-(IBAction)showOppositMenu:(id)sender{

    [self hideRightmenu:^{
        
        if([self.delegate respondsToSelector:@selector(notificationSelected:)])
        {
            [self.delegate showLeftMenu];
        }
    }];
}

-(void)notificationPresed:(Notification *)notification{
    
    [self hideRightmenu:^{
    
        if([self.delegate respondsToSelector:@selector(notificationSelected:)])
        {
            [self cleanSelf];
            
            if((unsigned long)notification.notificationType==1)
            {
                [self.delegate notificationSelected:notification];
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[emsDeviceManager isIphone6plus]?@"DreamShot_6plus":@"DreamShot" bundle:nil];
                DSViewController *dreamShot = [storyboard instantiateViewControllerWithIdentifier:@"DSViewController"];
                [self.delegate presentViewController:dreamShot animated:YES completion:^{
                    
                }];
                
                
            }

            
            
        }
    }];
}

-(void)cleanSelf{
    [[self.delegate.childViewControllers lastObject] willMoveToParentViewController:nil];
    [[[self.delegate.childViewControllers lastObject] view] removeFromSuperview];
    [[self.delegate.childViewControllers lastObject] removeFromParentViewController];
}
-(void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion{
    NSLog(@"Не надо детать  presentViewController из Menu !!!   self.delegate - вот что нужно");
}

@end
