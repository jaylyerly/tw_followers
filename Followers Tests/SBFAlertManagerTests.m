//
//  SBFAlertManagerTests.m
//  Followers
//
//  Created by Jay Lyerly on 2/1/14.
//  Copyright (c) 2014 Jay Lyerly. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "SBFAlertManager.h"

static const NSTimeInterval SBFAlertManagerTestTimeLimit = 5;

@interface SBFAlertManager (PrivateTesting)
@property (nonatomic, assign) BOOL isShowing;
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;
@end

@interface SBFAlertManagerTests : XCTestCase
@property (nonatomic, strong) SBFAlertManager* alertMgr;
@end

@implementation SBFAlertManagerTests

- (void)setUp
{
    [super setUp];
    self.alertMgr = [OCMockObject partialMockForObject:[[SBFAlertManager alloc] init]];
}

- (void)tearDown
{
    self.alertMgr = nil;
    [super tearDown];
}

- (void)testShared
{
    XCTAssertNil([SBFAlertManager sharedManager], @"sharedManager should be nil in unit test mode");
}

- (void)testShowing{
    __block BOOL testComplete = NO;

    self.alertMgr.isShowing = YES;

    id mockAlertView = [OCMockObject mockForClass:[UIAlertView class]];
    [[mockAlertView reject] show];
    
    BOOL didDisplay = [self.alertMgr displayAlertTitle:@"foo"
                                               message:@"bar"
                                       completionBlock:^(BOOL didShow){ testComplete = YES; }];

    NSDate *start = [NSDate date];
    while (!testComplete && ( [[NSDate date] timeIntervalSinceDate:start] < SBFAlertManagerTestTimeLimit )) {
        // This executes another run loop.
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        // Sleep 1/100th sec
        usleep(10000);
    }
    
    // should call 'show'
    [mockAlertView verify];
    XCTAssertFalse(didDisplay);
    XCTAssert(testComplete, @"Failed to execute completion block.");
}

- (void)testNotShowing{
    __block BOOL testComplete = NO;

    self.alertMgr.isShowing = NO;
    id mockAlertView = [OCMockObject mockForClass:[UIAlertView class]];
    [[[mockAlertView expect] andReturn:mockAlertView] alloc];
    (void)[[[mockAlertView expect] andReturn:mockAlertView] initWithTitle:[OCMArg any]
                                                                  message:[OCMArg any]
                                                                 delegate:[OCMArg isNotNil]
                                                        cancelButtonTitle:[OCMArg any]
                                                        otherButtonTitles:[OCMArg isNil], nil];
    [[mockAlertView expect] show];
    
    BOOL didDisplay = [self.alertMgr displayAlertTitle:@"foo"
                                               message:@"bar"
                                       completionBlock:^(BOOL didShow){ testComplete = YES; }];
    
    NSDate *start = [NSDate date];
    while (!testComplete && ( [[NSDate date] timeIntervalSinceDate:start] < SBFAlertManagerTestTimeLimit )) {
        // This executes another run loop.
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        // Sleep 1/100th sec
        usleep(10000);
    }
    
    // should call 'show'
    [mockAlertView verify];
    XCTAssert(didDisplay);
    XCTAssert(testComplete, @"Failed to execute completion block.");
}

- (void)testDismiss{
    self.alertMgr.isShowing = YES;
    [self.alertMgr alertView:nil didDismissWithButtonIndex:0];
    XCTAssertFalse(self.alertMgr.isShowing, @"isShowing should be false after calling dismiss method on delegate");
    
}

@end
