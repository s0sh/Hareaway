//
//  SettingsViewController.m
//  Scadaddle
//
//  Created by Roman Bigun on 6/15/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import "SettingsViewController.h"
#import "emsRightMenuVC.h"
#import "emsLeftMenuVC.h"
#import "SettingsManager.h"
#import "emsAPIHelper.h"
#import "UserDataManager.h"
#import "ScadaddlePopup.h"
#import "FBHelper.h"
////#import "emsLoginVC.h"
#import "emsScadProgress.h"
#import "FBHelper.h"
#import "FBWebLoginViewController.h"

@interface SettingsViewController ()
{

    ScadaddlePopup *popup;
    emsScadProgress * subView;
    
}
@end

@implementation SettingsViewController

-(void)viewWillAppear:(BOOL)animated{
    [self progress];
}
#pragma mark -Progresses
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

-(void)progressThread
{
    [NSThread detachNewThreadSelector:@selector(progress) toTarget:self withObject:nil];
}
-(void)startUpdating
{
    popup = [[ScadaddlePopup alloc] initWithFrame:self.view.frame withTitle:@"Loading..." withProgress:YES andButtonsYesNo:NO forTarget:self andMessageType:-1];
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
#pragma mark -Progresses end
- (void)viewDidLoad {
    [super viewDidLoad];
 }
-(void)viewDidAppear:(BOOL)animated
{
   
    [super viewDidAppear:YES];
    self.picker.delegate = self;
    self.picker.dataSource = self;
    self.picker.alpha = 0;
    isNotificationsSelected = YES;
    [self setNotifEnabled];
    [self initSettings];
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
-(void)initDoubleSlider
{
    
    DoubleSlider *slider = [DoubleSlider doubleSlider];
    [slider addTarget:self action:@selector(valueChangedForDoubleSlider:) forControlEvents:UIControlEventValueChanged];
    slider.tag = SLIDER_VIEW_TAG; //for testing purposes only
    [self.view addSubview:slider];
    [self valueChangedForDoubleSlider:slider];
    
}

#pragma mark Control Event Handlers
- (void)valueChangedForDoubleSlider:(DoubleSlider *)slider
{
    
    NSString *report = [NSString stringWithFormat:@"%i - %i", (int)slider.minSelectedValue , (int)slider.maxSelectedValue];
    self.reportLabel.text = report;
    
}
/*!
 * @discussion  Load initial information
 */
-(void)initSettings
{
    
    [[SettingsManager sharedManager] updateSettings];//Updates object in SettingsManager
     NSDictionary *d = [[SettingsManager sharedManager] ongoingSettings];//Object updated and we can use its data
    if(d.count>0)
    {
        self.reportLabel.text  = [NSString stringWithFormat:@"%@",d[kSettingsAgeRange]];
        self.showWhoomLbl.text = [d[kSettingsShowOnly] boolValue]==NO?@"Women":@"Men";
        self.radiusLbl.text = [NSString stringWithFormat:@"%@",d.count>2?d[kSettingsRadius]:@"1000000000"];
        isNotificationsSelected = [d[kSettingsIsNotificationEnabled] boolValue];
        [self setNotifEnabled];
        [self initDoubleSlider];
        NSString *report = [NSString stringWithFormat:@"%@ - %@", d[@"minAge"], d[@"maxAge"]];
        self.reportLabel.text = report;
        
        DoubleSlider *slider = (DoubleSlider *)[self.view viewWithTag:SLIDER_VIEW_TAG];
        if (slider) {
            
            [slider moveSlidersToPosition:[NSNumber numberWithInt:[d[@"minAge"] intValue]] : [NSNumber numberWithInt:[d[@"maxAge"] intValue]] animated:YES];
        }
    
    }
    [self dismissPopup];
    

}
/*!
 * @discussion  Change gender according to who axactly user wants to see in
 * the Radar
 */
-(IBAction)showOnlyAction
{
    if([self.showWhoomLbl.text isEqualToString:@"Women"]){
        self.showWhoomLbl.text = @"Men";
    }
    else{
        self.showWhoomLbl.text = @"Women";
    }
}
/*!
 * @discussion  Displays Radius picker with options drumm
 */
-(IBAction)radiusAction
{
    self.picker.alpha = 1;
}
-(IBAction)deleteProfile
{
    [[[UIAlertView alloc] initWithTitle:@"Delete Profile"
                               message:@"Are you sure you want to delete own profile?"
                              delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Cancel",nil, nil] show];
    
   
}
/*!
 * @discussion  Save preferences on the server/DB
 */
-(IBAction)save:(id)sender
{

    [self startUpdating];
    [self saveSettings];//Actual saving worker
    [self dismissPopupActionWithTitle:@"Saved!" andDuration:0.5 andExit:NO];
    

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if(buttonIndex==0)
    {
        [self progressThread];
        [Server removeUser];
        [[UserDataManager sharedManager] removeUsersData];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FBWebLogin" bundle:nil];
        FBWebLoginViewController *notebook = [storyboard instantiateViewControllerWithIdentifier:@"FBWebLogin"];
        
        [self presentViewController:notebook animated:YES completion:^{
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%i",0] forKey:@"defaultInterestSelected"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self stopSubview];
        }];
        
    
    }
    else
    {
    
        return;
    
    }

}
/*!
 * @discussion  Logout user from the Application
 */
-(IBAction)logout
{
    FBHelper *fh = [[FBHelper alloc] init];
    [fh fasebookLogout];
    [[UserDataManager sharedManager] removeUsersData];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FBWebLogin" bundle:nil];
    FBWebLoginViewController *notebook = [storyboard instantiateViewControllerWithIdentifier:@"FBWebLogin"];
    [self presentViewController:notebook animated:YES completion:^{
        
    }];
    
}
/*!
 * @discussion  NotificationEnabled button state changer
 * [Predefine state at view loading]
 */
-(void)setNotifEnabled
{

    if(isNotificationsSelected){
        [self.notifBtn setBackgroundImage:[UIImage imageNamed:@"switch_on_green"] forState:UIControlStateNormal];
   }else{
        [self.notifBtn setBackgroundImage:[UIImage imageNamed:@"switch_off_green"] forState:UIControlStateNormal];
   }

}
/*!
 * @discussion  NotificationEnabled button state changer.
 * [Reaction on 'changeState' action]
 */
-(void)changeStateAction
{
    if(isNotificationsSelected){
        isNotificationsSelected = NO;
        [self.notifBtn setBackgroundImage:[UIImage imageNamed:@"switch_off_green"] forState:UIControlStateNormal];
        
    }else{
        [self.notifBtn setBackgroundImage:[UIImage imageNamed:@"switch_on_green"] forState:UIControlStateNormal];
        isNotificationsSelected = YES;
    }
    
}
/*!
 * @discussion  Tapped change state button
 */
-(IBAction)changeState
{
    [self changeStateAction];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma Mark rightMenuDelegate
/*!
 * @discussion  Add defined info to an object and save preferences on the
 * server/DB
 */
-(void)saveSettings
{
    
     [[SettingsManager sharedManager] addObject:[NSString stringWithFormat:@"%@",self.reportLabel.text] forKey:kSettingsAgeRange];
     [[SettingsManager sharedManager] addObject:
     [self.showWhoomLbl.text isEqualToString:@"Women"]?
     [NSString stringWithFormat:@"%@",@"0"]:
     [NSString stringWithFormat:@"%@",@"1"]
                                     forKey:kSettingsShowOnly];
    
    [[SettingsManager sharedManager] addObject:[NSString stringWithFormat:@"%@",self.radiusLbl.text] forKey:kSettingsRadius];
    [[SettingsManager sharedManager] addObject:[NSString stringWithFormat:@"%i",isNotificationsSelected] forKey:kSettingsIsNotificationEnabled];
    [[SettingsManager sharedManager] addObject:[[UserDataManager sharedManager] serverToken] forKey:kServerApiToken];
    [Server saveSettings];
    
}
-(void)notificationSelected:(Notification *)notification
{
    [[self.childViewControllers lastObject] willMoveToParentViewController:nil];
    [[[self.childViewControllers lastObject] view] removeFromSuperview];
    [[self.childViewControllers lastObject] removeFromParentViewController];
    NSLog(@"notification %lu", (unsigned long)notification);
    
}
/*!
 * @discussion  DoubleRange slider delegates
 */
- (void)report:(RangeSlider *)sender {
    if((int)roundf(sender.min*100.f)<18.0f)
        return;
    NSString *report = [NSString stringWithFormat:@"%i - %i", (int)roundf(sender.min*100.f) , (int)roundf(sender.max*100.f)];
    self.reportLabel.text = report;
    NSLog(@"%@",report);
}
#pragma Mark leftMenudelegate
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
 * @discussion  to open Notification menu
 */
-(IBAction)showRightMenu{
    
    
    emsRightMenuVC *emsRightMenu = [ [emsRightMenuVC alloc] initWithDelegate:self];
    NSLog(@"emsLeftMenu %@",emsRightMenu.delegate);
    
}
/*!
 * @discussion  to open main menu
 */
-(IBAction)showLeftMenu{
    
    
    emsLeftMenuVC *emsLeftMenu =[[emsLeftMenuVC alloc]initWithDelegate:self ];
    NSLog(@"emsLeftMenu %@",emsLeftMenu.delegate);
   
}

#pragma mark -
#pragma mark UIPicker

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 100;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row
          forComponent:(NSInteger)component reusingView:(UIView *)view
{
    if (!view)
    {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 30)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(35, 3, 245, 24)];
        label.backgroundColor = [UIColor clearColor];
        label.tag = 1;
        label.text = [NSString stringWithFormat:@"%i",(int)row];
        [view addSubview:label];
        
    }
    
    return view;
}
- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
   self.picker.alpha = 0;
   self.radiusLbl.text = [NSString stringWithFormat:@"%i",(int)row];
    
}
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
