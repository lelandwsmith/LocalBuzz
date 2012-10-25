//
//  EventDetailViewController.m
//  LocalBuzz
//
//  Created by Vincent Leung on 10/25/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "EventDetailViewController.h"
#import "MapViewAnnotation.h"
#import "Event.h"

@implementation EventDetailViewController
//@synthesize titleLabel;
//@synthesize descriptionLabel;
//@synthesize timeLabel;
//@synthesize locationLabel;
//@synthesize mapView;

- (void) setEvent:(Event *)event {
    if (_event != event) {
        _event = event;
        [self configureView];
    }
}

- (void) configureView {
    Event *theEvent = self.event;
    if (theEvent) {
        NSLog(@"%@", self.titleLabel.text);
        self.titleLabel.text = theEvent.title;
        self.descriptionLabel.text = theEvent.description;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        self.timeLabel.text = [dateFormatter stringFromDate:theEvent.time];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSString *latLongString = [numberFormatter stringFromNumber:theEvent.longitude];
        self.locationLabel.text = [[latLongString stringByAppendingString:@" "] stringByAppendingString:[numberFormatter stringFromNumber:theEvent.latitude]];
    }
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self configureView];
}


@end