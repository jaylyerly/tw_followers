//
//  SBFTwitterManagerTests.m
//  Followers
//
//  Created by Jay Lyerly on 2/1/14.
//  Copyright (c) 2014 Jay Lyerly. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SBFTwitterManager.h"
#import "SBFTwitterUser.h"
#import "Mocktail.h"

@interface SBFTwitterManagerTests : XCTestCase
@property (strong, nonatomic) SBFTwitterManager *twMgr;
@property (nonatomic, strong) Mocktail          *mocktail;
@property (nonatomic, strong) NSBundle          *resourceBundle;

@end

@implementation SBFTwitterManagerTests

- (void)setUp
{
    [super setUp];
    self.twMgr = [[SBFTwitterManager alloc] init];
    
    self.resourceBundle = [NSBundle bundleForClass:[self class]];
    NSURL *mockDir = [self.resourceBundle bundleURL];
    self.mocktail = [Mocktail startWithContentsOfDirectoryAtURL:mockDir];
    
}

- (void)tearDown
{
    self.twMgr = nil;
    self.resourceBundle = nil;
    [self.mocktail stop];
    self.mocktail = nil;
    [super tearDown];
}

- (void)testUserInfo
{
    __block BOOL testComplete = NO;

    NSString *screenName                = @"jaylyerly";
    NSString *name                      = @"Jay Lyerly";
    NSString *location                  = @"St. Somewhere";
    NSString *description               = @"Mac/iOS developer, bunny slave, car geek, reformed astrophysicist, practicing parrothead.";
    NSString *url                       = @"http://t.co/vHSW6S3Fkp";
    NSString *follwers_count            = @"87";
    NSString *statuses_count            = @"1033";
    NSString *st_text                   = @"Cottleston, Cottleston, Cottleston Pie\nA fish can't whistle & neither can I\nAsk me a riddle & I reply\nCottleston, Cottleston, Cottleston Pie";
    
    
    [self.twMgr fetchInfoForUser:@"jaylyerly" completionBlock:^(SBFTwitterUser *user){
        XCTAssertTrue([user.username           isEqualToString:screenName]);
        XCTAssertTrue([user.name               isEqualToString:name]);
        XCTAssertTrue([user.location           isEqualToString:location]);
        XCTAssertTrue([user.twDescription      isEqualToString:description]);
        XCTAssertTrue([user.lastTweet          isEqualToString:st_text ]);
        XCTAssertTrue([user.url.absoluteString isEqualToString:url]);
        
        XCTAssertTrue(user.followers_count == [follwers_count integerValue]);
        XCTAssertTrue(user.status_count    == [statuses_count integerValue] );
        testComplete = YES;
    }];
    
    // Give the async call 5 second to return
    NSDate *start = [NSDate date];
    while (!testComplete && ( [[NSDate date] timeIntervalSinceDate:start] < 5 )) {
        // This executes another run loop.
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        // Sleep 1/100th sec
        usleep(10000);
    }
    XCTAssertTrue(testComplete, @"TRcompletion block did not execute");;
    
}

@end
