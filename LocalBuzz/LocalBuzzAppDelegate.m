//
//  LocalBuzzAppDelegate.m
//  LocalBuzz
//
//  Created by Vincent Leung on 10/1/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "LocalBuzzAppDelegate.h"
#import "CurrentEventViewController.h"
#import <CFNetwork/CFNetwork.h>

@interface LocalBuzzAppDelegate ()

@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) UITabBarController *mainViewController;
@property (strong, nonatomic) LoginViewController* loginViewController;
-(void)showLoginView;
@end

@implementation LocalBuzzAppDelegate
@synthesize navController = _navController;
@synthesize mainViewController = _mainViewController;
@synthesize loginViewController = _loginViewController;
@synthesize session = _session;
@synthesize xmppStream = _xmppStream;

NSString *const FBSessionStateChangedNotification = @"eecs441.info.vforvincent.Login:FBSessionStateChangedNotification";
NSString *const kHostName = @"localbuzz.vforvincent.info";

- (id)init {
    if (self = [super init]) {
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        self.xmppStream = [[XMPPStream alloc] init];
        self.xmppStream.hostName = kHostName;
        [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

/////////////////
#pragma mark UIApplicationDelegate
/////////////////

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIStoryboard*  storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                  bundle:nil];
    self.mainViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBar"];
    self.window.rootViewController = self.mainViewController;
    [self.window makeKeyAndVisible];
    if((![self.session isOpen])&&((FBSession.activeSession.state != FBSessionStateCreatedTokenLoaded))){
        [self showLoginView]; 
    }else{
        [FBSession.activeSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            //NSLog(@"Finished opening login session, with state: %d", status);
        }];
        [self getFriendUid];
    }
    [FBProfilePictureView class];
    
    //register user on XMPP
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
	NSLog(@"%@", username);
    XMPPJID *jid = [XMPPJID jidWithUser:username domain:self.xmppStream.hostName resource:nil];
    self.xmppStream.myJID = jid;
    NSError *error;
    if (![self.xmppStream connect:&error]) {
      //  NSLog(@"%@", error.localizedDescription);
    }
    return YES;

}

- (void)showLoginView
{
    UIStoryboard*  storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                          bundle:nil];
    LoginViewController* loginViewController =
    [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    self.window.rootViewController = (UIViewController*)loginViewController;
}

- (void) closeSession {
    [FBSession.activeSession closeAndClearTokenInformation];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSession.activeSession handleDidBecomeActive];
}

/*
 * If we have a valid session at the time of openURL call, we handle
 * Facebook transitions by passing the url argument to handleOpenURL
 */
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBSession.activeSession handleOpenURL:url];
}

-(void)applicationWillTerminate:(UIApplication *)application {
    // FBSample logic
    // if the app is going away, we close the session if it is open
    // this is a good idea because things may be hanging off the session, that need
    // releasing (completion block, etc.) and other components in the app may be awaiting
    // close notification in order to do cleanup
    [[NSUserDefaults standardUserDefaults] synchronize];
    [FBSession.activeSession close];
}

///////////////////////
#pragma mark Facebook authentication
//////////////////////////

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
   if ((self.accountStore = [[ACAccountStore alloc] init]) &&
        (self.accountTypeFB = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook] ) ){
        
        NSArray *fbAccounts = [self.accountStore accountsWithAccountType:self.accountTypeFB];
        id account;
        if (fbAccounts && [fbAccounts count] > 0 &&
            (account = [fbAccounts objectAtIndex:0])){
            
            [self.accountStore renewCredentialsForAccount:account completion:^(ACAccountCredentialRenewResult renewResult, NSError *error) {
                //we don't actually need to inspect renewResult or error.
                if (error){
                    
                }
            }];
        }
    }
    switch (state) {
        case FBSessionStateOpen:{
            [self getFriendUid];
            self.window.rootViewController = self.mainViewController;
            self.loginViewController = nil;
        }
            break;
        case FBSessionStateClosed:{
            
            [self.navController popToRootViewControllerAnimated:NO];
            
            [FBSession.activeSession closeAndClearTokenInformation];
            
            [self showLoginView];
            if(error){
               [self openSessionWithAllowLoginUI:YES];
            }
        }
            break;
        case FBSessionStateClosedLoginFailed:{
            
            [self.navController popToRootViewControllerAnimated:NO];
            
            [FBSession.activeSession closeAndClearTokenInformation];
            
            [self showLoginView];
            break;
        }
        default:
         
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:FBSessionStateChangedNotification
     object:session];
    
    if (error) {

    }
}

- (void)getFriendUid{
    NSString *query =
    @"SELECT uid, name, is_app_user FROM user WHERE uid IN "
    @"(SELECT uid2 FROM friend WHERE uid1=me()) AND is_app_user=1";
    // Set up the query parameter
    NSDictionary *queryParam =
    [NSDictionary dictionaryWithObjectsAndKeys:query, @"q", nil];
    // Make the API request that uses FQL
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              if (error) {
                                  NSLog(@"Errorwowowowow: %@", [error localizedDescription]);
                              } else {
                                  NSLog(@"Result: %@", result);
                              }
                          }];
}
/*
 * Opens a Facebook session and optionally shows the login UX.
 */
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    NSLog(@"openSessionWithAllowLoginUI is called");
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"user_location",
                            @"user_birthday",
                            @"read_friendlists",
                            nil];
    return [FBSession openActiveSessionWithReadPermissions:permissions
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
                                             //NSLog(@"permission1 is %@",session.permissions);

                                             if (state == FBSessionStateClosedLoginFailed || state == FBSessionStateCreatedOpening) {
                                                 
                                                 // If so, just send them round the loop again
                                                 [[FBSession activeSession] closeAndClearTokenInformation];
                                                 [FBSession setActiveSession:nil];
                                                 //FB_CreateNewSession();
                                             }
                                                                                          
                                             [self sessionStateChanged:session
                                                                 state:state
                                                                 error:error];
                                         }];
}

//////////////////////
#pragma mark XMPPStreamDelegate
//////////////////////

- (void) xmppStreamDidConnect:(XMPPStream *)sender {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    NSError *error;
    if (![self.xmppStream authenticateWithPassword:@"test" error:&error]) {
       // NSLog(@"%@", error.localizedDescription);
    }
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    NSError *registerError;
    if (![self.xmppStream registerWithPassword:@"test" error:&registerError]) {
       // NSLog(@"%@", registerError.localizedDescription);
    }
}
- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    NSError *error;
    if (![self.xmppStream authenticateWithPassword:@"test" error:&error]) {
      //  NSLog(@"%@", error.localizedDescription);
    }
    [self.xmppStream removeDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [self.xmppStream removeDelegate:self delegateQueue:dispatch_get_main_queue()];
}


@end
