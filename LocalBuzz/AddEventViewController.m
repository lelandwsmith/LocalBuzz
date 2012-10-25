//
//  AddEventViewController.m
//  LocalBuzz
//
//  Created by Vincent Leung on 10/24/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "AddEventViewController.h"
#import "TimePickerViewController.h"

@interface AddEventViewController ()

@end

@implementation AddEventViewController
@synthesize titleField;
@synthesize locationCell;
@synthesize timeCell;

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)createPressed:(id)sender {
    
}

- (IBAction)done:(UIStoryboardSegue *)segue {
    if ([[segue identifier] isEqualToString:@"SelectTime"]) {
        TimePickerViewController *timePicker = [segue sourceViewController];
        NSDate *selectedDate = timePicker.timePicker.date;
        self.timeCell.detailTextLabel.text = selectedDate.description;
    }
}


@end
