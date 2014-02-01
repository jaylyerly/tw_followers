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

static const NSString *twitterEndpoint = @"https://api.twitter.com/1.1";

typedef void (^SBFTwitterRequestSuccess)(NSDictionary* returnDict);
typedef void (^SBFTwitterRequestError)(NSHTTPURLResponse *urlResponse,  NSError *error);

@interface SBFTwitterManager ()
@property (nonatomic, strong)   ACAccountStore *accountStore;
@property (nonatomic, readonly) ACAccount      *twitterAccount;
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
    if ([self userHasAccessToTwitter]) {
        
        ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [self.accountStore requestAccessToAccountsWithType:twitterAccountType
                                                   options:NULL
                                                completion:^(BOOL granted, NSError *error) {

                                                    
            if (granted) {                
                SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                        requestMethod:SLRequestMethodGET
                                                                  URL:url
                                                           parameters:params];
                
                //  Attach an account to the request
                [request setAccount:self.twitterAccount];
                
                [request performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse *urlResponse,  NSError *error) {
                    if (responseData) {
                        if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                            NSError *jsonError;
                            NSDictionary *returnDict =  [NSJSONSerialization JSONObjectWithData:responseData
                                                                                        options:NSJSONReadingAllowFragments
                                                                                          error:&jsonError];
                            if (returnDict) {
                                successBlock(returnDict);
                            }
                            else {
                                // Our JSON deserialization went awry
                                NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                            }
                        }
                        else {
                            if (errorBlock){
                                errorBlock(urlResponse, error);
                            } else {
                                // The server did not respond ... were we rate-limited?
                                [self handleRateLimit:urlResponse];
                            }
                        }
                    }
                }];
            } else {
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

- (void) handleRateLimit:(NSHTTPURLResponse *)urlResponse{
    NSLog(@"The response status code is %d", urlResponse.statusCode);
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

- (NSURL *)urlForPath:(NSString *)path {
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", twitterEndpoint, path];
    return [NSURL URLWithString:urlString];
}

- (void)fetchFollowersForUser:(NSString *)username cursor:(NSString *)cursor completionBlock:(SBFTwitterFriendBlock)completionBlock {
    //NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/followers/list.json"];
    NSURL *url = [self urlForPath:@"followers/list.json"];
    
    NSDictionary *params = @{
                             @"screen_name"            : username,
                             @"skip_status"            : @"1",
                             @"count"                  : @"50",
                             @"include_user_entities"  : @"false",
                             @"cursor"                 : cursor ?: @"-1",   // if cursor is nil, default to -1
                             };

    SBFTwitterRequestSuccess successBlock = ^(NSDictionary* returnDict) {
        
        NSArray *users = returnDict[@"users"] ?: @{};
        NSString *cursorString = returnDict[@"next_cursor_str"];
        
        NSMutableArray *twUsers = [NSMutableArray array];
        for (NSDictionary *userDict in users){
            SBFTwitterUser *tu = [[SBFTwitterUser alloc] initWithDictionary:userDict];
            [twUsers addObject:tu];
        }
        completionBlock([NSArray arrayWithArray:twUsers], cursorString);
        
    };

    [self twitterRequest:url params:params onSuccess:successBlock onError:nil];
    
}


- (void)fetchTimelineForUser:(NSString *)username {
    NSURL *url = [self urlForPath:@"statuses/user_timeline.json"];
    
    NSDictionary *params = @{
                             @"screen_name" : username,
                             @"include_rts" : @"0",
                             @"trim_user"   : @"1",
                             @"count"       : @"1",
                             };
    
    SBFTwitterRequestSuccess successBlock = ^(NSDictionary* returnDict) {
        NSLog(@"Timeline Response: %@\n", returnDict);
    };
    
    [self twitterRequest:url params:params onSuccess:successBlock onError:nil];
    
}

- (void)fetchInfoForUser:(NSString *)username completionBlock:(SBFTwitterInfoBlock)completionBlock {
    NSURL *url = [self urlForPath:@"users/show.json"];
    
    NSDictionary *params = @{ @"screen_name" : username };
    
    SBFTwitterRequestSuccess successBlock = ^(NSDictionary* returnDict) {
        SBFTwitterUser *user = [[SBFTwitterUser alloc] initWithDictionary:returnDict];
        completionBlock(user);
    };
    
    [self twitterRequest:url params:params onSuccess:successBlock onError:nil];
    
}

- (ACAccount *)twitterAccount{
    ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    ACAccount *twAccount = [[self.accountStore accountsWithAccountType:twitterAccountType] lastObject];
    return twAccount;
}

- (NSString *)defaultUsername {
    return self.twitterAccount.username;
}
@end

