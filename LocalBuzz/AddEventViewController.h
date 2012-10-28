//
//  AddEventViewController.h
//  LocalBuzz
//
//  Created by Vincent Leung on 10/24/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddEventViewController : UITableViewController <UITextFieldDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITableViewCell *latitudeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *startTimeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *endTimeCell;
@property (weak, nonatomic) IBOutlet UILabel *lat_label;
@property (weak, nonatomic) IBOutlet UILabel *long_lebal;

@property (weak, nonatomic) IBOutlet UISwitch *switcher;
- (IBAction)timeSelected:(UIStoryboardSegue *)segue;
- (IBAction)locationSelected:(UIStoryboardSegue *)segue;

@end
