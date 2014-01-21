//
//  SBFAlertManager.h
//  Followers
//
//  Created by Jay Lyerly on 1/20/14.
//  Copyright (c) 2014 Jay Lyerly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBFAlertManager : NSObject

+ (SBFAlertManager *)sharedManager;
- (BOOL) displayAlertTitle:(NSString *)title message:(NSString *)msg;

@end
