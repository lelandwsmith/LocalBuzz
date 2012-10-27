//
//  SettingTableViewController.h
//  LocalBuzz
//
//  Created by Zichao Fu on 12-10-26.
//  Copyright (c) 2012年 Vincent Leung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UITableViewCell *logoutBT;
@property (weak, nonatomic) IBOutlet UITableViewCell *UserInfoCell;
@property (weak, nonatomic) IBOutlet UILabel *UserInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentRange;
@property (weak, nonatomic) IBOutlet UISlider *slider;

- (IBAction)setRange:(id)sender;
@end
