//
//  AddEventViewController.h
//  LocalBuzz
//
//  Created by Vincent Leung on 10/24/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AddEventViewController : UITableViewController <UITextFieldDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITableViewCell *latitudeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *startTimeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *endTimeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *location;
@property (weak, nonatomic) IBOutlet UISwitch *switcher;

- (IBAction)timeSelected:(UIStoryboardSegue *)segue;
- (IBAction)locationSelected:(UIStoryboardSegue *)segue;

@end
