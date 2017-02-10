//
//  emsChatVC.m
//  Fishy
//
//  Created by developer on 21/01/15.
//  Copyright (c) 2015 ErmineSoft. All rights reserved.
//

#import "emsChatVC.h"
#import "emsChatCell.h"
#import "Message.h"
#import "XMPPFramework.h"
#import "emsRightMenuVC.h"
#import "emsLeftMenuVC.h"
#import "UserDataManager.h"
#import "MediaPickerViewController.h"
#import "ABStoreManager.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "emsAPIHelper.h"
#import "NotebookViewController.h"
#import "emsScadProgress.h"
#import "FBHelper.h"
//#import "emsLoginVC.h"
#import "FBWebLoginViewController.h"

const CGFloat rWidthOffset = 30.0f;
const CGFloat rImageSize = 50.0f;

@interface emsChatVC ()< emsChatCellDataSource, emsChatCellDelegate>{
    UIImage *myAvatar;
    UIImage *oponentAvatar;
    IBOutlet UIView *viewWithPicker;
    BOOL pickerIsShow;
    NSString *password;
    BOOL customCertEvaluation;
    BOOL isXmppConnected;
    XMPPStream *xmppStream;
    XMPPReconnect *xmppReconnect;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
    XMPPvCardTempModule *xmppvCardTempModule;
    XMPPvCardAvatarModule *xmppvCardAvatarModule;
    XMPPCapabilities *xmppCapabilities;
    XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    emsScadProgress * subView;
    IBOutlet UIView *detailImageView;
}
@property (nonatomic, strong) NSMutableArray *messages;

@property(weak) IBOutlet UIView *contentView;
@property(retain)IBOutlet UITextField *commentsTF;
@property (retain )NSMutableArray *commentsArray;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, assign) id  _chatDelegate;
@property (nonatomic, assign) id  _messageDelegate;
@property (retain, nonatomic) NSMutableArray *smileArray;
@property (retain, nonatomic) NSMutableDictionary *usersData;
@property (nonatomic, weak) IBOutlet UILabel *titleLbl;
@property (nonatomic, retain) IBOutlet UIScrollView *smileScroll;
@property (nonatomic, weak) IBOutlet UIImageView *detailImage;
@end

@implementation emsChatVC


/**
 *  @discussion Keyboard delagate.
 */

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    NSInteger textLength = 0;
    textLength = [textField.text length] + [string length] - range.length;
    if([[textField text] length] == 0 && [string isEqualToString:@" "])
    {
        return NO;
    }else{
        return YES;
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self progress];
}
/*!
 *Show progress view ander superView
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
 * Remove progress view from superView
 */

