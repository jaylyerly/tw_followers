//
//  SBFTwitterUser.m
//  Followers
//
//  Created by Jay Lyerly on 12/4/12.
//  Copyright (c) 2012 Jay Lyerly. All rights reserved.
//

#import "SBFTwitterUser.h"
#import <CoreGraphics/CoreGraphics.h>

NSString * const SBFTwitterUserDidUpdateAvatarNotification = @"SBFTwitterUserDidUpdateAvatarNotification";

@interface SBFTwitterUser () <NSURLConnectionDataDelegate>

@property (readwrite, copy,   nonatomic) NSString* username;
@property (readwrite, copy,   nonatomic) NSString* name;
@property (readwrite, copy,   nonatomic) NSString* location;
@property (readwrite, copy,   nonatomic) NSString* twDescription;
@property (readwrite, copy,   nonatomic) NSString* lastTweet;
@property (readwrite, strong, nonatomic) NSURL* url;
@property (readwrite, strong, nonatomic) NSURL* lastTweetURL;
@property (readwrite, strong, nonatomic) UIImage* avatar;
@property (readwrite, strong, nonatomic) NSURL* avatarUrl;
@property (readwrite) NSUInteger followers_count;
@property (readwrite) NSUInteger status_count;
@property (readwrite, strong, nonatomic) NSMutableData* tmpImgData;

@end

static NSOperationQueue* _queue = nil;       // make a single queue for the whole class

@implementation SBFTwitterUser

-(instancetype) initWithDictionary:(NSDictionary*)userDict
{
    self = [super init];
    if (self) {
        _username = userDict[@"screen_name"];
        _name = userDict[@"name"];
        _location = userDict[@"location"];
        _twDescription = userDict[@"description"];
        _avatar = nil;
        _avatarUrl = [NSURL URLWithString:userDict[@"profile_image_url"]];
        NSString *url = userDict[@"url"];
        if (url && ![url isEqual:[NSNull null]]){
            _url = [NSURL URLWithString:userDict[@"url"]];
        }
        _followers_count = [(NSString*)userDict[@"followers_count"] integerValue];
        _status_count = [(NSString*)userDict[@"statuses_count"] integerValue];
        
        _lastTweet = userDict[@"status"][@"text"];
        // clean up the tweet; a little ghetto, but it gets it done.
        _lastTweet = [_lastTweet stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        _lastTweet = [_lastTweet stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
        _lastTweet = [_lastTweet stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
        
        NSString* lastID = userDict[@"status"][@"id"];
        _lastTweetURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://twitter.com/%@/status/%@", _username, lastID]];
        
        _tmpImgData = nil;
        NSURLRequest *request = [NSURLRequest requestWithURL:_avatarUrl];
        
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[SBFTwitterUser sharedQueue]
                               completionHandler:^(NSURLResponse* resp, NSData* data, NSError* err){
                                   if (data){
                                       [self addAvatarWithRoundedCorners:[UIImage imageWithData:data]];
                                   }
                               }];
    }
    return self;
}

- (void)addAvatarWithRoundedCorners:(UIImage *)newAvatar
{
    CGRect _bounds =  CGRectMake(0, 0, newAvatar.size.width, newAvatar.size.height);
    
    // Create a path
    CGRect insetRect = CGRectInset(_bounds, 0, 0);
    CGRect offsetRect = insetRect; offsetRect.origin = CGPointZero;
    UIGraphicsBeginImageContext(insetRect.size);
    
    CGContextRef imgContext = UIGraphicsGetCurrentContext();
    if (imgContext){
        CGPathRef clippingPath = [UIBezierPath bezierPathWithRoundedRect:offsetRect cornerRadius:10.0].CGPath;
        CGContextAddPath(imgContext, clippingPath);
        CGContextClip(imgContext);
        // Draw the image
        [newAvatar drawInRect:offsetRect];
        // Get the image
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.avatar = img;
    }else{
        // sometimes during a transition, UIGraphicsGetCurrentContext() fails
        self.avatar = newAvatar;        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:SBFTwitterUserDidUpdateAvatarNotification object:self];
}



+ (NSOperationQueue*)sharedQueue
{
    if (_queue == nil){
        _queue = [[NSOperationQueue alloc] init];
        [_queue setMaxConcurrentOperationCount:4];
    }
    return _queue;
}

// Some comparators so an array can be sorted alphabetically
- (NSComparisonResult)compareUserName:(SBFTwitterUser *)otherUser {
    return [self.username compare:otherUser.username options:NSCaseInsensitiveSearch];
}

- (NSComparisonResult)compareName:(SBFTwitterUser *)otherUser {
    return [self.name compare:otherUser.name options:NSCaseInsensitiveSearch];
}

// Make sure we can print out something useful if we get stringified
- (NSString*)description
{
    return [NSString stringWithFormat:@"SBFTwitterUser<%@>", self.username];
}

@end
