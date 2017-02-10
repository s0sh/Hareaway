//
//  SocialsManager.m
//  Scadaddle
//
//  Created by Roman Bigun on 3/30/15.
//  Copyright (c) 2015 Roman Bigun. All rights reserved.
//

/*!
 * @discussion THIS CLASS IS NOT USED AT THIS MOMENT
 * @see .h file for methods description
 */

#import "SocialsManager.h"

@implementation SocialsManager


@synthesize socials = _socials;
-(id)init{
    //NOTE: Use this init method if you want to use your class as a delegate (one entity only)
    self = [super init];
    return self;
}
-(void)youtubeVideoLinksForTerm:(NSString*)term{
    YoutubeHelper *yth = [[YoutubeHelper alloc] init];
    [yth searchYoutubeVideosForTerm:term];
}
-(void)initSocials{
    //Взять из базы все социальные сети, их данные настройки
   _socials = [[NSArray alloc] initWithArray:[Core getSocials]];//Could be a bug here (nil olbject could come)

}

/////////////FACEBOOK////////////////
-(NSString *)fbAccessToken;{
    return [[FBHelper sharedInstance] FBuserToken];
}
-(BOOL)facebookLoginInsertToView:(UIViewController*)target{
    if([[FBHelper sharedInstance] FBLogin:target]){
        return YES;
    }
    return NO;
}
-(NSArray *)fbUserInterests{
   return [FBHelper currentUserInterests];
}
-(NSArray *)fbUserActivities{
    return [FBHelper getUserActivities];
}
-(NSArray *)fbUserAlbums{
    return [FBHelper getUserAlbums];
}
-(NSArray *)fbUserInterestWithID:(NSString*)iId{
    return [FBHelper getUserInterestWithId:iId];
}
-(NSArray *)fbUserImagesWithId:(NSString*)pId{
    return [FBHelper getUserPhotosInAlbumsWithId:pId];
}
-(NSArray *)fbUserFriends{
    return [FBHelper currentUserFriends];
}
-(NSArray *)fbUserNotifications{
    return [FBHelper getNotifications];
}
//////////////INSTAGRAM//////////////
-(void)instagramLogin{
    InstagHelper *ih = [[InstagHelper alloc] init];
    [ih instagramLogin];
}
-(NSString *)fbLoggedInUserID{
    return [[FBHelper sharedInstance] loggedInUserFBId];
}
-(NSString *)avatarUrlWithID:(NSString *)fbUserID{
   return [[FBHelper sharedInstance] getAvatarURLWithID:fbUserID];
}
-(NSArray *)instagramPosts{
    InstagHelper *ih = [[InstagHelper alloc] init];
    return [ih getInstagramPosts];
}
//////////////G+//////////////
-(void)googlePlusButton:(UIViewController *)vk{
    GPlusHelper *gPlus = [[GPlusHelper alloc] init];
    [gPlus GooglePlusButton:vk];
}
-(void)gPlusLogin{
    GPlusHelper *gPlus = [[GPlusHelper alloc] init];
    [gPlus googlePlusLogin];

}
//Twitter button
-(void)twitterButton:(UIViewController *)vk{
    [TWHelper insertTwitterLoginButtonIntoViewController:vk];
}

// COMMON HELPER
-(Socials *)socialWithType:(int)type
{

//    if(!_socials){
//        [self initSocials];
//    }
//    int i = 0;
//    for(Socials *s in _socials){
//        NSDictionary *d = [Core getSocialForId:i];
//        NSLog(@"Social : %@\n",[Core getSocialForId:i]);
//        if([[NSString stringWithFormat:@"%@",d [@"type"]] intValue]== type){
//            return s;
//        }
//        i++;
//    }
    
    return nil;

}
-(NSDictionary*)getSocialWithType:(int)type
{

//    if(!_socials){
//        [self initSocials];
//    }
//    NSDictionary *res = [NSDictionary dictionary];
//    for(int i = 0;i< _socials.count; i++){
//        res = [Core getSocialForId:i];
//        NSLog(@"Social : %@\n",[Core getSocialForId:i]);
//        if([[NSString stringWithFormat:@"%@",res [@"type"]] intValue]== type){
//            return res;
//        }
//    }
//    
//    return res;

    return nil;
}
@end
