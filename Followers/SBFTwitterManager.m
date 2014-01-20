//
//  SBFTwitterManager.m
//  Followers
//
//  Created by Jay Lyerly on 1/19/14.
//  Copyright (c) 2014 Jay Lyerly. All rights reserved.
//

#import "SBFTwitterManager.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface SBFTwitterManager ()
@property (nonatomic, strong) ACAccountStore *accountStore;
@end

@implementation SBFTwitterManager

+(SBFTwitterManager *)sharedManager {
    static SBFTwitterManager *_manager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _manager = [[SBFTwitterManager alloc] init];
    });
    
    return _manager;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        _accountStore = [[ACAccountStore alloc] init];
    }
    
    return self;
}

- (BOOL)userHasAccessToTwitter
{
    return [SLComposeViewController
            isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void)fetchFollowersForUser:(NSString *)username cursor:(NSNumber *)cursor completionBlock:(SBFTwitterFriendBlock)completionBlock {
    if ([self userHasAccessToTwitter]) {
        
        ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier: ACAccountTypeIdentifierTwitter];
        
        [self.accountStore requestAccessToAccountsWithType:twitterAccountType
                                                   options:NULL
                                                completion:^(BOOL granted, NSError *error) {
             if (granted) {
                 NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:twitterAccountType];
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/followers/list.json"];
                 NSDictionary *params = @{
                                              @"screen_name"            : username,
                                              @"skip_status"            : @"1",
                                              @"count"                  : @"1",
                                              @"include_user_entities"  : @"false",
                                              @"cursor"                 : cursor ?: @-1,   // if cursor is nil, default to -1
                                        };
                 
                 SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                         requestMethod:SLRequestMethodGET
                                                                   URL:url
                                                            parameters:params];
                 
                 //  Attach an account to the request
                 [request setAccount:[twitterAccounts lastObject]];
                 
                 [request performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse *urlResponse,  NSError *error) {
                      if (responseData) {
                          if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                              NSError *jsonError;
                              NSDictionary *returnDict =  [NSJSONSerialization JSONObjectWithData:responseData
                                                                                            options:NSJSONReadingAllowFragments
                                                                                              error:&jsonError];
                              if (returnDict) {
                                  NSDictionary *users = returnDict[@"users"] ?: @{};
                                  NSString *cursorString = returnDict[@"next_cursor_str"];
                                  completionBlock(users, cursorString);
                              }
                              else {
                                  // Our JSON deserialization went awry
                                  NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                              }
                          }
                          else {
                              // The server did not respond ... were we rate-limited?
                              NSLog(@"The response status code is %d",
                                    urlResponse.statusCode);
                          }
                      }
                  }];
             }
             else {
                 // Access was not granted, or an error occurred
                 NSLog(@"%@", [error localizedDescription]);
             }
         }];
    }
}

- (void)fetchTimelineForUser:(NSString *)username
{
    //  Step 0: Check that the user has local Twitter accounts
    if ([self userHasAccessToTwitter]) {
        
        //  Step 1:  Obtain access to the user's Twitter accounts
        ACAccountType *twitterAccountType =
        [self.accountStore accountTypeWithAccountTypeIdentifier:
         ACAccountTypeIdentifierTwitter];
        
        [self.accountStore
         requestAccessToAccountsWithType:twitterAccountType
         options:NULL
         completion:^(BOOL granted, NSError *error) {
             if (granted) {
                 //  Step 2:  Create a request
                 NSArray *twitterAccounts =
                 [self.accountStore accountsWithAccountType:twitterAccountType];
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                               @"/1.1/statuses/user_timeline.json"];
                 NSDictionary *params = @{@"screen_name" : username,
                                          @"include_rts" : @"0",
                                          @"trim_user" : @"1",
                                          @"count" : @"1"};
                 SLRequest *request =
                 [SLRequest requestForServiceType:SLServiceTypeTwitter
                                    requestMethod:SLRequestMethodGET
                                              URL:url
                                       parameters:params];
                 
                 //  Attach an account to the request
                 [request setAccount:[twitterAccounts lastObject]];
                 
                 //  Step 3:  Execute the request
                 [request performRequestWithHandler:
                  ^(NSData *responseData,
                    NSHTTPURLResponse *urlResponse,
                    NSError *error) {
                      
                      if (responseData) {
                          if (urlResponse.statusCode >= 200 &&
                              urlResponse.statusCode < 300) {
                              
                              NSError *jsonError;
                              NSDictionary *timelineData =
                              [NSJSONSerialization
                               JSONObjectWithData:responseData
                               options:NSJSONReadingAllowFragments error:&jsonError];
                              if (timelineData) {
                                  NSLog(@"Timeline Response: %@\n", timelineData);
                              }
                              else {
                                  // Our JSON deserialization went awry
                                  NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                              }
                          }
                          else {
                              // The server did not respond ... were we rate-limited?
                              NSLog(@"The response status code is %d",
                                    urlResponse.statusCode);
                          }
                      }
                  }];
             }
             else {
                 // Access was not granted, or an error occurred
                 NSLog(@"%@", [error localizedDescription]);
             }
         }];
    }
}
@end

