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

- (BOOL) displayAlertTitle:(NSString *)title message:(NSString *)msg{
    if (self.isShowing){
        return NO;
    } else {
        self.isShowing = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:title
                                        message:msg
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        });
        return YES;
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    self.isShowing = NO;
}

@end