-(void)stopSubview{
    
    [UIView animateWithDuration:0.5 animations:^{
        subView.alpha = 0;
    } completion:^(BOOL finished) {
        [subView removeFromSuperview];
        subView = nil;
    }];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:YES];
    
    [[ABStoreManager sharedManager] setDoneEditing:NO];
    
    if ([[ABStoreManager sharedManager] imageForChat]!=nil) {
        

        /*!
         * gets image from
         */
        UIImage *ima = [[UIImage alloc] init];
        
        ima = [[ABStoreManager sharedManager] imageForChat];
        [self scrollToBottomTable];
        [self.messages  insertObject:[Message messageWithString:@"" image:oponentAvatar date:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]] status:sendingMessage  owner:ownerSelf andAttacmentImage:ima attachUrl:nil] atIndex:[self.messages count]];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.messages  count]-1 inSection:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        emsChatCell* cell = (emsChatCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        CATransition *transition = [CATransition animation];
        transition.duration = 1.0f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionPush;
        [cell.dateLable.layer addAnimation:transition forKey:nil];
        [cell.bubbleView.layer addAnimation:transition forKey:nil];
        [cell.textLabel.layer addAnimation:transition forKey:nil];
        [cell.arrowImage.layer addAnimation:transition forKey:nil];
        [self.tableView  performSelector:@selector(reloadData) withObject:nil afterDelay:2.05];
        
        [self sendImade:ima];
        
    }else{

        /*!
         * gets messages from xmpp server
         */
        NSArray *tmpArr = [NSArray array];
        tmpArr =[self.usersData objectForKey:@"messageArchive"];
        
        for (NSDictionary *dic in tmpArr) {
            
            if ([[dic objectForKey:@"fromjid"] isEqualToString:[NSString stringWithFormat:@"%@@scadjabber.gotests.com",self.usersData[@"user"][@"uId"]]]) {
                NSData *newdata=[[dic objectForKey:@"body"] dataUsingEncoding:NSUTF8StringEncoding
                                                         allowLossyConversion:YES];
                NSString *mystring=[[NSString alloc] initWithData:newdata encoding:NSNonLossyASCIIStringEncoding];
                if (mystring != NULL) {
                    
                    NSString *string = @"http://scad" ;
                    
                    if ([mystring rangeOfString:string].location != NSNotFound) {
                        
                        [self.messages  insertObject:[Message messageWithString:mystring image:oponentAvatar date:[NSString stringWithFormat:@"%ld", (long)[[NSString stringWithFormat:@"%@",[dic objectForKey:@"sentdate"]] integerValue]] status:sendingMessage  owner:ownerSelf andAttacmentImage:nil attachUrl:YES] atIndex:[self.messages count]];
                        
                    }else{
                        
                        [self.messages  insertObject:[Message messageWithString:mystring image:oponentAvatar date:[NSString stringWithFormat:@"%ld", (long)[[NSString stringWithFormat:@"%@",[dic objectForKey:@"sentdate"]] integerValue]] status:sendingMessage  owner:ownerSelf andAttacmentImage:nil attachUrl:nil] atIndex:[self.messages count]];
                    }
                }
            }else{
                /*!
                 * gets messages from ourserver
                 */
                NSData *newdata=[[dic objectForKey:@"body"] dataUsingEncoding:NSUTF8StringEncoding
                                                         allowLossyConversion:YES];
                NSString *mystring=[[NSString alloc] initWithData:newdata
                                                         encoding:NSNonLossyASCIIStringEncoding];
                
                NSString *string = @"http://scad";
                
                if ([mystring rangeOfString:string].location != NSNotFound) {
                    
                    [self.messages  insertObject:[Message messageWithString:mystring image:oponentAvatar date:[NSString stringWithFormat:@"%ld", (long)[[NSString stringWithFormat:@"%@",[dic objectForKey:@"sentdate"]] integerValue]] status:sendingMessage  owner:ownerOther andAttacmentImage:nil attachUrl:YES] atIndex:[self.messages count]];
                }else{
                    [self.messages  insertObject:[Message messageWithString:mystring image:oponentAvatar date:[NSString stringWithFormat:@"%ld", (long)[[NSString stringWithFormat:@"%@",[dic objectForKey:@"sentdate"]] integerValue]] status:sendingMessage  owner:ownerOther andAttacmentImage:nil attachUrl:nil] atIndex:[self.messages count]];
                }
            }
        }
        
        [self.tableView reloadData];
        [self scrollToBottomTable];
    }
    
    [self stopSubview];
}

/*!
 * @return: User object dictionary
 */
- (id)initDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        
        self.usersData = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
    }
    return self;
}


-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self initArray];
    [self picData];
    self.titleLbl.text = self.usersData[@"friendName"];
    [self scrleSetap];
    self.messages = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [self setupStream];
    
    if (![self connect])
    {
        
    }
    
    [self setViewPicker];
}
/**
 *  @discussion Method set Picker view frame
 */

-(void)setViewPicker{
    CGRect frame = viewWithPicker.frame;
    frame.origin.y =1200;
    viewWithPicker.frame = frame;
    [self.view addSubview:viewWithPicker];
}


