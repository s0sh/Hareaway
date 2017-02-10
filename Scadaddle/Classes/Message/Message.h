//
//  Message.h
//  Fishy
//
//  Created by developer on 20/03/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger,MessageOwner) {
   ownerSelf = 0,
   ownerOther
};

typedef NS_ENUM(NSUInteger,MessageStatus) {
    sendingMessage = 0,
    sentMessage,
    readMessage

};

@interface Message : NSObject

+ (instancetype)messageWithString:(NSString *)message image:(UIImage *)image date:(NSString *)date status:(MessageStatus)status owner:(MessageOwner)messOwner andAttacmentImage:(UIImage *)attacImage attachUrl:(BOOL )attachUrl;

- (instancetype)initWithString:(NSString *)message image:(UIImage *)image date:(NSString *)date status:(MessageStatus)status owner:(MessageOwner)messOwner andAttacmentImage:(UIImage *)attacImage attachUrl:(BOOL)attachUrl;

@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *attachUrl;
@property (nonatomic, strong) UIImage *avatar;
@property (nonatomic, assign) MessageOwner messageOwner;
@property (nonatomic, assign) MessageStatus messageStatus;
@property (nonatomic, copy) NSString * messageDate;
@property (nonatomic, strong) UIImage *attachImage;
@property (nonatomic) BOOL isImage;
@end