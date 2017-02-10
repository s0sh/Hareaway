//
//  ViewController.m
//  StripeExample
//
//  Created by Jack Flintermann on 8/21/14.
//  Copyright (c) 2014 Stripe. All rights reserved.
//

#import <Stripe/Stripe.h>
#import "AFNetworking.h"
#import "SHViewController.h"
#import "PaymentViewController.h"
#import "SHConstants.h"
#import "ShippingManager.h"
//#import <ApplePayStubs/ApplePayStubs.h>
#import "emsMainScreenVC.h"
#import "ABStoreManager.h"
#import "emsAPIHelper.h"
#import "ScadaddlePopup.h"
#import "emsActivityVC.h"
#import "emsScadProgress.h"

@interface SHViewController () <PaymentViewControllerDelegate, STPCheckoutViewControllerDelegate>
{

    ScadaddlePopup *popup;
    emsScadProgress * subView;
}

@property (nonatomic) BOOL applePaySucceeded;
@property (nonatomic) NSError *applePayError;
@property (nonatomic) ShippingManager *shippingManager;
@property (nonatomic) IBOutlet UIButton *applePayButton;
@end

@implementation SHViewController

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

-(void)startUpdating
{
    
    [NSThread detachNewThreadSelector:@selector(progress) toTarget:self withObject:nil];
    
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

-(void)dismissPopupActionWithTitle:(NSString*)title1 andDuration:(double)duration andExit:(BOOL)exit
{
    
        [popup removeFromSuperview];
    
}
-(IBAction)dismissPopup
{
    
    [popup removeFromSuperview];
    
    
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    isChecked = NO;
    self.checkoutBtn.alpha = 0;
    self.creditBtn.alpha = 0;
    self.shippingManager = [[ShippingManager alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(manipulations:) name:@"ActivityCreated" object:nil];
    
   // self.applePayButton.enabled = [self applePayEnabled];
}
-(void)manipulations:(NSNotification *)notification
{

    
    [self startActivity];


}
-(void)startActivity
{
   
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self presentViewController:[[emsActivityVC alloc] init] animated:YES completion:^{
                [self stopSubview];
            }];
        });
    

}
- (void)presentError:(NSError *)error {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:nil
                                                      message:[error localizedDescription]
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                            otherButtonTitles:nil];
    [message show];
}

- (void)paymentSucceeded {
    [self messagePopupWithTitle:@"Payment successfully created!" hideOkButton:NO];

}

#pragma mark - Apple Pay
//*!****************************************************
//@note: Commented but it could be used in the future
//- (BOOL)applePayEnabled {
//    if ([PKPaymentRequest class]) {
//        PKPaymentRequest *paymentRequest = [Stripe paymentRequestWithMerchantIdentifier:AppleMerchantId];
//        return [Stripe canSubmitPaymentRequest:paymentRequest];
//    }
//    return NO;
//}

//- (IBAction)beginApplePay:(id)sender {
//    self.applePaySucceeded = NO;
//    self.applePayError = nil;
//
//    NSString *merchantId = AppleMerchantId;
//
//    PKPaymentRequest *paymentRequest = [Stripe paymentRequestWithMerchantIdentifier:merchantId];
//    if ([Stripe canSubmitPaymentRequest:paymentRequest]) {
//        [paymentRequest setRequiredShippingAddressFields:PKAddressFieldPostalAddress];
//        [paymentRequest setRequiredBillingAddressFields:PKAddressFieldPostalAddress];
//        paymentRequest.shippingMethods = [self.shippingManager defaultShippingMethods];
//        paymentRequest.paymentSummaryItems = [self summaryItemsForShippingMethod:paymentRequest.shippingMethods.firstObject];
//#if DEBUG
//        STPTestPaymentAuthorizationViewController *auth = [[STPTestPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
//#else
//        PKPaymentAuthorizationViewController *auth = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
//#endif
//        auth.delegate = self;
//        [self presentViewController:auth animated:YES completion:nil];
//    }
//}

//- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
//                  didSelectShippingAddress:(ABRecordRef)address
//                                completion:(void (^)(PKPaymentAuthorizationStatus status, NSArray *shippingMethods, NSArray *summaryItems))completion {
//    [self.shippingManager fetchShippingCostsForAddress:address
//                                            completion:^(NSArray *shippingMethods, NSError *error) {
//                                                if (error) {
//                                                    completion(PKPaymentAuthorizationStatusFailure, nil, nil);
//                                                    return;
//                                                }
//                                                completion(PKPaymentAuthorizationStatusSuccess,
//                                                           shippingMethods,
//                                                           [self summaryItemsForShippingMethod:shippingMethods.firstObject]);
//                                            }];
//}

//- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
//                   didSelectShippingMethod:(PKShippingMethod *)shippingMethod
//                                completion:(void (^)(PKPaymentAuthorizationStatus, NSArray *summaryItems))completion {
//    completion(PKPaymentAuthorizationStatusSuccess, [self summaryItemsForShippingMethod:shippingMethod]);
//}

//- (NSArray *)summaryItemsForShippingMethod:(PKShippingMethod *)shippingMethod {
//    PKPaymentSummaryItem *shirtItem = [PKPaymentSummaryItem summaryItemWithLabel:@"Promotion" amount:[NSDecimalNumber decimalNumberWithString:@"10.00"]];
//    NSDecimalNumber *total = [shirtItem.amount decimalNumberByAdding:shippingMethod.amount];
//    PKPaymentSummaryItem *totalItem = [PKPaymentSummaryItem summaryItemWithLabel:@"Scadaddle Shop" amount:total];
//    return @[shirtItem, shippingMethod, totalItem];
//}

//- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
//                       didAuthorizePayment:(PKPayment *)payment
//                                completion:(void (^)(PKPaymentAuthorizationStatus))completion {
//    [[STPAPIClient sharedClient] createTokenWithPayment:payment
//                                             completion:^(STPToken *token, NSError *error) {
//                                                 [self createBackendChargeWithToken:token
//                                                                         completion:^(STPBackendChargeResult status, NSError *error) {
//                                                                             if (status == STPBackendChargeResultSuccess) {
//                                                                                 self.applePaySucceeded = YES;
//                                                                                 completion(PKPaymentAuthorizationStatusSuccess);
//                                                                             } else {
//                                                                                 self.applePayError = error;
//                                                                                 completion(PKPaymentAuthorizationStatusFailure);
//                                                                             }
//                                                                         }];
//                                             }];
//}
//
//- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
//    if (self.applePaySucceeded) {
//        [self paymentSucceeded];
//    } else if (self.applePayError) {
//        [self presentError:self.applePayError];
//    }
//    [self dismissViewControllerAnimated:YES completion:nil];
//    self.applePaySucceeded = NO;
//    self.applePayError = nil;
//}

#pragma mark - Stripe Checkout

- (IBAction)beginStripeCheckout:(id)sender {
    STPCheckoutOptions *options = [[STPCheckoutOptions alloc] initWithPublishableKey:[Stripe defaultPublishableKey]];
    options.purchaseDescription = @"Promotion";
    options.purchaseAmount = 1000; // this is in cents
    options.logoColor = [UIColor purpleColor];
    STPCheckoutViewController *checkoutViewController = [[STPCheckoutViewController alloc] initWithOptions:options];
    checkoutViewController.checkoutDelegate = self;
    [self presentViewController:checkoutViewController animated:YES completion:nil];
}

- (void)checkoutController:(STPCheckoutViewController *)controller didCreateToken:(STPToken *)token completion:(STPTokenSubmissionHandler)completion {
    [self createBackendChargeWithToken:token completion:completion];
}

