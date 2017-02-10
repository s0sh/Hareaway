//
//  ViewController.h
//  StripeExample
//
//  Created by Jack Flintermann on 8/21/14.
//  Copyright (c) 2014 Stripe. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "Flurry.h"
@protocol STPBackendCharging <NSObject>

- (void)createBackendChargeWithToken:(STPToken *)token completion:(STPTokenSubmissionHandler)completion;

@end

@interface SHViewController : UIViewController<STPBackendCharging/*,FlurryDelegate*/>
{

    UIActivityIndicatorView *interestsIndicator;
    BOOL isChecked;
    
}
@property(nonatomic,retain)IBOutlet UIButton *checkBtn;
@property(nonatomic,retain)IBOutlet UIButton *nextBtn;
@property(nonatomic,retain)IBOutlet UIView *hider;
@property(nonatomic,retain)IBOutlet UIButton *creditBtn;
@property(nonatomic,retain)IBOutlet UIButton *checkoutBtn;
@end
