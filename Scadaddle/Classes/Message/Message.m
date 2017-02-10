//
//  Message.m
//  Fishy
//
//  Created by developer on 20/03/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//


#import "Message.h"

@implementation Message


+ (instancetype)messageWithString:(NSString *)message image:(UIImage *)image date:(NSString *)date status:(MessageStatus)status owner:(MessageOwner)messOwner andAttacmentImage:(UIImage *)attacImage attachUrl:(BOOL)attachUrl{
    
   return [[Message alloc] initWithString:message image:image date:date status:status owner:messOwner andAttacmentImage:(UIImage *)attacImage attachUrl:attachUrl];
}

- (instancetype)initWithString:(NSString *)message image:(UIImage *)image date:(NSString *)date status:(MessageStatus)status owner:(MessageOwner)messOwner andAttacmentImage:(UIImage *)attacImage attachUrl:(BOOL )attachUrl
{
    self = [super init];
    if(self)
    {
        _message = message;
        _avatar = image;
        _messageOwner = messOwner;
        _messageDate = date;
        _messageStatus = status;
        _attachImage = attacImage;
        _isImage = attachUrl;
    }
    return self;
}


@end
