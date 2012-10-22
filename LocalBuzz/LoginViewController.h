//
//  LoginViewController.h
//  LocalBuzz
//
//  Created by Zichao Fu on 12-10-3.
//  Copyright (c) 2012年 Vincent Leung. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@end

@interface friendinfo : NSObject {
@public
    
    NSString* Fname;
    NSString* Fid;
}
@property(nonatomic, copy) NSString *Fname;
@property(nonatomic, copy) NSString *Fid;
@end

@implementation friendinfo
@synthesize Fname,Fid;
- (void) dealloc
{
    self.Fname = nil;
    self.Fid = nil;
}
@end