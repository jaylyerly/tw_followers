//
//  SBFUserInfoViewController.m
//  Followers
//
//  Created by Jay Lyerly on 12/5/12.
//  Copyright (c) 2012 Jay Lyerly. All rights reserved.
//

#import "SBFUserInfoViewController.h"

#import "SBFTwitterUser.h"

@interface SBFUserInfoViewController ()

@property (strong, nonatomic) SBFTwitterUser* twUser;

@end

@implementation SBFUserInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
        case 0:                 // UserInfo
            return 2;
        case 1:                 // Tweet
            return 2;
        case 2:                 // DetailInfo
            return 4;
        default:
            return 0;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:                 // UserInfo
            return @"";
        case 1:                 // Tweet
            return @"Latest Tweet";
        case 2:                 // DetailInfo
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
        case 0:                 // UserInfo
            if (row == 0){
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
        case 1:                 // Tweet
            if (row == 0){
                cell = [tableView dequeueReusableCellWithIdentifier:@"Tweet" forIndexPath:indexPath];
                tv = (UITextView*)[cell viewWithTag:101];
                tv.scrollEnabled = NO;  // disable scrolling, we know it's big enough for tweets
                tv.text = self.twUser.lastTweet;
            }else{
                cell = [tableView dequeueReusableCellWithIdentifier:@"TweetLink" forIndexPath:indexPath];
                cell.textLabel.text = @"Open at twitter.com";
            }
            break;
        case 2:                 // DetailInfo
            cell = [tableView dequeueReusableCellWithIdentifier:@"DetailInfo" forIndexPath:indexPath];
            switch (row) {
                case 0:
                    cell.textLabel.text = @"Location";
                    cell.detailTextLabel.text = self.twUser.location;
                    break;
                case 1:
                    cell.textLabel.text = @"URL";
                    cell.detailTextLabel.text = self.twUser.url.description;
                    break;
                case 2:
                    cell.textLabel.text = @"Followers";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",self.twUser.followers_count];
                    break;
                case 3:
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
    if ( ([indexPath section] == 0 && [indexPath row] == 1) ||          // twitter description
         ([indexPath section] == 1 && [indexPath row] == 0) )           // last tweet
    {
        return 88;
    }
    if ([indexPath section] == 0 && [indexPath row] == 0){          //  avatar & name
        return 60;  // nudge this a little bigger so the avatar doesn't spill out 
    }
    return 44;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;

    if (section == 1 && row==1){   // open tweet at twitter.com
        [[UIApplication sharedApplication] openURL:self.twUser.lastTweetURL];
    }
    if (section == 2 && row==1){   // open tweet at twitter.com
        [[UIApplication sharedApplication] openURL:self.twUser.url];
    }
    
}



@end
