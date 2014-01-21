//
//  SBFTwitterManager.h
//  Followers
//
//  Created by Jay Lyerly on 1/19/14.
//  Copyright (c) 2014 Jay Lyerly. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SBFTwitterUser;

typedef void (^SBFTwitterFriendBlock)(NSArray *friends, NSString *next_cursor);
typedef void (^SBFTwitterInfoBlock)(SBFTwitterUser* user);

@interface SBFTwitterManager : NSObject

@property (nonatomic, readonly) NSString* defaultUsername;
@property (nonatomic, readonly) NSString* defaultName;

+ (SBFTwitterManager *)sharedManager;
//- (BOOL)userHasAccessToTwitter;
- (void)fetchTimelineForUser:(NSString *)username;
- (void)fetchFollowersForUser:(NSString *)username cursor:(NSString *)cursor completionBlock:(SBFTwitterFriendBlock)block;
- (void)fetchInfoForUser:(NSString *)username completionBlock:(SBFTwitterInfoBlock)block;


@end
