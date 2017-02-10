//
//  Constants.h
//  ChatApplication
//
//  Created by developer on 02/12/14.
//  Copyright (c) 2014 ErmineSoft. All rights reserved.
//
#import "AppDelegate.h"

#define kScrollUP 170
#define kScrollUP_iphone4 110

#define kMainScreenBounds [UIScreen mainScreen].bounds.size.height
#define APP (AppDelegate*)[[UIApplication sharedApplication] delegate]
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_IPHONE_4 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) > DBL_EPSILON )
#define USER_IDEOMA_IPHONE ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define IS_iOS_7    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_iOS_8    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#pragma emsLoginVC
#pragma RegistrationVC
#define kBorderHeight 32;
#define kPickerFrame CGRectMake(0, 313 , 320, 555)
#define kPickerFrameHidden CGRectMake(0, [UIScreen mainScreen].bounds.size.height , 320, 255)
#define kborderColor [UIColor colorWithRed:95/255.f green:129/255.f blue:139/255.f alpha:0.5f].CGColor
#define kTFborderColor [UIColor colorWithRed:155/255.f green:169/255.f blue:178/255.f alpha:0.8]
#pragma InterestsVC
#pragma emsProfileVC
#define VIEW_ACTIVITY 230
#define VIEW_DIMENSIONS_MY_A 320
#define VIEW_ACTIVITY_6 300
#define VIEW_DIMENSIONS_6 414
#define kNewCardFrame CGRectMake(320, newCard.frame.origin.y, newCard.frame.size.width, newCard.frame.size.height)
#define kNewCardFrameTransition CGRectMake(-100, newCard.frame.origin.y, newCard.frame.size.width, newCard.frame.size.height)
#define kNewCardFrameTransitionDone CGRectMake(45, newCard.frame.origin.y, newCard.frame.size.width, newCard.frame.size.height)
#define kNewCardFrameTransitionRihgt CGRectMake(344, newCard.frame.origin.y, newCard.frame.size.width, newCard.frame.size.height)
#pragma MainScreenVC
#define kSelectedNumberMenu  170;
#define  kSelectedNumber -1;
#define kZeroIndex 0
#define kStandartSellHeight 130
#define kNewCardFrameMainScreen CGRectMake(80, newCard.frame.origin.y, newCard.frame.size.width, newCard.frame.size.height)
#define kCellScrollRight CGRectMake(cell.sc.frame.origin.x+320, cell.sc.frame.origin.y , cell.sc.frame.size.width, cell.sc.frame.size.height)
#define kCellScrollLeft CGRectMake(cell.sc.frame.origin.x-320, cell.sc.frame.origin.y , cell.sc.frame.size.width, cell.sc.frame.size.height);
#define selectedNumberMenuScroll 200
// alerts

