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
@property (weak, nonatomic) IBOutlet UITableViewCell *timeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *longitudeCell;

- (IBAction)timeSelected:(UIStoryboardSegue *)segue;
- (IBAction)locationSelected:(UIStoryboardSegue *)segue;

@end
