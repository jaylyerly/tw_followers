//
//  SBFTwitterManagerTests.m
//  Followers
//
//  Created by Jay Lyerly on 2/1/14.
//  Copyright (c) 2014 Jay Lyerly. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <Accounts/Accounts.h>
#import "SBFTwitterManager.h"
#import "SBFTwitterUser.h"
#import "Mocktail.h"

static const NSTimeInterval SBFTwitterManagerTestTimeLimit = 5;

@interface SBFTwitterManager (TestingPrivates)
@property (nonatomic, strong)   ACAccountStore *accountStore;
- (BOOL)userHasAccessToTwitter;
@end

@interface SBFTwitterManagerTests : XCTestCase
@property (strong, nonatomic) SBFTwitterManager *twMgr;
@property (nonatomic, strong) Mocktail          *mocktail;
@property (nonatomic, strong) NSBundle          *resourceBundle;

@end

@implementation SBFTwitterManagerTests

- (void)setUp
{
    [super setUp];
    // Mock twitter manager to always have access to Twitter 
    id mockTwMgr = [OCMockObject partialMockForObject:[[SBFTwitterManager alloc]init]];
    [[[mockTwMgr stub] andReturnValue:@YES] userHasAccessToTwitter];
    self.twMgr = mockTwMgr;
    
    // Enable Mocktail to provide faux twitter response from file
    self.resourceBundle = [NSBundle bundleForClass:[self class]];
    NSURL *mockDir = [self.resourceBundle bundleURL];
    self.mocktail = [Mocktail startWithContentsOfDirectoryAtURL:mockDir];
    
    // Fake an account store that always grants access to accounts
    id mockAccountStore = [OCMockObject niceMockForClass:[ACAccountStore class]];
    self.twMgr.accountStore = mockAccountStore;
    [[[mockAccountStore stub] andCall:@selector(requestAccessToAccountsWithType:options:completion:) onObject:self]
                                     requestAccessToAccountsWithType:[OCMArg any]
                                     options:[OCMArg any]
                                     completion:[OCMArg any]
     ];

}

- (void) requestAccessToAccountsWithType:(ACAccountType*)type
                                 options:(NSDictionary *)dict
                              completion:(ACAccountStoreRequestAccessCompletionHandler)completion {
    // just execute the completion block with access granted and no error
    completion(YES,nil);    
}

- (void)tearDown
{
    self.twMgr.accountStore = nil;
    self.twMgr = nil;
    self.resourceBundle = nil;
    [self.mocktail stop];
    self.mocktail = nil;
    [super tearDown];
}

- (void)waitFor:(BOOL *)aBool {
    NSDate *start = [NSDate date];
    while (!*aBool && ( [[NSDate date] timeIntervalSinceDate:start] < SBFTwitterManagerTestTimeLimit )) {
        // This executes another run loop.
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        // Sleep 1/100th sec
        usleep(10000);
    }
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
    
    [self waitFor:&testComplete];

    XCTAssertTrue(testComplete, @"Completion block did not execute");;
    
}

- (void)testFollowers {
    
    __block BOOL testComplete = NO;

    [self.twMgr fetchFollowersForUser:@"jaylyerly" cursor:@"-1" completionBlock:^(NSArray *friends, NSString *next_cursor)
    {
        XCTAssert([friends count] == 87);
        testComplete = YES;
    }];
    
    [self waitFor:&testComplete];

    XCTAssertTrue(testComplete, @"Completion block did not execute");;
}

- (void)testTimeline {
    __block BOOL testComplete = NO;
    
    [self.twMgr fetchTimelineForUser:@"jaylyerly" completionBlock:^(NSDictionary *dict)
     {
         XCTAssertNotNil(dict, @"Timeline dictionary is nil");
         testComplete = YES;
     }];
    
    [self waitFor:&testComplete];
    
    XCTAssertTrue(testComplete, @"Completion block did not execute");;
    
}

- (void)testShared
{
    XCTAssertNil([SBFTwitterManager sharedManager], @"sharedManager should be nil in unit test mode");
}


@end
