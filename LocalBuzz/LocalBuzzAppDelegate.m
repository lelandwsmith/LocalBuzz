//
//  LocalBuzzAppDelegate.m
//  LocalBuzz
//
//  Created by Vincent Leung on 10/1/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "LocalBuzzAppDelegate.h"
#import "CurrentEventViewController.h"
#import "XMPP.h"
#import "XMPPUserCoreDataStorageObject.h"
#import <CFNetwork/CFNetwork.h>

#import "DDLog.h"
#import "DDTTYLogger.h"

#if DEBUG
    static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
    static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface LocalBuzzAppDelegate ()

@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) UITabBarController *mainViewController;
@property (strong, nonatomic) LoginViewController* loginViewController;
-(void)showLoginView;

-(void) setupStream;
-(void)tearDownStream;

-(void)goOnline;
-(void)goOffline;
@end

@implementation LocalBuzzAppDelegate
@synthesize navController = _navController;
@synthesize mainViewController = _mainViewController;
@synthesize loginViewController = _loginViewController;
@synthesize session = _session;
NSString *const FBSessionStateChangedNotification =
@"eecs441.info.vforvincent.Login:FBSessionStateChangedNotification";

- (XMPPStream *)xmppStream {
    if (_xmppStream == nil) {
        _xmppStream = [[XMPPStream alloc] init];
    }
    return _xmppStream;
}

- (XMPPRosterCoreDataStorage *)xmppRosterStorage {
    if (_xmppRosterStorage == nil) {
        _xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    }
    return _xmppRosterStorage;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    [self setupStream];
    //[FBRequest requestWithGraphPath:@"me/permissions" parameters:nil HTTPMethod:nil].session.permissions;
   // NSLog(@"original permission is %@",[FBRequest requestWithGraphPath:@"me/permissions" parameters:nil HTTPMethod:nil].session.permissions);
  //  NSLog(@"original expire date is %@",self.session.expirationDate);
    UIStoryboard*  storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                  bundle:nil];
    self.mainViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBar"];
    self.window.rootViewController = self.mainViewController;
    [self.window makeKeyAndVisible];
    //NSLog(@"didFinishWith#3");
    //if (![self openSessionWithAllowLoginUI:NO]) {
    if(![self.session isOpen]){
        // No? Display the login page.
        [self showLoginView];
    }
    [FBProfilePictureView class];
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

- (void) setupStream {
    NSAssert(self.xmppStream == nil, @"Method setupStream invoked multiple times");

#if !TARGET_IPHONE_SIMULATOR
    {
        self.xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.xmppStream setHostName:@"localbuzz.vforvincent.info"];
    allowSelfSignedCertificate = NO;
    allowSSLHostNameMismatch = NO;
}

- (void) tearDownStream {
    [self.xmppStream removeDelegate:self];
    [self.xmppStream disconnect];
}

- (void) goOnline {
    XMPPPresence *presence = [XMPPPresence presence];
    [self.xmppStream sendElement:presence];
}

- (void) goOffline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [self.xmppStream sendElement:presence];
}

- (BOOL)connectToXMPP {
    if (![self.xmppStream isDisconnected]) {
        return YES;
    }
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    if (username == nil) {
        return NO;
    }
    [self.xmppStream setMyJID:[XMPPJID jidWithString:username]];
    NSError *error = nil;
    if (![self.xmppStream connect:&error]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
		                                                    message:@"See console for error details."
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Ok"
		                                          otherButtonTitles:nil];
		[alertView show];
        
		DDLogError(@"Error connecting: %@", error);
        
		return NO;
    }
    return YES;
}

