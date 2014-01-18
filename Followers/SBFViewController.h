//
//  SBFViewController.h
//  Followers
//
//  Created by Jay Lyerly on 12/3/12.
//  Copyright (c) 2012 Jay Lyerly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBFViewController : UIViewController

@property (nonatomic) BOOL jumpToFollowers;

- (void) addTask:(void(^)(NSDictionary* userDict))taskBlock forID:(NSString*)connectionID;

@end
