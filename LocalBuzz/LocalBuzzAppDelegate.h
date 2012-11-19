//
//  LocalBuzzAppDelegate.h
//  LocalBuzz
//
//  Created by Vincent Leung on 10/1/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Accounts/ACAccountStore.h>
#import <Accounts/ACAccountType.h>
#import <Social/Social.h>
#import <CoreData/CoreData.h>
#import "XMPPFramework.h"

extern NSString *const FBSessionStateChangedNotification;
@class LoginViewController;

@interface LocalBuzzAppDelegate : UIResponder <UIApplicationDelegate, XMPPStreamDelegate> {
    BOOL allowSelfSignedCertificate;
    BOOL allowSSLHostNameMismatch;
    BOOL isXMPPConnected;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FBSession *session;
@property (strong, nonatomic) XMPPStream *xmppStream;
@property (strong, nonatomic) XMPPRosterCoreDataStorage *xmppRosterStorage;
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void) closeSession;
- (BOOL) connectToXMPP;
- (void) disconnectFromXMPP;

- (NSManagedObjectContext *)managedObjectContext_roster;
@end
