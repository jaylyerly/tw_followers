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
#import "SBFTwitterUser.h"
#import "SBFAlertManager.h"

typedef void (^SBFTwitterRequestSuccess)(NSDictionary* returnDict);
typedef void (^SBFTwitterRequestError)(NSHTTPURLResponse *urlResponse,  NSError *error);

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


- (void)twitterRequest:(NSURL *)url
                params:(NSDictionary *)params
             onSuccess:(SBFTwitterRequestSuccess)successBlock
               onError:(SBFTwitterRequestError)errorBlock {
    
}

- (void)fetchFollowersForUser:(NSString *)username cursor:(NSString *)cursor completionBlock:(SBFTwitterFriendBlock)completionBlock {
    if ([self userHasAccessToTwitter]) {
        
        ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [self.accountStore requestAccessToAccountsWithType:twitterAccountType
                                                   options:NULL
                                                completion:^(BOOL granted, NSError *error) {
             if (granted) {
                 NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:twitterAccountType];
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/followers/list.json"];
                 NSDictionary *params = @{
                                              @"screen_name"            : username,
                                              @"skip_status"            : @"1",
                                              @"count"                  : @"50",
                                              @"include_user_entities"  : @"false",
                                              @"cursor"                 : cursor ?: @"-1",   // if cursor is nil, default to -1
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
                                  NSArray *users = returnDict[@"users"] ?: @{};
                                  NSString *cursorString = returnDict[@"next_cursor_str"];
                                  
                                  NSMutableArray *twUsers = [NSMutableArray array];
                                  for (NSDictionary *userDict in users){
                                      SBFTwitterUser *tu = [[SBFTwitterUser alloc] initWithDictionary:userDict];
                                      [twUsers addObject:tu];
                                  }
                                  completionBlock([NSArray arrayWithArray:twUsers], cursorString);
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
                              NSDictionary *headers = [urlResponse allHeaderFields];
                              NSLog(@"headers: %@", headers);
                              if (urlResponse.statusCode == 429){
                                  NSInteger reset = [(NSString *)headers[@"x-rate-limit-reset"] integerValue];
                                  NSDate *resetDate = [NSDate dateWithTimeIntervalSince1970:reset];
                                  NSLog(@"Current time is %@", [NSDate date]);
                                  NSLog(@"Rate limit reset at %@", resetDate);
                                  NSInteger minutes = floor([resetDate timeIntervalSinceNow] / 60);
                                  NSInteger seconds = ((int)[resetDate timeIntervalSinceNow]) % 60;
                                  NSLog(@"Rate limit reset in %02d:%02d ", minutes, seconds);
                                  NSString *msg = [NSString stringWithFormat:@"Rate limit reset in\n%02d:%02d minutes", minutes, seconds];
                                  NSString *title = @"Uh-oh!  Twitter API rate limit exceeded";
                                  [[SBFAlertManager sharedManager] displayAlertTitle:title message:msg];
                              }
                              
                          }
                      }
                  }];
             }
             else {
                 // Access was not granted, or an error occurred
                 NSLog(@"%@", [error localizedDescription]);
             }
         }];
    } else {
        // No access to twitter -- ie, no account
        [[SBFAlertManager sharedManager] displayAlertTitle:@"No Twitter Access"
                                                   message:@"Did you configure your Twitter accounts in the system settings?"];
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

- (void)fetchInfoForUser:(NSString *)username completionBlock:(SBFTwitterInfoBlock)completionBlock
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
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"];
                 NSDictionary *params = @{ @"screen_name" : username };
                 SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                         requestMethod:SLRequestMethodGET
                                                                   URL:url
                                                            parameters:params];
                 
                 //  Attach an account to the request
                 [request setAccount:[twitterAccounts lastObject]];
                 
                 //  Step 3:  Execute the request
                 [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                      if (responseData) {
                          if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                              NSError *jsonError;
                              NSDictionary *userData = [NSJSONSerialization JSONObjectWithData:responseData
                                                                                           options:NSJSONReadingAllowFragments
                                                                                             error:&jsonError];
                              if (userData) {
                                  SBFTwitterUser *user = [[SBFTwitterUser alloc] initWithDictionary:userData];
                                  completionBlock(user);
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


- (NSString *)defaultUsername {
    ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    ACAccount *twAccount = [[self.accountStore accountsWithAccountType:twitterAccountType] lastObject];
    NSString *name = [NSString stringWithFormat:@"@%@", twAccount.username];   // prepend the @

    return name;
}
@end