#pragma mark - UITableViewDelegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *message = [self.messages objectAtIndex:indexPath.row];
    
    NSString *CellIdentifier = [NSString stringWithFormat: @"Cell%li", (long)indexPath.row];
    
    emsChatCell *cell = (emsChatCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[emsChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = self.tableView.backgroundColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.dataSource = self;
        cell.delegate = self;
        
        cell.textLabel.text = message.message;
        cell.imageView.image = message.avatar;
        cell.dateLable.text  = [self strDate:[NSDate dateWithTimeIntervalSince1970:[message.messageDate integerValue]]];
        cell.attachView.image = message.attachImage;
        
        
        cell.twitterButton.tag = indexPath.row;
        [cell.twitterButton addTarget:self action:@selector(twitterShare:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.fbButton.tag = indexPath.row;
        [cell.fbButton addTarget:self action:@selector(facebookShare:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.showImageBtn.tag = indexPath.row;
        [cell.showImageBtn addTarget:self action:@selector(imageShow:) forControlEvents:UIControlEventTouchUpInside];
        if (message.messageStatus == sentMessage) {
            [self sentSnatus:cell.statusImage];
        }
        if (message.messageStatus == readMessage) {
            [self readStatus:cell.statusImage];
        }
    }
    
    if (message.messageOwner == ownerSelf) {
        cell.imageUrl = (NSString *)self.usersData[@"user"][@"userImg"];
        cell.authorType = cellAuthorTypeSelf;
        
    }else{
        cell.imageUrl = (NSString *)self.usersData[@"friendUser"][@"userImg"];
        cell.authorType = cellAuthorTypeOther;
        
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *message = [self.messages objectAtIndex:indexPath.row];
    CGSize size;
    size = [message.message sizeWithFont:[UIFont fontWithName:@"MyriadPro-Cond" size:14] constrainedToSize:CGSizeMake(self.tableView.frame.size.width - [self minInsetForCell:nil atIndexPath:indexPath] -rImageSize - 8.0f - rWidthOffset, CGFLOAT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    
    if (message.isImage == YES) {
        
        return 140;
    }
    
    if (message.attachImage != nil) {
        
        return 140;
        
    }else{
        
        return size.height +55.0f;
    }
}

- (CGFloat)minInsetForCell:(emsChatCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        return 100.0f;
    }
    
    return 50.0f;
}


/**
 *  @discussion interfaceOrientation delagate
 */

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark social TFDelegate

/**
 *  @discussion Keyboard delagate
 */
- (void)keyboardWasShown:(NSNotification *)notification
{
    [self scrollMainToUp:YES];
    pickerIsShow = YES;
    CGRect keyboardRect = [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    self.contentView.frame =CGRectMake(self.contentView.frame.origin.x,
                                       self.view.frame.size.height -  keyboardRect.size.height -44,
                                       self.contentView.frame.size.width ,
                                       self.contentView.frame.size.height);
    
    
    [self scrollToBottomTable];
}

/**
 *  @discussion Keyboard delagate
 */
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    pickerIsShow = NO;
    
    self.contentView.frame =CGRectMake(self.contentView.frame.origin.x,
                                       453,
                                       self.contentView.frame.size.width,
                                       self.contentView.frame.size.height);
    [self scrollMainToUp:NO ];
}
/**
 *  @discussion TextField delegate
*/
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

/**
 *  @discussion Method resigns TextView
*/

-(void)scrollToBottomTable{
    
    [UIView animateWithDuration:.8 animations:^{
        
        [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentSize.height-self.tableView.frame.size.height +44,
                                                       self.tableView.bounds.size.width,
                                                       self.tableView.bounds.size.height)
                                   animated:YES];
        
    }];
    
}
/**
 * @discussion Method send xmpp message
 */

-(IBAction)sendMessage{
    
    if (self.commentsTF.text.length && ![self.commentsTF.text isEqualToString:@" "]) {
        
        NSData *data = [self.commentsTF.text dataUsingEncoding:NSNonLossyASCIIStringEncoding];
        NSString *goodValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:goodValue];
        
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        
        [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@scadjabber.gotests.com",self.usersData[@"friendUser"][@"uId"]]];
        [message addChild:body];
        
        [self.xmppStream sendElement:message];
        
        [self scrollToBottomTable];
        [self.messages  insertObject:[Message messageWithString:self.commentsTF.text image:myAvatar date:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]]  status:sentMessage  owner:ownerSelf andAttacmentImage:nil attachUrl:nil] atIndex:[self.messages count]];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.messages  count]-1 inSection:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        
        emsChatCell* cell = (emsChatCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        
        CATransition *transition = [CATransition animation];
        transition.duration = 1.0f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionPush;
        
        [cell.dateLable.layer addAnimation:transition forKey:nil];
        [cell.bubbleView.layer addAnimation:transition forKey:nil];
        [cell.textLabel.layer addAnimation:transition forKey:nil];
        [cell.arrowImage.layer addAnimation:transition forKey:nil];
        [self.tableView  performSelector:@selector(reloadData) withObject:nil afterDelay:2.05];
        
        if (pickerIsShow) {
            [self.commentsTF resignFirstResponder];
        }
    
        [Server checkSendPush:self.usersData[@"friendUser"][@"uId"] callback:^(NSString * boolCheck) {
            if (boolCheck) {
                NSString *string = @"Unavailable";
                if ([boolCheck rangeOfString:string].location != NSNotFound) {
               /*!
                * @discussion User Unavailable send Push
                */
                    [Server postPush:self.usersData[@"friendUser"][@"uId"] andMessage:self.commentsTF.text callback:^(NSString *callBack){
                        
                    }];
                    self.commentsTF.text = @"";
                } else {
                    
                    /*!
                     *User Available
                     */
                   
                    self.commentsTF.text = @"";
                }
            }
            self.commentsTF.text = @"";
        }];
        
        //Push
    }
}

/**
 *  @discussion Method sets corner radius to images
*/

-(void)cornerImage:(UIImageView*)imageView{
    
    imageView .layer.cornerRadius = imageView.frame.size.height/2;
    imageView .layer.borderWidth = 1.0f;
    imageView .layer.borderColor = [UIColor colorWithRed:95/255.f green:129/255.f blue:139/255.f alpha:0.5f].CGColor;
    imageView .layer.shadowColor = [UIColor blackColor].CGColor;
    imageView.layer.masksToBounds = YES;
}

/*!
 * strDate
 * @discussion Method generates date
 * @return:NSDAte in string format
 */
-(NSString*)strDate:(id)timeObj
{
    NSDate *dateToday =[NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM dd hh:mm"];
    NSString *string = [format stringFromDate:dateToday];
    return string;
}


/**
 * @discussion Method sets message status (read / anread)
 */

-(void)sentSnatus:(UIImageView *)imageView{
    imageView.image = [UIImage imageNamed:@"chekmark"];
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    [imageView.layer addAnimation:transition forKey:nil];
}
/**
 * @discussion Method sets message status (read / anread)
 */
-(void)readStatus:(UIImageView *)imageView{
    
    imageView.image = [UIImage imageNamed:@"chekmark_blue"];
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    [imageView.layer addAnimation:transition forKey:nil];
}

- (void)scrollMainToUp:(BOOL)up{
    int yUP = 170;
    
    if (up) {
        yUP = -170;
        
        if (!pickerIsShow ) {

        }
        
        
    }else{
        
        if (!pickerIsShow ) {
            
        }
    }
}

/**
 * @discussion Method sets all xmpp modules
 */

- (void)setupStream
{
    
    xmppStream = [[XMPPStream alloc] init];
    
#if !TARGET_IPHONE_SIMULATOR
    {
        xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    
    xmppReconnect = [[XMPPReconnect alloc] init];
    xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
    xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    // Activate xmpp modules
    [xmppReconnect         activate:xmppStream];
    [xmppvCardTempModule   activate:xmppStream];
    [xmppvCardAvatarModule activate:xmppStream];
    [xmppCapabilities      activate:xmppStream];
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
 
    
}

/**
 * @discussion Method send image via socket
 */

- (BOOL)connect
{
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    
    NSString *myJID = [NSString stringWithFormat:@"%@@scadjabber.gotests.com",self.usersData[@"user"][@"uId"]];
    NSString *myPassword =[[UserDataManager sharedManager] serverToken];
    [xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
    password = myPassword;
    
    NSError *error = nil;
    
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    {
        return NO;
    }
    
    return YES;
}

/**
 * @discussion Method send image via socket
 */

-(IBAction)sendImage:(id)sender{
    
    
    UIImage *ima = [[UIImage alloc] init];
    ima = [UIImage imageNamed:@"fb_icon"];
    
    NSData *dataF = UIImagePNGRepresentation(ima);
    NSString *imgStr=[dataF base64Encoding];
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:self.commentsTF.text];
    
    NSXMLElement *ImgAttachement = [NSXMLElement elementWithName:@"attachement"];
    [ImgAttachement setStringValue:imgStr];
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@scadjabber.gotests.com",self.usersData[@"friendUser"][@"uId"]]];
    [message addChild:body];
    [message addChild:ImgAttachement];
    [self.xmppStream sendElement:message];
    
}
#pragma mark XMPPStream Delegate

/**
 * @discussion XMPP Delegate. Method checks socket Connection
 * @param XMPPStream sender
 * @param GCDAsyncSocket socket
 */

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    
}

/**
 * @discussion XMPP Delegate. Method checks Secure connection
 * @param XMPPStream sender
 */

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
    
    NSString *expectedCertName = [xmppStream.myJID domain];
    
    if (expectedCertName)
    {
        settings[(NSString *) kCFStreamSSLPeerName] = expectedCertName;
    }
    
    if (customCertEvaluation)
    {
        settings[GCDAsyncSocketManuallyEvaluateTrust] = @(YES);
    }
}

/**
 *
 * @discussion XMPP Delegate. Method checks XMPP Authenticate.Colls if did  Authenticate
 * @param XMPPStream sender
 */

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    isXmppConnected = YES;
    NSError *error = nil;
    if (![[self xmppStream] authenticateWithPassword:password error:&error])
    {
        
    }
}

/**
 * @discussion XMPP Delegate. Method checks XMPP Authenticate.Colls if did  Authenticate
 * @param XMPPStream sender
 */
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [[self xmppStream] sendElement:presence];
}

/**
 * didNotAuthenticate
 * @discussion XMPP Delegate. Method checks XMPP Authenticate.Colls if did Not Authenticate
 * @param XMPPStream sender
 */

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    
}

