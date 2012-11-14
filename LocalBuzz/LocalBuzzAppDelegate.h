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
extern NSString *const FBSessionStateChangedNotification;
@class LoginViewController;

@interface LocalBuzzAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LoginViewController *viewController;
@property (strong, nonatomic) FBSession *session;
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void) closeSession;
@end