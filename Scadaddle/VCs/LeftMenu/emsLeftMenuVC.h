//
//  emsLeftMenuVC.h
//  Scadaddle
//
//  Created by developer on 14/04/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol leftMenudelegate;

typedef NS_ENUM(NSUInteger, ActionsType) {
    socialRadarAction = 0,
    mapAction,
    activityAction,
    notebookAction,
    myProfileAction,
    activityBuilderAction,
    settingAction,
    quitAction
};

@interface emsLeftMenuVC : UIViewController

@property (nonatomic, assign) ActionsType actionsTypel;
@property(nonatomic,weak)UIViewController <leftMenudelegate>* delegate;
-(id)initWithDelegate:(UIViewController *)delegateVC;
@end


@protocol leftMenudelegate <NSObject>
@required
-(void)actionPresed:(ActionsType)actionsTypel complite:(void (^)())complite;
-(void)showRightMenu;
@end