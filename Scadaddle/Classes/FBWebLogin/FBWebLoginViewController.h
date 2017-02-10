//
//  FBWebLoginViewController.h
//  Scadaddle
//
//  Created by Roman Bigun on 11/4/15.
//  Copyright © 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBWebLoginViewController : UIViewController<UIWebViewDelegate>
@property(nonatomic,retain)UIWebView *webview;
@property (nonatomic, retain) NSString *accessToken;
@property(nonatomic,retain)UIActivityIndicatorView  *FbActive;
@end
