//
//  SBFUserInfoViewController.h
//  Followers
//
//  Created by Jay Lyerly on 12/5/12.
//  Copyright (c) 2012 Jay Lyerly. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SBFTwitterUser;

@interface SBFUserInfoViewController : UITableViewController

-(void) setupWithUser:(SBFTwitterUser*)user;

@end
