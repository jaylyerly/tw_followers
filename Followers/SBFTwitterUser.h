//
//  SBFTwitterUser.h
//  Followers
//
//  Created by Jay Lyerly on 12/4/12.
//  Copyright (c) 2012 Jay Lyerly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBFTwitterUser : NSObject

@property (readonly, copy,   nonatomic) NSString* username;
@property (readonly, copy,   nonatomic) NSString* name;
@property (readonly, copy,   nonatomic) NSString* location;
@property (readonly, copy,   nonatomic) NSString* twDescription;
@property (readonly, copy,   nonatomic) NSString* lastTweet;
@property (readonly, strong, nonatomic) NSURL* url;
@property (readonly, strong, nonatomic) NSURL* lastTweetURL;
@property (readonly, strong, nonatomic) UIImage* avatar;
@property (readonly) NSUInteger followers_count;
@property (readonly) NSUInteger status_count;

- (instancetype) initWithDictionary:(NSDictionary*)userDict;
- (NSComparisonResult)compareUserName:(SBFTwitterUser *)otherUser;
- (NSComparisonResult)compareName:(SBFTwitterUser *)otherUser;

@end