- (void)disconnectFromXMPP {
    [self goOffline];
    [self.xmppStream disconnect];
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


- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    ACAccountStore *accountStore;
    ACAccountType *accountTypeFB;
    if ((accountStore = [[ACAccountStore alloc] init]) &&
        (accountTypeFB = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook] ) ){
        
        NSArray *fbAccounts = [accountStore accountsWithAccountType:accountTypeFB];
        id account;
        if (fbAccounts && [fbAccounts count] > 0 &&
            (account = [fbAccounts objectAtIndex:0])){
            
            [accountStore renewCredentialsForAccount:account completion:^(ACAccountCredentialRenewResult renewResult, NSError *error) {
                //we don't actually need to inspect renewResult or error.
                if (error){
                    
                }
            }];
        }
    }
    switch (state) {
        case FBSessionStateOpen:{
           // NSLog(@"state == FBSessionSateOpen");
            //NSLog(@"expire date is %@",session.expirationDate);
           // NSLog(@"original permission is %@",[FBRequest requestWithGraphPath:@"me/permissions" parameters:nil HTTPMethod:nil].session.permissions);
            self.window.rootViewController = self.mainViewController;
            self.loginViewController = nil;
        }
            break;
        case FBSessionStateClosed:{
            //NSLog(@"state == FBSessionStateClosed");
            [self.navController popToRootViewControllerAnimated:NO];
            
            [FBSession.activeSession closeAndClearTokenInformation];
            
            [self showLoginView];
            if(error){
               [self openSessionWithAllowLoginUI:YES];
            }
        }
            break;
        case FBSessionStateClosedLoginFailed:{
            //NSLog(@"state == FBSessionStateClosedLoginFailed");
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


      //  [self openSessionWithAllowLoginUI:YES];
        
        
        
        /*UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Login Failed"
                                  message:@"Please grant the app the required permission and retry"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        self.session = nil;
        [alertView show];*/
      //  [self.navController popToRootViewControllerAnimated:NO];
        
       // [FBSession.activeSession closeAndClearTokenInformation];
      ////
       // [self showLoginView];
    }
}


/*
 * Opens a Facebook session and optionally shows the login UX.
 */
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    //NSLog(@"openSessionWithAllowLoginUI is called");
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"user_location",
                            @"user_birthday",
                            @"read_friendlists",
                            nil];
    //NSLog(@"permission0 is %@",self.session.permissions);
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
                                                                                          //NSLog(@"permission2 is %@",session.permissions);
                                             [self sessionStateChanged:session
                                                                 state:state
                                                                 error:error];
                                         }];
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


- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (allowSelfSignedCertificate)
	{
		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
	}
	
	if (allowSSLHostNameMismatch)
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
	else
	{
		// Google does things incorrectly (does not conform to RFC).
		// Because so many people ask questions about this (assume xmpp framework is broken),
		// I've explicitly added code that shows how other xmpp clients "do the right thing"
		// when connecting to a google server (gmail, or google apps for domains).
		
		NSString *expectedCertName = nil;
		
		NSString *serverDomain = self.xmppStream.hostName;
		NSString *virtualDomain = [self.xmppStream.myJID domain];
		
		if ([serverDomain isEqualToString:@"talk.google.com"])
		{
			if ([virtualDomain isEqualToString:@"gmail.com"])
			{
				expectedCertName = virtualDomain;
			}
			else
			{
				expectedCertName = serverDomain;
			}
		}
		else if (serverDomain == nil)
		{
			expectedCertName = virtualDomain;
		}
		else
		{
			expectedCertName = serverDomain;
		}
		
		if (expectedCertName)
		{
			[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
		}
	}
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	isXMPPConnected = YES;
	
	NSError *error = nil;
	
	if (![self.xmppStream authenticateWithPassword:@"test" error:&error])
	{
		DDLogError(@"Error authenticating: %@", error);
	}
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	[self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    self.xmppStream.myJID = [XMPPJID jidWithString:[[NSUserDefaults standardUserDefaults] stringForKey:@"username"]];
    NSError *registerError = nil;
    if (![self.xmppStream registerWithPassword:@"test" error:&registerError]) {
        NSLog(@"Register error: %@", registerError.localizedDescription);
    }
    [self connectToXMPP];
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
	// A simple example of inbound message handling.
    
	if ([message isChatMessageWithBody])
	{
		XMPPUserCoreDataStorageObject *user = [self.xmppRosterStorage userForJID:[message from]
		                                                         xmppStream:self.xmppStream
		                                               managedObjectContext:[self managedObjectContext_roster]];
		
		NSString *body = [[message elementForName:@"body"] stringValue];
		NSString *displayName = [user displayName];
        
		if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
		{
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
                                                                message:body
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
			[alertView show];
		}
		else
		{
			// We are not active, so use a local notification instead
			UILocalNotification *localNotification = [[UILocalNotification alloc] init];
			localNotification.alertAction = @"Ok";
			localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName,body];
            
			[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
		}
	}
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
	DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (!isXMPPConnected)
	{
		DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
	}
}


- (NSManagedObjectContext *)managedObjectContext_roster {
    return [self.xmppRosterStorage mainThreadManagedObjectContext];
}

@end
