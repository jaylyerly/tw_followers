//
//  SBFViewController.m
//  Followers
//
//  Created by Jay Lyerly on 12/3/12.
//  Copyright (c) 2012 Jay Lyerly. All rights reserved.
//

#import "SBFViewController.h"


#import "SBFTableViewController.h"

#define kOAuthConsumerKey				@"1ZpyrD6z9JigIQJ7BAPfw"
#define kOAuthConsumerSecret			@"cjjMyfUENuyztrTQPCqGuzn9UhP8UETQKUnLQpPgVg8"

@interface SBFViewController (){
}

@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIButton *logoutButton;
@property (strong, nonatomic) IBOutlet UIButton *followersButton;
@property (strong, nonatomic) IBOutlet UILabel *connectedLabel;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) NSMutableDictionary* taskDict;
@property (strong, nonatomic) SBFTableViewController* tableView;
@property (strong, nonatomic) NSDate* lastErrorDate;

@end

@implementation SBFViewController

#pragma mark Overridden UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    DLog(@"viewDidLoad");
    self.taskDict = [NSMutableDictionary dictionary];
    
    self.tableView = nil;
    self.lastErrorDate = [NSDate distantPast];
//    if (self.twEngine.isAuthorized){
//        self.jumpToFollowers = YES;
//    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshButtonStateWithAnimation:NO];
    DLog(@"viewWillAppear");
}

-(void)viewDidAppear:(BOOL)animated
{
    if (self.jumpToFollowers){
        self.jumpToFollowers = NO;
        [self performSegueWithIdentifier:@"viewFollowers" sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark IBAction Methods

- (IBAction)logout:(id)sender {
    DLog(@"Logout button pressed");
    [self storeCachedTwitterOAuthData:nil forUsername:nil];    // nuked the stored credentials
//    [self.twEngine clearAccessToken];
    [self refreshButtonState];
    [self.view setNeedsDisplay];
}

- (IBAction)login:(id)sender {
    DLog(@"Login button pressed");
    
/*
    UIViewController *twLoginController = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:self.twEngine delegate:self];
    
    if (twLoginController){         // this is nil if we can use store credentials
        [self presentViewController:twLoginController animated:YES completion:nil];
    }else{
        [self performSegueWithIdentifier:@"viewFollowers" sender:self];
    }
*/
    [self refreshButtonState];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"viewFollowers"]){
        // set the username for the tableview display
        SBFTableViewController* tableView = (SBFTableViewController*)segue.destinationViewController;
        self.tableView = tableView;
//        tableView.username = self.twEngine.username;
        //tableView.username = @"andriajensen";   
        //tableView.username = @"hotdogsladies";
        //tableView.username = @"TheEllenShow";  
//        tableView.twEngine = self.twEngine;
        tableView.stackLevel = 0;
        tableView.rootViewController = self;
    }
}


#pragma mark Custom Methods
- (void)refreshButtonState{
    [self refreshButtonStateWithAnimation:YES];
}

- (void)refreshButtonStateWithAnimation:(BOOL) animate
{    
    CGFloat animDuration = .5;
    if (animate == NO){
        animDuration = 0.0;
    }
/*
    if (self.twEngine.isAuthorized){        // logged in and ready
        
        [UIView animateWithDuration:animDuration
                              delay:0.0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                                self.followersButton.enabled = YES;
                                self.followersButton.alpha = 1.0;
                                
                                self.logoutButton.enabled = YES;
                                self.logoutButton.alpha = 1.0;
                                
                                self.loginButton.enabled = NO;
                                self.loginButton.alpha = .4;
                                
                                self.usernameLabel.text = [NSString stringWithFormat:@"@%@", self.twEngine.username];
                                self.usernameLabel.alpha = 1.0;
                                self.connectedLabel.alpha = 1.0;
                         }
                         completion:nil];

    }else{                                                  // not logged in
        
        [UIView animateWithDuration:animDuration
                              delay:0.0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                                self.followersButton.enabled = NO;
                                self.followersButton.alpha = .4;
                                        
                                self.logoutButton.enabled = NO;
                                self.logoutButton.alpha = .4;
                                
                                self.loginButton.enabled = YES;
                                self.loginButton.alpha = 1.0;
                                
                                self.usernameLabel.alpha = 0.0;
                                self.connectedLabel.alpha = 0.0;
                         }
                         completion:nil];

    }
 */
}

- (void) addTask:(void(^)(NSDictionary* userDict))taskBlock forID:(NSString*)connectionID
{
    [self.taskDict setValue:taskBlock forKey:connectionID];
}

- (void)executeTaskID:(NSString*)connectionID withUsers:(NSArray*) userInfoArray
{
    for (NSDictionary* userDict in userInfoArray){
        //DLog(@"Running block on userDict: %@", userDict);
        void (^theBlock)(NSDictionary*) = [self.taskDict objectForKey:connectionID];
        theBlock(userDict);
    }
}

#pragma mark Twitter Engine Delegates

- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username
{
    DLog(@"store twitter creds: >%@< >%@<", username, data);
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    [defs setObject:data forKey:[self getDefaultsKeyForUsername:username]];
    [defs synchronize];

}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username
{
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSString* data = [defs stringForKey:[self getDefaultsKeyForUsername:username]];
    DLog(@"retrieve twitter creds: >%@< >%@<",username, data);
    return data;
}

-(NSString*) getDefaultsKeyForUsername:(NSString*)username
{
    //return [NSString stringWithFormat:@"TwitterCreds-%@",username];
    return @"TwitterCreds";
}

- (void) twitterOAuthConnectionFailedWithData: (NSData *) data
{
    DLog(@"Twitter OAuth Connection failed.");
}

#pragma mark TwitterEngineDelegate
/*
- (void) requestSucceeded: (NSString *) requestIdentifier {
	//DLog(@"Request %@ succeeded", requestIdentifier);
    
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
	//DLog(@"Request %@ failed with error: %@", requestIdentifier, error);
    
    NSString* errStr = [error localizedDescription];
    NSString* msg = [NSString stringWithFormat:@"Uh oh!  Looks like there's a problem contacting Twitter.  You can pull down on the list to try again.\n\nError: %@",errStr];
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Twitter Error" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    // don't flood the user with a bunch of alerts in the same 2 seconds
    // they're probably the same error form several requests sent at about the same time
    if ( [[NSDate date] timeIntervalSinceDate:self.lastErrorDate] > 2.0){
        self.lastErrorDate = [NSDate date];
        [alert show];
    }
}

- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier
{
    DLog(@"status results received for connection ID: %@", connectionIdentifier);
}

- (void)directMessagesReceived:(NSArray *)messages forRequest:(NSString *)connectionIdentifier
{
    DLog(@"status results received for connection ID: %@", connectionIdentifier);
}

- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier
{
    //DLog(@"user info results received for connection ID: %@", connectionIdentifier);
    [self executeTaskID:connectionIdentifier withUsers:userInfo];
}

- (void)miscInfoReceived:(NSArray *)miscInfo forRequest:(NSString *)connectionIdentifier
{
    DLog(@"misc info results received for connection ID: %@", connectionIdentifier);
}

- (void)searchResultsReceived:(NSArray *)searchResults forRequest:(NSString *)connectionIdentifier
{
    DLog(@"search results received for connection ID: %@", connectionIdentifier);
}

- (void)imageReceived:(UIImage *)image forRequest:(NSString *)connectionIdentifier
{
    DLog(@"image received for connection ID: %@", connectionIdentifier);
}
*/
@end