/**
 *
 * @discussion XMPP Delegate. Method receives new XMPPIQ.
 * @param XMPPStream sender
 */

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    return NO;
}

/**
 * @discussion XMPP Delegate. Method receives new XMPPMessage.
 * @param XMPPStream sender
 */

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    
    if ([message isChatMessageWithBody])
    {
        UIImage* image;
        
        if ([message elementForName:@"attachement"]) {
            
            NSString * trt = [[message elementForName:@"attachement"] stringValue];
            
            NSData* data = [[NSData alloc] initWithBase64EncodedString:trt options:0];
            
            image = [UIImage imageWithData:data];
            
        }
        
        [self scrollToBottomTable];
        
        NSString *str = [[message elementForName:@"body"]stringValue];
        NSString* esc1 = [str stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
        NSString* esc2 = [esc1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        NSString* quoted = [[@"\"" stringByAppendingString:esc2] stringByAppendingString:@"\""];
        NSData* data = [quoted dataUsingEncoding:NSUTF8StringEncoding];
        NSString* unesc = [NSPropertyListSerialization propertyListFromData:data
                                                           mutabilityOption:NSPropertyListImmutable format:NULL
                                                           errorDescription:NULL];
        
        NSString *string = @"http://scad" ;
        
        
        
        if ([unesc rangeOfString:string].location != NSNotFound) {
            
            [self.messages  insertObject:[Message messageWithString:unesc image:oponentAvatar date:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]] status:sendingMessage  owner:ownerOther andAttacmentImage:image attachUrl:YES] atIndex:[self.messages count]];
            
        }else{
            
            [self.messages  insertObject:[Message messageWithString:unesc image:oponentAvatar date:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]] status:sendingMessage  owner:ownerOther andAttacmentImage:image attachUrl:nil] atIndex:[self.messages count]];
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.messages  count]-1 inSection:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        emsChatCell* cell = (emsChatCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        
        CATransition *transition = [CATransition animation];
        transition.duration = 1.0f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionPush;
        
        [cell.dateLable.layer addAnimation:transition forKey:nil];
        [cell.bubbleView.layer addAnimation:transition forKey:nil];
        [cell.textLabel.layer addAnimation:transition forKey:nil];
        [cell.arrowImage.layer addAnimation:transition forKey:nil];
        [self.tableView  performSelector:@selector(reloadData) withObject:nil afterDelay:1.5];
        
        
    }
}


