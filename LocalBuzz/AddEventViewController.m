//
//  AddEventViewController.m
//  LocalBuzz
//
//  Created by Vincent Leung on 10/24/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "AddEventViewController.h"
#import "TimePickerViewController.h"
#import "LocationSelectionViewController.h"
#import "AFHTTPClient.h"
@interface AddEventViewController () {
@private NSDate *selectedDate;
}
@end

@implementation AddEventViewController
@synthesize titleField;
@synthesize latitudeCell;
@synthesize longitudeCell;
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
                            self.titleField.text, @"event[title]",
                            [dateFormatter stringFromDate:selectedDate], @"event[time]",
                            self.longitudeCell.detailTextLabel.text, @"event[longitude]",
                            self.latitudeCell.detailTextLabel.text, @"event[latitude]",
                            0, @"event[public]",
                            @"Random description", @"event[description]",
                            nil];
    [httpClient postPath:@"/events.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"Response: %@", responseString);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)timeSelected:(UIStoryboardSegue *)segue {
    if ([[segue identifier] isEqualToString:@"ReturnTime"]) {
        TimePickerViewController *timePicker = [segue sourceViewController];
        selectedDate = timePicker.timePicker.date;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        self.timeCell.detailTextLabel.text = [dateFormatter stringFromDate:selectedDate];
    }
}

- (IBAction)locationSelected:(UIStoryboardSegue *)segue {
    if ([[segue identifier] isEqualToString:@"ReturnLocation"]) {
        LocationSelectionViewController *locationSelector = [segue sourceViewController];
        CLLocationCoordinate2D selectedLatLong = locationSelector.latLong;
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        self.latitudeCell.detailTextLabel.text = [formatter stringFromNumber:[NSNumber numberWithDouble:selectedLatLong.latitude]];
        self.longitudeCell.detailTextLabel.text = [formatter stringFromNumber:[NSNumber numberWithDouble:selectedLatLong.longitude]];
    }
}

- (IBAction)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"SelectTime"]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        selectedDate = [dateFormatter dateFromString:self.timeCell.detailTextLabel.text];
        TimePickerViewController *timePickerController = segue.destinationViewController;
        timePickerController.timePicker.date = selectedDate;
    }
}

- (void) viewDidLoad {
    self.titleField.delegate = self;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
}

- (void) hideKeyboard {
    [self.titleField resignFirstResponder];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}


@end
