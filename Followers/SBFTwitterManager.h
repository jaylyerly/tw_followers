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
typedef void (^SBFTwitterTimelineBlock)(NSDictionary* dict);

@interface SBFTwitterManager : NSObject

@property (nonatomic, readonly) NSString* defaultUsername;

+ (SBFTwitterManager *)sharedManager;
- (void)fetchTimelineForUser:(NSString *)username completionBlock:(SBFTwitterTimelineBlock)block;
- (void)fetchFollowersForUser:(NSString *)username cursor:(NSString *)cursor completionBlock:(SBFTwitterFriendBlock)block;
- (void)fetchInfoForUser:(NSString *)username completionBlock:(SBFTwitterInfoBlock)block;


@end