/**
 * @discussion XMPP Delegate. Method receives new XMPPPresence.
 * @param XMPPStream sender
 */
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    
    
}

/**
 * @discussion  Method checks xmpp Disconnection error
 * @param XMPPStream sender
 */

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    
    
}

/**
 * @discussion  Method checks xmpp Disconnection
 * @param XMPPStream sender
 */
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    if (!isXmppConnected)
    {
        
    }
}


#pragma mark XMPPRosterDelegate
/**
 * @discussion  XMPP Roster Delegate
 * return:XMPPPresence
 */
- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
    
    
    
}
/**
 * @discussion Method sets xmpp Configuration
 * return:XMPPStream
 */
- (XMPPStream *)xmppStream {
    return  xmppStream ;
}


/**
 * @discussion Method shows picker
 */
-(IBAction)showPicker{
    
    [self.self.commentsTF resignFirstResponder];
    
    [UIView animateWithDuration:0.4 animations:^{
        
        viewWithPicker.frame =CGRectMake(0, 405 , 320, 555);
    }];
    
}

/**
 * @discussion Method sets fetch Configuration
 * return:XMPPStream
 */
-(void)xmppRoomDidJoin:(XMPPRoom *)sender {
    
    [sender fetchConfigurationForm];
}

-(IBAction)tesstt:(id)sender{
    
    [[ABStoreManager sharedManager] setChatDataDictionary:self.messages];
    [[ABStoreManager sharedManager] setChatMode:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ActivityBuilder_4" bundle:nil];
    MediaPickerViewController *notebook = [storyboard instantiateViewControllerWithIdentifier:@"MediaPicker"];
    
    [self presentViewController:notebook animated:YES completion:^{
        
    }];
}
/**
 * @discussion Method sets smiles view
 *
 */
-(void)picData{
    
    viewWithPicker.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height , 320, 255);
    [self.view addSubview:viewWithPicker];
}

