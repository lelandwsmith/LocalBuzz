//
//  TimePickerViewController.h
//  LocalBuzz
//
//  Created by Vincent Leung on 10/24/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PickStartTime,
    PickEndtime
} TimePickerMode;

@interface TimePickerViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (weak, nonatomic) NSDate* timeToDisplay;
@property (nonatomic) TimePickerMode timepickerMode;

@end
