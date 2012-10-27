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
@private NSDate *startTime;
@private NSDate *endTime;
}
@end

@implementation AddEventViewController
@synthesize titleField;
@synthesize latitudeCell;
@synthesize longitudeCell;
@synthesize startTimeCell;

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)timeSelected:(UIStoryboardSegue *)segue {
    if ([[segue identifier] isEqualToString:@"ReturnTime"]) {
        TimePickerViewController *timePicker = [segue sourceViewController];
        NSDate *pickedTime = timePicker.timePicker.date;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        if (timePicker.timepickerMode == PickStartTime) {
            startTime = pickedTime;
            self.startTimeCell.detailTextLabel.text = [dateFormatter stringFromDate:startTime];
        } else if (timePicker.timepickerMode == PickEndtime) {
            endTime = pickedTime;
            self.endTimeCell.detailTextLabel.text = [dateFormatter stringFromDate:endTime];
        }
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
    if ([[segue identifier] isEqualToString:@"SelectStartTime"]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        startTime = [dateFormatter dateFromString:self.startTimeCell.detailTextLabel.text];
        NSLog(@"%@", [startTime description]);
        TimePickerViewController *timePickerController = segue.destinationViewController;
        timePickerController.timeToDisplay = startTime;
        timePickerController.timepickerMode = PickStartTime;
    }
    if ([[segue identifier] isEqualToString:@"SelectEndTime"]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        endTime = [dateFormatter dateFromString:self.endTimeCell.detailTextLabel.text];
        NSLog(@"%@", [endTime description]);
        TimePickerViewController *timePickerController = segue.destinationViewController;
        timePickerController.timeToDisplay = endTime;
        timePickerController.timepickerMode = PickEndtime;
    }
    if ([[segue identifier] isEqualToString:@"EventCreated"]) {
        NSURL *createUserURL = [NSURL URLWithString:@"http://localhost:3000/"];
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:createUserURL];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.titleField.text, @"event[title]",
                                [dateFormatter stringFromDate:startTime], @"event[start_time]",
                                [dateFormatter stringFromDate:endTime], @"event[end_time]",
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
    }
}

- (void) viewDidLoad {
    self.titleField.delegate = self;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
}

- (void) hideKeyboard {
    [self.titleField resignFirstResponder];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}


@end
