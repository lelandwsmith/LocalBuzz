//
//  SettingTableViewController.h
//  LocalBuzz
//
//  Created by Zichao Fu on 12-10-26.
//  Copyright (c) 2012年 Vincent Leung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UITableViewCell *logoutCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *UserInfoCell;
@property (weak, nonatomic) IBOutlet UILabel *UserInfoLabel;
@end
