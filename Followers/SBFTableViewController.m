//
//  SBFTableViewController.m
//  Followers
//
//  Created by Jay Lyerly on 12/4/12.
//  Copyright (c) 2012 Jay Lyerly. All rights reserved.
//

#import "SBFTableViewController.h"
#import "SBFTwitterUser.h"
#import "SBFUserInfoViewController.h"
#import "SBFTwitterManager.h"

static const NSUInteger kSBFTableViewCellHeight = 60;

static const NSUInteger kSBFTableViewSectionUserInfo = 0;
static const NSUInteger kSBFTableViewSectionFollowers = 1;

@interface SBFTableViewController ()

@property (nonatomic) NSUInteger stackLevel;
@property (strong, nonatomic) SBFTwitterUser *twitterUser;
@property (strong, nonatomic) NSMutableArray *followers;
@property (copy,   nonatomic) NSString *cursor;
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initialSetup
{
    self.twitterUser = nil;
    self.followers = nil;
    self.cursor = @"-1";
    self.cursorList = [NSMutableArray array];
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
    

    // TODO: refactor using direct SBFTwitterUser comparision
    __block NSMutableArray *names = [NSMutableArray array];
    [self.followers enumerateObjectsUsingBlock:^(SBFTwitterUser *user, NSUInteger index, BOOL *stop){
        [names addObject:user.name];
    }];
    
    for (SBFTwitterUser *user in twUsers){
        if (! [names containsObject:user.name]){
            [self.followers addObject:user];
        }
    }
    
}

-(BOOL)isFinishedLoadingFollowers
{
    return [self.followers count] == self.twitterUser.followers_count;
}

-(void) reloadOnMainThread {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"number of followers: %d", [self.followers count]);
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
    if (section == kSBFTableViewSectionUserInfo) { return @"User Info";}
    if (self.followers){
        return [NSString stringWithFormat:@"Followers (%d of %d)", [self.followers count], self.twitterUser.followers_count ];
    }
    return @"Followers";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kSBFTableViewSectionUserInfo) {return 1;}
    
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
    return kSBFTableViewCellHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // set some sensible defaults, just in case
    cell.imageView.image = nil;
    cell.detailTextLabel.text = @"";
    cell.textLabel.text = @"";
    
    if ([indexPath section] == kSBFTableViewSectionUserInfo){  // user info section
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
                [self observerTwitterUser:user];
                [self reloadOnMainThread];
            }];
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
            }
        }
    }
    
    return cell;
}

- (void)requestFollowerData
{
    DLog(@"requesting followers with cursor: %@", self.cursor);
    DLog(@"requesting followers with cursorlist: %@", self.cursorList);

    // bail on '0', this indicates there are no more pages.
    if ([self.cursor isEqualToString:@"0"])           { return;}

    // bail if we've already requested this page.
    if ([self.cursorList containsObject:self.cursor]) { return;}

    [self.cursorList addObject:self.cursor];
    [[SBFTwitterManager sharedManager] fetchFollowersForUser:self.username
                                                      cursor:self.cursor
                                             completionBlock:^(NSArray *friends, NSString *next_cursor){
                                                 [self addFollowers:friends];
                                                 self.cursor = next_cursor;
                                                 for (SBFTwitterUser *twUser in friends){
                                                     [self observerTwitterUser:twUser];
                                                 }
                                                 [self reloadOnMainThread];
                                             }];
    
}

- (void)observerTwitterUser:(SBFTwitterUser *)user {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:SBFTwitterUserDidUpdateAvatarNotification
                        object:user
                         queue:nil
                    usingBlock:^(NSNotification *notification)
    {
        [self reloadOnMainThread];
    }];
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //DLog(@"WJL >>>> tap on table at index %d,%d", indexPath.section, indexPath.row);
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if ([indexPath section] == kSBFTableViewSectionUserInfo){
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
    subView.stackLevel = self.stackLevel + 1;
    [self.navigationController pushViewController:subView animated:YES];
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat height = scrollView.frame.size.height;
    CGFloat contentYoffset = scrollView.contentOffset.y;
    CGFloat distanceFromBottom = scrollView.contentSize.height - contentYoffset;
    if(distanceFromBottom < height) {
        [self requestFollowerData];
    }
}
@end
