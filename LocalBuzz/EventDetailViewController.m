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

@interface EventDetailViewController ()

@end

@implementation EventDetailViewController
@synthesize titleLabel = _titleLabel;
@synthesize descriptionLabel = _descriptionLabel;
@synthesize timeLabel = _timeLabel;
@synthesize locationLabel = _locationLabel;
@synthesize mapLable = _mapLable;
@synthesize currentCoordinate = _currentCoordinate;


- (void) setEvent:(Event *)event {
    if (_event != event) {
        _event = event;
        [self configureView];
    }
}

- (void) configureView {
	Event *theEvent = self.event;
	if (theEvent) {
		[self setUpMap:theEvent.latitude :theEvent.longitude];
		
		self.titleLabel.text = theEvent.title;
		self.descriptionLabel.text = theEvent.detailDescription;
		
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

- (void) setUpMap:(NSNumber *)destLat :(NSNumber *)destLng {
	MapView *mapView = [[MapView alloc] initWithFrame:self.mapLable.bounds];
	[self.mapLable addSubview:mapView];
	
	// Fake the data of the start location
	CLLocationCoordinate2D startCoordinate = self.currentCoordinate;
	DDAnnotation *startAnnotation = [[DDAnnotation alloc] initWithCoordinate:startCoordinate addressDictionary:nil];
	
	// Fake the data of destination location
	CLLocationCoordinate2D endCoordinate = CLLocationCoordinate2DMake([destLat doubleValue], [destLng doubleValue]);
	DDAnnotation *endAnnotation = [[DDAnnotation alloc] initWithCoordinate:endCoordinate addressDictionary:nil];
	
	[mapView showRouteFrom:startAnnotation to:endAnnotation];
}


- (void) viewDidLoad {
    [super viewDidLoad];
    [self configureView];
}

@end