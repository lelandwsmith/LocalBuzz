//
//  UserInfoTableViewController.h
//  LocalBuzz
//
//  Created by Zichao Fu on 12-10-26.
//  Copyright (c) 2012年 Vincent Leung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
@interface UserInfoTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *NameCell;
@property (weak, nonatomic) IBOutlet UILabel *LocationCell;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *photo;

@end
