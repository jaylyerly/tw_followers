//
//  SBFTwitterUserTests.m
//  Followers
//
//  Created by Jay Lyerly on 1/18/14.
//  Copyright (c) 2014 Jay Lyerly. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SBFTwitterUser.h"

@interface SBFTwitterUserTests : XCTestCase
@end

@implementation SBFTwitterUserTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testTwitterUser
{
    NSString *screenName                = @"Super";
    NSString *name                      = @"Clark Kent";
    NSString *location                  = @"Metropolis";
    NSString *description               = @"Just another working stiff";
    NSString *profile_image_url         = @"http://upload.wikimedia.org/wikipedia/en/7/72/Superman.jpg";
    NSString *url                       = @"http://en.wikipedia.org/wiki/Daily_Planet";
    NSString *follwers_count            = @"1933";
    NSString *statuses_count            = @"20114";
    NSString *st_text                   = @"Just making another phone call.";
    NSString *st_id                     = @"1234";
    NSString *st_in_reply_to_status_id  = @"1233";
    
    NSDictionary *twDict = @{
                             @"screen_name":        screenName,
                             @"name":               name,
                             @"location":           location,
                             @"description":        description,
                             @"profile_image_url":  profile_image_url,
                             @"url":                url,
                             @"followers_count":    follwers_count,
                             @"statuses_count":     statuses_count,
                             @"status":@{
                                            @"text":                    st_text,
                                            @"id":                      st_id,
                                            @"in_reply_to_status_id":   st_in_reply_to_status_id,
                                        },
                             };
    SBFTwitterUser *user = [[SBFTwitterUser alloc] initWithDictionary:twDict];
    
    XCTAssertTrue([user.username           isEqualToString:screenName]);
    XCTAssertTrue([user.name               isEqualToString:name]);
    XCTAssertTrue([user.location           isEqualToString:location]);
    XCTAssertTrue([user.twDescription      isEqualToString:description]);
    XCTAssertTrue([user.lastTweet          isEqualToString:st_text ]);
    XCTAssertTrue([user.url.absoluteString isEqualToString:url]);

    XCTAssertTrue(user.followers_count == [follwers_count integerValue]);
    XCTAssertTrue(user.status_count    == [statuses_count integerValue] );
}

- (void)testCompareName{
    SBFTwitterUser *bats = [[SBFTwitterUser alloc] initWithDictionary:@{@"screen_name":@"Batman",   @"name":@"Bruce Wayne"}];
    SBFTwitterUser *sups = [[SBFTwitterUser alloc] initWithDictionary:@{@"screen_name":@"Superman", @"name":@"Clark Kent" }];
    
    XCTAssertTrue([bats compareUserName:sups] == NSOrderedAscending);
    XCTAssertTrue([sups compareUserName:sups] == NSOrderedSame);
    XCTAssertTrue([sups compareUserName:bats] == NSOrderedDescending);
}

- (void)testCompareUser{
    SBFTwitterUser *bats = [[SBFTwitterUser alloc] initWithDictionary:@{@"screen_name":@"Batman",   @"name":@"Bruce Wayne"}];
    SBFTwitterUser *sups = [[SBFTwitterUser alloc] initWithDictionary:@{@"screen_name":@"Superman", @"name":@"Clark Kent" }];
    
    XCTAssertTrue([bats compareName:sups] == NSOrderedAscending);
    XCTAssertTrue([sups compareName:sups] == NSOrderedSame);
    XCTAssertTrue([sups compareName:bats] == NSOrderedDescending);
}

@end
