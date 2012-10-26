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


- (void) setEvent:(Event *)event {
    if (_event != event) {
        _event = event;
        [self configureView];
    }
}

- (CLLocationManager *) locationManager {
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        if ([CLLocationManager locationServicesEnabled]) {
            _locationManager.delegate = self;
            _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            _locationManager.distanceFilter = kCLDistanceFilterNone;
        }
    }
    return _locationManager;
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

- (void) setUpMap:(NSNumber *)destLat :(NSNumber *)destLon {
	MapView *mapView = [[MapView alloc] initWithFrame:self.mapLable.bounds];
	[self.mapLable addSubview:mapView];
	
	// Fake the data of the start location
	CLLocationCoordinate2D startCoordinate = [self.locationManager.location coordinate];
    NSLog(@"%f, %f", startCoordinate.latitude, startCoordinate.longitude);
	MapViewAnnotation *startAnnotation = [[MapViewAnnotation alloc] initWithTitle:@"Start" coordinate:startCoordinate];
	
	// Fake the data of destination location
	CLLocationCoordinate2D endCoordinate = CLLocationCoordinate2DMake([destLat doubleValue], [destLon doubleValue]);
	MapViewAnnotation *endAnnotation = [[MapViewAnnotation alloc] initWithTitle:@"Destination" coordinate:endCoordinate];
	
	[mapView showRouteFrom:startAnnotation to:endAnnotation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self configureView];
    [self.locationManager stopUpdatingLocation];
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@", [error localizedDescription]);
    [self.locationManager stopUpdatingLocation];
}
- (void) viewDidLoad {
    [super viewDidLoad];
    [self.locationManager startUpdatingLocation];
}

@end