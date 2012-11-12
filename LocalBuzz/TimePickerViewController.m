//
//  TimePickerViewController.m
//  LocalBuzz
//
//  Created by Vincent Leung on 10/24/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "TimePickerViewController.h"

@interface TimePickerViewController ()
@end

@implementation TimePickerViewController
@synthesize timePicker;
@synthesize timeToDisplay = _timeToDisplay;
@synthesize timepickerMode;
@synthesize minimumDate;

- (NSDate *)timeToDisplay {
    if (_timeToDisplay == nil) {
        _timeToDisplay = [NSDate date];
    }
    return _timeToDisplay;
}

- (void) viewDidLoad {
    [self.timePicker setDate:self.timeToDisplay animated:YES];
    self.timePicker.minimumDate = self.minimumDate;
}
@end
