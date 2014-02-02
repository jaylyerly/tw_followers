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

@interface SBFTwitterManager (TestingPrivates)
@property (nonatomic, strong)   ACAccountStore *accountStore;
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
    self.twMgr = [[SBFTwitterManager alloc] init];

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
