//
//  SBFTableViewController.m
//  Followers
//
//  Created by Jay Lyerly on 12/4/12.
//  Copyright (c) 2012 Jay Lyerly. All rights reserved.
//

#import "SBFTableViewController.h"
#import "SBFTwitterUser.h"
#import "SBFViewController.h"
#import "SBFUserInfoViewController.h"
#import "SBFTwitterManager.h"

@interface SBFTableViewController ()

@property (strong, nonatomic) SBFTwitterUser *twitterUser;
@property (strong, nonatomic) NSMutableArray *followers;
@property (strong, nonatomic) NSString *cursor;
@property (strong, nonatomic) NSMutableArray *cursorList;
@property (strong, nonatomic) SBFUserInfoViewController* userInfoViewController;
@property (readonly) BOOL isFinishedLoadingFollowers;

@end

@implementation SBFTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self initialSetup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
        [self initialSetup];
    }
    return self;
}

- (void)initialSetup
{
    self.twitterUser = nil;
    self.followers = nil;
    self.cursor = @"-1";
    self.cursorList = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TableViewCells" bundle:nil] forCellReuseIdentifier:@"Cell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LoadingTableViewCells" bundle:nil] forCellReuseIdentifier:@"Loading"];
    
    UIStoryboard *sbd = [UIStoryboard storyboardWithName:@"UserInfo" bundle:nil];
    self.userInfoViewController = (SBFUserInfoViewController*)[sbd instantiateViewControllerWithIdentifier:@"UserInfo"];

    // Build a home buton to go back to the top of the stack
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStyleBordered target:self action:@selector(popToHome:)];
    if (self.stackLevel != 0){  // we're at the top level, so disable
        //homeButton.enabled = NO;
        self.navigationItem.rightBarButtonItem = homeButton;
    }
    
    // Add a pull-to-refresh gizmo
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh)
             forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = [NSString stringWithFormat:@"@%@",self.username];
}

- (NSString *)username {
    if (_username){
        return _username;
    }
    return [SBFTwitterManager sharedManager].defaultUsername;
}

#pragma mark - IBActions