- (void)checkoutController:(STPCheckoutViewController *)controller didFinishWithStatus:(STPPaymentStatus)status error:(NSError *)error {
    switch (status) {
    case STPPaymentStatusSuccess:
        [self paymentSucceeded];
        break;
    case STPPaymentStatusError:
        [self presentError:error];
        break;
    case STPPaymentStatusUserCancelled:
        // do nothing
        break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Custom Credit Card Form

- (IBAction)beginCustomPayment:(id)sender {
    PaymentViewController *paymentViewController = [[PaymentViewController alloc] initWithNibName:nil bundle:nil];
    paymentViewController.amount = [NSDecimalNumber decimalNumberWithString:@"10.00"];
    paymentViewController.backendCharger = self;
    paymentViewController.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:paymentViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)paymentViewController:(PaymentViewController *)controller didFinish:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (error) {
        [self presentError:error];
    } else {
        [self paymentSucceeded];
    }
}

#pragma mark - STPBackendCharging

- (void)createBackendChargeWithToken:(STPToken *)token completion:(STPTokenSubmissionHandler)completion {
    NSDictionary *chargeParams = @{ @"stripeToken": token.tokenId, @"amount": @"1000" };

    if (!BackendChargeURLString) {
        NSError *error = [NSError
            errorWithDomain:StripeDomain
                       code:STPInvalidRequestError
                   userInfo:@{
                       NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Good news!\nYou have promoted your Event/Activity![Token: %@]",
                                                                             token.tokenId]
                   }];
        completion(STPBackendChargeResultFailure, error);
        return;
    }

    // This passes the token off to our payment backend, which will then actually complete charging the card using your Stripe account's secret key
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:[BackendChargeURLString stringByAppendingString:@"/charge"]
        parameters:chargeParams
        success:^(AFHTTPRequestOperation *operation, id responseObject) { completion(STPBackendChargeResultSuccess, nil); }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) { completion(STPBackendChargeResultFailure, error); }];
}

#pragma mark ViewControllerManagement

-(void)addIndicators{
    interestsIndicator = [[UIActivityIndicatorView alloc] init];
    interestsIndicator.center = self.view.center;
    interestsIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [interestsIndicator startAnimating];
    [self.view addSubview:interestsIndicator];
    
    
}
-(IBAction)sociarRodar:(id)sender{
    
    [self saveActivity];
}
-(IBAction)check
{
    
    if(isChecked){
        isChecked = NO;
        [self.checkBtn setBackgroundImage:[UIImage imageNamed:@"non_check"] forState:UIControlStateNormal];
        self.checkoutBtn.alpha = 0;
        self.creditBtn.alpha = 0;
        self.hider.alpha = 1;
        [self.nextBtn setEnabled:YES];
    }else{
        isChecked = YES;
        [self.checkBtn setBackgroundImage:[UIImage imageNamed:@"check_btn"] forState:UIControlStateNormal];
        self.checkoutBtn.alpha = 1;
        self.creditBtn.alpha = 1;
        self.hider.alpha = 0;
        [self.nextBtn setEnabled:NO];
    }
    
    
}
/*!
 @discussion  the end of torture :) . It collects all data which has been 
 setted up by the user during creating Activity in ActivityBuilder and 
 send it to the server.
 */
-(IBAction)saveActivity
{
    
        [self startUpdating];
    
        [[ABStoreManager sharedManager] removeVideoFromActivity];
        for(int i=0;i<[[ABStoreManager sharedManager] deleteImagesWithIndexes].count;i++)
        {
            NSLog(@"%d",i);
           [[ABStoreManager sharedManager] removeImagePhisicallyAtIndex:(int)[[[ABStoreManager sharedManager] deleteImagesWithIndexes][i] integerValue]];
        }
        
        if(isChecked)
        {
            [[ABStoreManager sharedManager] addData:@"1" forKey:@"promoted"];
            
        }
        [[ABStoreManager sharedManager] saveYoutubes];//Adds youtube objects to ActivityObject
        [[ABStoreManager sharedManager] prepareToSendRequest];//Adds additional data
        [[ABStoreManager sharedManager] saveThisActivity];//Create Activity object
    /*!
     @discussion  Edit activity
     */
        if([[ABStoreManager sharedManager] editingMode])
        {
        
            [Server postUpdateActivities];
        
        }
    /*!
     @discussion  Regular creating Activity
     */
        else
        {
            [Server saveActivity];
        }
    [[ABStoreManager sharedManager] setModeEditing:NO];
    
    
}

@end
