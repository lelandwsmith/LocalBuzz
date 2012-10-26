//
//  EventDetailViewController.m
//  LocalBuzz
//
//  Created by Vincent Leung on 10/25/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "EventDetailViewController.h"
#import "Event.h"
#import "RegexKitLite.h"

#define MINIMUM_ZOOM_ARC 0.014
#define ANNOTATION_REGION_PAD_FACTOR 1.15
#define MAX_DEGREES_ARC 360

@interface EventDetailViewController ()

@end

@implementation EventDetailViewController
@synthesize titleLabel = _titleLabel;
@synthesize descriptionLabel = _descriptionLabel;
@synthesize timeLabel = _timeLabel;
@synthesize locationLabel = _locationLabel;

/*@synthesize mapView = _mapView;
@synthesize locationManager = _locationManager;
@synthesize routes = _routes;
*/

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
        
        [self setUpMap];
    }
}

- (void) setUpMap {
	MapView* mapView = [[MapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	[self.view addSubview:mapView];
	
	// Fake the data of the start location
	CLLocationCoordinate2D startCoordinate = CLLocationCoordinate2DMake(37.78700, -121.40400);
	MapViewAnnotation *startAnnotation = [[MapViewAnnotation alloc] initWithTitle:@"Start" coordinate:startCoordinate];
	
	// Fake the data of destination location
	CLLocationCoordinate2D endCoordinate = CLLocationCoordinate2DMake(37.78688, -122.405398);
	MapViewAnnotation *endAnnotation = [[MapViewAnnotation alloc] initWithTitle:@"Destination" coordinate:endCoordinate];
	
	[mapView showRouteFrom:startAnnotation to:endAnnotation];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self configureView];
}

@end