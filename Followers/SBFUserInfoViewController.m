//
//  SBFUserInfoViewController.m
//  Followers
//
//  Created by Jay Lyerly on 12/5/12.
//  Copyright (c) 2012 Jay Lyerly. All rights reserved.
//

#import "SBFUserInfoViewController.h"

#import "SBFTwitterUser.h"

static const NSUInteger kSBFUserInfoCellHeightSmall  = 44;
static const NSUInteger kSBFUserInfoCellHeightMedium = 60;
static const NSUInteger kSBFUserInfoCellHeightLarge  = 88;

static const NSUInteger kSBFUserInfoSectionUserInfo   = 0;
static const NSUInteger kSBFUserInfoSectionTweet      = 1;
static const NSUInteger kSBFUserInfoSectionDetailInfo = 2;

static const NSUInteger kSBFUserInfoSectionUserInfoAvatar        = 0;
static const NSUInteger kSBFUserInfoSectionUserInfoDescription   = 1;

static const NSUInteger kSBFUserInfoSectionTweetText      = 0;
static const NSUInteger kSBFUserInfoSectionTweetLink      = 1;

static const NSUInteger kSBFUserInfoSectionDetailInfoLocation  = 0;
static const NSUInteger kSBFUserInfoSectionDetailInfoLink      = 1;
static const NSUInteger kSBFUserInfoSectionDetailInfoFollowers = 2;
static const NSUInteger kSBFUserInfoSectionDetailInfoTweets    = 3;


@interface SBFUserInfoViewController ()

@property (strong, nonatomic) SBFTwitterUser* twUser;

@end

@implementation SBFUserInfoViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setupWithUser:(SBFTwitterUser*)user;
{
    self.twUser = user;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case kSBFUserInfoSectionUserInfo:
            return 2;
        case kSBFUserInfoSectionTweet:
            return 2;
        case kSBFUserInfoSectionDetailInfo:
            return 4;
        default:
            return 0;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case kSBFUserInfoSectionUserInfo:
            return @"";
        case kSBFUserInfoSectionTweet:
            return @"Latest Tweet";
        case kSBFUserInfoSectionDetailInfo:
            return @"User Details"  ;
        default:
            return @"";
    }
    
    return @"";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    UITableViewCell *cell = nil;
    UITextView *tv = nil;
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    switch (section) {
        case kSBFUserInfoSectionUserInfo:
            if (row == kSBFUserInfoSectionUserInfoAvatar){
                cell = [tableView dequeueReusableCellWithIdentifier:@"UserInfo" forIndexPath:indexPath];
                cell.textLabel.text = self.twUser.name;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"@%@", self.twUser.username];
                cell.imageView.image = self.twUser.avatar;
            }else{
                cell = [tableView dequeueReusableCellWithIdentifier:@"Tweet" forIndexPath:indexPath];
                tv = (UITextView*)[cell viewWithTag:101];
                tv.text = self.twUser.twDescription;
            }
            break;
        case kSBFUserInfoSectionTweet:
            if (row == kSBFUserInfoSectionTweetText){
                cell = [tableView dequeueReusableCellWithIdentifier:@"Tweet" forIndexPath:indexPath];
                tv = (UITextView*)[cell viewWithTag:101];
                tv.scrollEnabled = NO;  // disable scrolling, we know it's big enough for tweets
                tv.text = self.twUser.lastTweet;
            }else{
                cell = [tableView dequeueReusableCellWithIdentifier:@"TweetLink" forIndexPath:indexPath];
                cell.textLabel.text = @"Open at twitter.com";
            }
            break;
        case kSBFUserInfoSectionDetailInfo:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DetailInfo" forIndexPath:indexPath];
            switch (row) {
                case kSBFUserInfoSectionDetailInfoLocation:
                    cell.textLabel.text = @"Location";
                    cell.detailTextLabel.text = self.twUser.location;
                    break;
                case kSBFUserInfoSectionDetailInfoLink:
                    cell.textLabel.text = @"URL";
                    cell.detailTextLabel.text = self.twUser.url.description;
                    break;
                case kSBFUserInfoSectionDetailInfoFollowers:
                    cell.textLabel.text = @"Followers";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",self.twUser.followers_count];
                    break;
                case kSBFUserInfoSectionDetailInfoTweets:
                    cell.textLabel.text = @"Tweets";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",self.twUser.status_count];
                    break;
            }
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == kSBFUserInfoSectionUserInfo){
        if ([indexPath row] == kSBFUserInfoSectionUserInfoAvatar){
            return kSBFUserInfoCellHeightMedium;
        }
        if ([indexPath row] == kSBFUserInfoSectionUserInfoDescription){
            return kSBFUserInfoCellHeightLarge;
        }
    }
    
    if ([indexPath section] == kSBFUserInfoSectionTweet){
        if ([indexPath row] == kSBFUserInfoSectionTweetText){
            return kSBFUserInfoCellHeightLarge;
        }
    }

    return kSBFUserInfoCellHeightSmall;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;

    if (section == kSBFUserInfoSectionTweet){
        if (row == kSBFUserInfoSectionTweetLink){   // open tweet at twitter.com
            [[UIApplication sharedApplication] openURL:self.twUser.lastTweetURL];
        }
    }
    if (section == kSBFUserInfoSectionDetailInfo){
        if (row == kSBFUserInfoSectionDetailInfoLink){   // open tweet at twitter.com
            [[UIApplication sharedApplication] openURL:self.twUser.url];
        }
    }
}



@end
