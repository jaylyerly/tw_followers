//
//  SBFTwitterUser.h
//  Followers
//
//  Created by Jay Lyerly on 12/4/12.
//  Copyright (c) 2012 Jay Lyerly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBFTwitterUser : NSObject

@property (readonly, strong, nonatomic) NSString* username;
@property (readonly, strong, nonatomic) NSString* name;
@property (readonly, strong, nonatomic) NSString* location;
@property (readonly, strong, nonatomic) NSString* twDescription;
@property (readonly, strong, nonatomic) NSURL* url;
@property (readonly, strong, nonatomic) NSString* lastTweet;
@property (readonly, strong, nonatomic) NSURL* lastTweetURL;
@property (readonly, strong, nonatomic) UIImage* avatar;
@property (readonly) NSUInteger followers_count;
@property (readonly) NSUInteger status_count;
@property (readwrite) NSUInteger listIndex;

-(id) initWithDictionary:(NSDictionary*)userDict;

@end
