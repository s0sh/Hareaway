//
//  emsInterestsView.h
//  Scadaddle
//
//  Created by developer on 06/04/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface emsInterestsView : UIView{
    
    void (^resultBlock)(BOOL bl);
    void (^cellBackBlock)(BOOL bl);
    UIImageView *avatarImage;
    UILabel *nameLabel;
    UILabel *inrerestsLabelLabel;
    UITextField *mainTF;
    UIButton *checkBtn;
    NSInteger errorCount;
  
}



- (id)initWithWord:(NSString *)initWord result:(void (^)(BOOL bl))blo cellBlock:(void (^)(BOOL bl))cellBlock ;
- (id)initWithWord:(NSString *)initWord result:(void (^)(BOOL bl))blo ;
@end
