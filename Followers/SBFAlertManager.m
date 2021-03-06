//
//  SBFAlertManager.m
//  Followers
//
//  Created by Jay Lyerly on 1/20/14.
//  Copyright (c) 2014 Jay Lyerly. All rights reserved.
//

#import "SBFAlertManager.h"

@interface SBFAlertManager () <UIAlertViewDelegate>

@property (nonatomic, assign) BOOL isShowing;

@end

@implementation SBFAlertManager

+(SBFAlertManager *)sharedManager {
    // Don't show blocking alerts in Unit Test Mode
    if ([[[NSProcessInfo processInfo] environment] objectForKey:@"SBFUnitTestMode"]){
        return nil;
    }

    static SBFAlertManager *_manager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _manager = [[SBFAlertManager alloc] init];
    });
    
    return _manager;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        _isShowing = NO;
    }
    
    return self;
}

- (BOOL) displayAlertTitle:(NSString *)title message:(NSString *)msg completionBlock:(SBFAlertManagerCompletionBlock)block{
    if (self.isShowing){
        if (block) {
            block(NO);
        }
        return NO;
    } else {
        self.isShowing = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:title
                                        message:msg
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            if (block){
                block(YES);
            }
        });
        return YES;
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    self.isShowing = NO;
}

@end