-(IBAction)popToHome:(id)sender
{
    //self.rootViewController.jumpToFollowers = YES;
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark - Custom Methods
-(void)refresh{
    [self initialSetup];  // reset all the bits
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

-(void)addFollowers:(NSArray *)twUsers
{
    //DLog(@"addFollower");
    if (self.followers == nil) {
        self.followers = [NSMutableArray array];
    }
    [self.followers addObjectsFromArray:twUsers];
}

-(BOOL)isFinishedLoadingFollowers
{
    return [self.followers count] == self.twitterUser.followers_count;
}

-(void) reloadOnMainThread {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) { return @"User Info";}
    if (self.followers){
        return [NSString stringWithFormat:@"Followers (%d of %d)", [self.followers count], self.twitterUser.followers_count ];
    }
    return @"Followers";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {return 1;}
    
    if ([self.followers count] == 0) {return 1;}
    
    // If all the followers aren't loaded, add an extra cell for the Loading... text
    if (self.isFinishedLoadingFollowers){
        return [self.followers count];
    } else {
        return [self.followers count] + 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // set some sensible defaults, just in case
    cell.imageView.image = nil;
    cell.detailTextLabel.text = @"";
    cell.textLabel.text = @"";
    
    if ([indexPath section] == 0){  // user info section
        if (self.twitterUser){
            cell.textLabel.text = [NSString stringWithFormat:@"@%@",self.twitterUser.username];
            cell.detailTextLabel.text = self.twitterUser.name;
            cell.imageView.image = self.twitterUser.avatar;
        }else{
            cell.textLabel.text = @"Loading...";
            cell.detailTextLabel.text = @"...";
            cell.imageView.image = [UIImage imageNamed:@"twitter"];
            SBFTwitterManager *mgr = [SBFTwitterManager sharedManager];
            [mgr fetchInfoForUser:self.username completionBlock:^(SBFTwitterUser *user){
                self.twitterUser = user;
                [self.twitterUser addObserver:self
                                   forKeyPath:@"avatar"
                                      options:NSKeyValueObservingOptionNew
                                      context:nil];
                [self reloadOnMainThread];
            }];
            
/*
            if (self.userInfoConnectionID == nil){      // don't send request again if we've already sent one
                cell.textLabel.text = @"Loading...";
                cell.detailTextLabel.text = @"...";
                cell.imageView.image = [UIImage imageNamed:@"twitter"];
                //self.userInfoConnectionID = [self.twEngine getUserInformationFor:self.username];
                void (^theBlock)(NSDictionary*)=^void(NSDictionary *userDict){
                    self.twitterUser = [[SBFTwitterUser alloc] initWithDictionary:userDict];
                    if (self.twitterUser.followers_count == 0){
                        // if the follower count is 0, make an empty array so the table draws correctly
                        self.followers = [NSMutableArray array];
                    }
                    [self.tableView reloadData];
                };
//                if (self.userInfoConnectionID){
//                    [self.rootViewController addTask:theBlock forID:self.userInfoConnectionID];
//                }else{
//                    DLog(@"UserInfoConnectionID is nil in SFTableViewController!");
//                }

            }
*/
        }
    }else{      // followers section
        NSInteger row = [indexPath row];
        
        if (row == [self.followers count] && row != 0){  // this is the extra cell for 'Loading....'
            return [tableView dequeueReusableCellWithIdentifier:@"Loading" forIndexPath:indexPath];
        }else{
            NSArray* fws = self.followers;
            if (self.followers){
                if ([self.followers count] == 0){
                    cell.textLabel.text = @"No followers yet...";
                    cell.detailTextLabel.text = @"";
                    cell.imageView.image = nil;
                }else{
                    SBFTwitterUser* follower = fws[row];
                    cell.textLabel.text = [NSString stringWithFormat:@"@%@",follower.username];
                    cell.detailTextLabel.text = follower.name;
                    cell.imageView.image = follower.avatar;
                }
            }else{
                cell.textLabel.text = @"Loading...";
                cell.detailTextLabel.text = @"...";
                cell.imageView.image = [UIImage imageNamed:@"twitter"];
                [self requestFollowerData];
                /*
                [[SBFTwitterManager sharedManager] fetchFollowersForUser:self.username
                                                                  cursor:nil
                                                         completionBlock:^(NSArray *friends, NSString *next_cursor){
                                                             self.followers = [NSMutableArray arrayWithArray:friends];
                                                             self.cursor = next_cursor;
                                                             [self reloadOnMainThread];
                                                         }];
                 */
            }
        }
    }
    
    return cell;
}

- (void)requestFollowerData
{
    if (![self.cursor isEqualToString:@"0"] && ![self.cursorList containsObject:self.cursor ]){
        [[SBFTwitterManager sharedManager] fetchFollowersForUser:self.username
                                                          cursor:self.cursor
                                                 completionBlock:^(NSArray *friends, NSString *next_cursor){
                                                     [self addFollowers:friends];
                                                     self.cursor = next_cursor;
                                                     [self.cursorList addObject:self.cursor];
                                                     for (SBFTwitterUser *twUser in friends){
                                                         [twUser addObserver:self
                                                                  forKeyPath:@"avatar"
                                                                     options:NSKeyValueObservingOptionNew
                                                                     context:nil];
                                                     }
                                                     [self reloadOnMainThread];
                                                 }];
    }
    
    /*
    DLog(@"requesting followers with cursor: %@", self.cursor);
    if ([self.cursorList containsObject:self.cursor]) { return; } // bail if we've already requested this cursor
    [self.cursorList addObject:self.cursor];
    //self.followersConnectionID = [self.twEngine getFollowersIncludingCurrentStatus:NO forScreenName:self.username withCursor:self.cursor];
    void (^theBlock)(NSDictionary*)=^void(NSDictionary *userDict){
        // see if there's a cursor value pointing to another page
        NSString* next_cursor = [userDict objectForKey:@"next_cursor"];
        if (next_cursor){
            self.cursor = next_cursor;
        }
        
        SBFTwitterUser* twUser = [[SBFTwitterUser alloc] initWithDictionary:userDict];
        twUser.listIndex = [self.followers count];
        [self addFollower:twUser];
        [twUser addObserver:self
                 forKeyPath:@"avatar"
                    options:NSKeyValueObservingOptionNew
                    context:nil];
        [self.tableView reloadData];
    };
     */
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"removing observer for %@", object);
    [object removeObserver:self forKeyPath:keyPath];       // remove observer, these only update once
    [self reloadOnMainThread];
    return;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //DLog(@"WJL >>>> tap on table at index %d,%d", indexPath.section, indexPath.row);
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if ([indexPath section] == 0){
        //DLog(@"WJL -- > loading user info");
        if (self.twitterUser == nil) { cell.selected = NO; return; }  // bail if the user hasn't been loaded yet
        [self.userInfoViewController setupWithUser:self.twitterUser];
        [self.navigationController pushViewController:self.userInfoViewController animated:YES];
        return;
    }
    
    // section == 1
    NSInteger row = [indexPath row];

    // bail if the followers list is empty or not yet initialized
    if ([self.followers count] == 0 || self.followers == nil) { cell.selected = NO; return; }

    //NSArray* fws = [self.followers sortedArrayUsingSelector:@selector(compareUserName:)];
    NSArray* fws = self.followers;
    SBFTwitterUser *twUser = fws[row];
    
    SBFTableViewController* subView = [[SBFTableViewController alloc] init];
    subView.username = twUser.username;
    //subView.twEngine = self.twEngine;
    //subView.rootViewController = self.rootViewController;
    subView.stackLevel = self.stackLevel + 1;
    [self.navigationController pushViewController:subView animated:YES];
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // if the user scrolls to the bottom of the followers list and there is another batch of
    // followers available, fire off another request, but be careful not to do it twice for
    // the same cursor
    if ( (![self.cursor isEqualToString:@"-1"]) &&          // -1 or 0 means there are no other pages
            (![self.cursor isEqualToString:@"0"]) &&
            (![self.cursorList containsObject:self.cursor])  // and we haven't retrieved this before
        ){
        CGFloat height = scrollView.frame.size.height;
        
        CGFloat contentYoffset = scrollView.contentOffset.y;
        
        CGFloat distanceFromBottom = scrollView.contentSize.height - contentYoffset;
        //DLog(@"offset: %f", contentYoffset);
        
        if(distanceFromBottom < height)
        {
            // need to acquire more data
            [self requestFollowerData];
        }
    }
}

@end