-(void)scrleSetap{
    
    int xPos = 0;
    int yPos = 3;
    int lineCount = 0;
    for (int i =1;i!=[self.smileArray count];i++)
    {
        if (i==9)
        {
            lineCount=0;
            xPos=0;
            yPos=+25;
        }
        if (i==17)
        {
            lineCount=0;
            xPos=0;
            yPos=+45;
        }
        
        if (i==25)
        {
            lineCount=0;
            xPos=0;
            yPos=+65;
        }
        if (i==33)
        {
            lineCount=0;
            xPos=0;
            yPos=+85;
        }
        if (i==41)
        {
            lineCount=0;
            xPos=0;
            yPos=+105;
        }
        if (i==49)
        {
            lineCount=0;
            xPos=0;
            yPos=+125;
        }
        if (i==57)
        {
            lineCount=0;
            xPos=0;
            yPos=+145;
        }
        if (i==65)
        {
            lineCount=0;
            xPos=0;
            yPos=+165;
        }
        if (i==73)
        {
            lineCount=0;
            xPos=0;
            yPos=+185;
        }
        
        UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
        
        bt.frame=CGRectMake(xPos, yPos, 40, 20);
        
        NSString *str = [self.smileArray objectAtIndex:i];
        
        NSString* esc1 = [str stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
        NSString* esc2 = [esc1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        NSString* quoted = [[@"\"" stringByAppendingString:esc2] stringByAppendingString:@"\""];
        NSData* data = [quoted dataUsingEncoding:NSUTF8StringEncoding];
        NSString* unesc = [NSPropertyListSerialization propertyListFromData:data
                                                           mutabilityOption:NSPropertyListImmutable format:NULL
                                                           errorDescription:NULL];
        
        
        [bt setTitle:unesc forState:UIControlStateNormal];
        bt.tag = i;
        [bt.titleLabel setTextAlignment: NSTextAlignmentLeft];
        [bt addTarget:self action:@selector(emoctionSelected:) forControlEvents:UIControlEventTouchUpInside];
        xPos=xPos+40;
        [self.smileScroll addSubview:bt];
        lineCount = lineCount+1;
    }
    
    if ([[UIScreen mainScreen] bounds].size.height>480.0)
    {
        self.smileScroll.contentSize=CGSizeMake(320, 120);
    }
    else
    {
        self.smileScroll.contentSize=CGSizeMake(320, 160);
    }
}

/**
 * @discussion Method sends emoction char vie text fiald
 *
 */

-(void)emoctionSelected:(id)sender
{
    UIButton *button = (UIButton *)sender;
    int smileIndex = (int)button.tag;
    NSString* input =[self.smileArray objectAtIndex:smileIndex];
    
    NSString* esc1 = [input stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString* esc2 = [esc1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString* quoted = [[@"\"" stringByAppendingString:esc2] stringByAppendingString:@"\""];
    NSData* data = [quoted dataUsingEncoding:NSUTF8StringEncoding];
    NSString* unesc = [NSPropertyListSerialization propertyListFromData:data
                                                       mutabilityOption:NSPropertyListImmutable format:NULL
                                                       errorDescription:NULL];
    
    self.commentsTF.text =  [NSString stringWithFormat:@"%@%@",self.commentsTF.text,unesc];
    
    viewWithPicker.frame =CGRectMake(0, 1105 , 320, 555);
}

/**
 * @discussion Method sets smiles array
 *
 */
-(void)initArray{
    
    self.smileArray  =  [[NSMutableArray alloc] initWithObjects:
                         
                         @"\\ud83d\\ude00",@"\\ud83d\\ude01",@"\\ud83d\\ude02",
                         @"\\ud83d\\ude03",@"\\ud83d\\ude04",@"\\ud83d\\ude05",
                         @"\\ud83d\\ude06",@"\\ud83d\\ude07",@"\\ud83d\\ude08",
                         @"\\ud83d\\ude09",@"\\ud83d\\ude0a",@"\\ud83d\\ude0b",
                         @"\\ud83d\\ude0c",@"\\ud83d\\ude0d",@"\\ud83d\\ude0e",
                         @"\\ud83d\\ude0f",@"\\ud83d\\ude10",@"\\ud83d\\ude11",
                         @"\\ud83d\\ude12",@"\\ud83d\\ude13",@"\\ud83d\\ude14",
                         @"\\ud83d\\ude15",@"\\ud83d\\ude16",@"\\ud83d\\ude17",
                         @"\\ud83d\\ude18",@"\\ud83d\\ude19",@"\\ud83d\\ude1a",
                         @"\\ud83d\\ude1b",@"\\ud83d\\ude1c",@"\\ud83d\\ude1d",
                         @"\\ud83d\\ude1e",@"\\ud83d\\ude1f",@"\\ud83d\\ude20",
                         @"\\ud83d\\ude21",@"\\ud83d\\ude22",@"\\ud83d\\ude23",
                         @"\\ud83d\\ude24",@"\\ud83d\\ude25",@"\\ud83d\\ude26",
                         @"\\ud83d\\ude27",@"\\ud83d\\ude28",@"\\ud83d\\ude29",
                         @"\\ud83d\\ude2a",@"\\ud83d\\ude2b",@"\\ud83d\\ude2c",
                         @"\\ud83d\\ude2d",@"\\ud83d\\ude2e",@"\\ud83d\\ude2f",
                         @"\\ud83d\\ude30",@"\\ud83d\\ude31",@"\\ud83d\\ude32",
                         @"\\ud83d\\ude33",@"\\ud83d\\ude34",@"\\ud83d\\ude35",
                         @"\\ud83d\\ude36",@"\\ud83d\\ude37",@"\\ud83d\\ude15",
                         nil];
}

/**
 * @discussion Method share data via facebook
 *
 */
-(void)facebookShare:(UIButton *)sender
{
    
    Message *message = [self.messages objectAtIndex:sender.tag];
    
    NSString * shareText;
    
    if (message.messageOwner == ownerSelf) {
        shareText = [NSString stringWithFormat:@"said: %@  in Scadaddle application",message.message];
    }else{
        shareText = [NSString stringWithFormat:@"%@ said: %@ in Scadaddle application",self.usersData[@"friendName"],message.message];
    }
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [controller setInitialText:[NSString stringWithFormat:@"%@",shareText]];
    [self presentViewController:controller animated:YES completion:Nil];
    
    
}

/**
 * @discussion Method share data via twitter
 *
 */

-(void)twitterShare:(UIButton *)sender
{
    Message *message = [self.messages objectAtIndex:sender.tag];
    
    NSString * shareText;
    
    if (message.messageOwner == ownerSelf) {
        shareText = [NSString stringWithFormat:@"said: %@  in Scadaddle application",message.message];
    }else{
        shareText = [NSString stringWithFormat:@"%@ said: %@ in Scadaddle application",self.usersData[@"friendName"],message.message];
    }
    
    
    SLComposeViewController *tweetSheet = [SLComposeViewController
                                           composeViewControllerForServiceType:SLServiceTypeTwitter];
    [tweetSheet setInitialText:[NSString stringWithFormat:@"%@",shareText]];
    [self presentViewController:tweetSheet animated:YES completion:nil];
    
}


#pragma Mark rightMenuDelegate

/**
 * @discussion Method cleans child view controllers
 */
-(void)notificationSelected:(Notification *)notification
{
    [[self.childViewControllers lastObject] willMoveToParentViewController:nil];
    [[[self.childViewControllers lastObject] view] removeFromSuperview];
    [[self.childViewControllers lastObject] removeFromParentViewController];
}

/**
 *  @discussion Sets up Righ Menu
 */
-(IBAction)showRightMenu{
    
    emsRightMenuVC *emsRightMenu = [ [emsRightMenuVC alloc] initWithDelegate:self];

}
#pragma Mark leftMenudelegate

/**
 *  @discussion Sets up Left Menu
 *
 */
-(IBAction)showLeftMenu{
    emsLeftMenuVC *emsLeftMenu =[[emsLeftMenuVC alloc]initWithDelegate:self ];

}

/*!
 * @discussion Sets up Left Menu
 * @param actionsTypel actions that were chosen
 * @see emsLeftMenuVC
 */

-(void)actionPresed:(ActionsType)actionsTypel complite:(void (^)())complite{
    
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
        
    }else{
        
         [self clearData ];
    }
    complite();
   
}

/**
 *
 * Method called to clean class instances
 */
-(void)clearData{
     [[ABStoreManager sharedManager] setImageForChat:nil];
    for (UIView *view in self.view.subviews) {// временный dealloc
        [view removeFromSuperview];
    }
    [[ABStoreManager sharedManager] setImageForChat:nil];
    [[ABStoreManager sharedManager] setChatMode:NO];
    [[ABStoreManager sharedManager] setChatDataDictionary:nil];
     [[ABStoreManager sharedManager]  flushData];
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self teardownStream];
}

/**
 *  @discussion Method cleans all xmpp parts when applicationWillTerminate
 */
- (void)applicationWillTerminate:(UIApplication *)application
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self teardownStream];
}

