//
//  SBFTwitterManager.h
//  Followers
//
//  Created by Jay Lyerly on 1/19/14.
//  Copyright (c) 2014 Jay Lyerly. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^SBFTwitterFriendBlock)(NSDictionary *friends, NSString *next_cursor);

@interface SBFTwitterManager : NSObject

+ (SBFTwitterManager *)sharedManager;
//- (BOOL)userHasAccessToTwitter;
- (void)fetchTimelineForUser:(NSString *)username;
- (void)fetchFollowersForUser:(NSString *)username cursor:(NSNumber *)cursor completionBlock:(SBFTwitterFriendBlock)block;


@end
