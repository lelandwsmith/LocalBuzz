//
//  AddEventViewController.m
//  LocalBuzz
//
//  Created by Vincent Leung on 10/24/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "AddEventViewController.h"
#import "TimePickerViewController.h"
#import "AFHTTPClient.h"
@interface AddEventViewController () {
@private NSDate *selectedDate;
}
@end

@implementation AddEventViewController
@synthesize titleField;
@synthesize locationCell;
@synthesize timeCell;

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)createPressed:(id)sender {
    NSURL *createUserURL = [NSURL URLWithString:@"http://localhost:3000/"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:createUserURL];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"];
    NSLog(@"%@", [selectedDate description]);
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            titleField.text, @"event[title]",
                            [dateFormatter stringFromDate:selectedDate], @"event[time]",
                            nil];
    [httpClient postPath:@"/events.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"Response: %@", responseString);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(UIStoryboardSegue *)segue {
    if ([[segue identifier] isEqualToString:@"ReturnTime"]) {
        TimePickerViewController *timePicker = [segue sourceViewController];
        selectedDate = timePicker.timePicker.date;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        self.timeCell.detailTextLabel.text = [dateFormatter stringFromDate:selectedDate];
    }
}

- (IBAction)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"SelectTime"]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        NSDate *selectedDate = [dateFormatter dateFromString:self.timeCell.detailTextLabel.text];
        TimePickerViewController *timePickerController = segue.destinationViewController;
        timePickerController.timePicker.date = selectedDate;
    }
}


@end