/**
 *  @discussion Method cleans all xmpp parts
 */
- (void)teardownStream
{

    [xmppStream removeDelegate:self];
    [xmppReconnect         deactivate];
    [xmppvCardTempModule   deactivate];
    [xmppvCardAvatarModule deactivate];
    [xmppCapabilities      deactivate];
    [xmppStream disconnect];
    xmppStream = nil;
    xmppReconnect = nil;
    xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
    xmppvCardAvatarModule = nil;
    xmppCapabilities = nil;
    xmppCapabilitiesStorage = nil;
    [viewWithPicker removeFromSuperview];
    xmppCapabilitiesStorage =nil;
}

/**
 *  @discussion keyboard delagate
 */
-(IBAction)backAction:(id)sender{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Notebook_6plus" bundle:nil];
    NotebookViewController *notebook = [storyboard instantiateViewControllerWithIdentifier:@"NotebookViewController"];
    [self presentViewController:notebook animated:YES completion:^{
        
    }];
    
    [self clearData ];
}

/**
 *  @discussion Method gets detail image
*/
-(void)imageShow:(UIButton *)sender{
    
    Message *message = [self.messages objectAtIndex:(int)sender.tag];
    
    if (message.attachImage == nil) {
        
        UIImageView *v = [[UIImageView alloc] init];
        
        if(![self imageHandlerInterest:message.message andInterestView:v])
        {
            [self downloadImage:message.message andIndicator:nil addToImageView:v andImageName:message.message];
        }
        
        [self selectrdImage:v.image andIndex:(int)sender.tag];
        
    }else{
        
        [self selectrdImage:message.attachImage andIndex:(int)sender.tag];
    }
}

