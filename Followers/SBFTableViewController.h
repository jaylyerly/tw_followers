//
//  SBFTableViewController.h
//  Followers
//
//  Created by Jay Lyerly on 12/4/12.
//  Copyright (c) 2012 Jay Lyerly. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SBFViewController;

@interface SBFTableViewController : UITableViewController

@property (strong, nonatomic) NSString *username;
//@property (strong, nonatomic) SBFViewController *rootViewController;
@property (nonatomic) NSUInteger stackLevel;

@end