/**
 *  @discussion Method sets detail image view
*/

-(void)selectrdImage:(UIImage *)image andIndex:(int)imageIndex{
    
    detailImageView.frame = CGRectMake(0, 0 , 320, 500);
    
    [self.view addSubview: detailImageView];
    
    self.detailImage.image = image;
    
    [UIView animateWithDuration:1.8 animations:^{
        detailImageView.hidden = NO;
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 animations:^{
            
        }];
    }];
}

/**
 *  @discussion Method hides image dettail screen
*/
-(IBAction)hideImage{
    
    [detailImageView removeFromSuperview];
    
    [UIView animateWithDuration:1.8 animations:^{
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 animations:^{
            
        }];
    }];
}
/*!
 * @discussion to download image by path and set image to appropriate image view
 * @param coverUrl absolute path to image
 * @param targetView set image here after download is complete
 * @param imageName we use it as a unique key to save image in cache
 */
-(void)downloadImage:(NSString *)coverUrl andIndicator:(UIActivityIndicatorView*)indicator addToImageView:(UIImageView*)targetView andImageName:(NSString*)imageName{
    __block UIImage *image = [UIImage new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:coverUrl]];
        image  = [UIImage imageWithData:imageData];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [indicator stopAnimating];
            if (image == nil) {
                
                targetView.image = [UIImage imageNamed:@"placeholder"];
                
            }else{
                
                targetView.image = image;
                
                if(image){
                    
                    [[[ABStoreManager sharedManager] imageCache] setObject:image forKey:imageName];
                    
                }
            }
        });
    });
    
    
}


-(BOOL)imageHandlerInterest:(NSString*)path andInterestView:(UIImageView *)imageView
{
    UIImage *image = [[[ABStoreManager sharedManager] imageCache] objectForKey:path];
    
    if(image)
    {
        imageView.image = image;
        
        return YES;
    }
    
    imageView.image = [UIImage imageNamed:@"placeholder"];
    
    return NO;
}

/**
 * @discussion Method sends image to apponent
 */

-(void)sendImade:(UIImage *)image
{
    __block NSString * str ;
    
    NSMutableDictionary *tmp=[[NSMutableDictionary alloc] init];
    
    [tmp setObject:image forKey:kUDKUserInfoAvatarFile];
    [tmp setObject:[[UserDataManager sharedManager] serverToken] forKey:kServerApiToken];
    
    [Server sendImageToChat:tmp callback:^(NSString * callback) {
        str = callback;
    }];
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:str];
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    
    [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@scadjabber.gotests.com",self.usersData[@"friendUser"][@"uId"]]];
    
    [message addChild:body];
    
    [self.xmppStream sendElement:message];
    
    
}

- (void)sendElement:(NSXMLElement *)element{

}
-(void)viewDidDisappear:(BOOL)animated{

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
