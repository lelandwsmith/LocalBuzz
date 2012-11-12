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
@synthesize timeLabel = _timeLabel;
@synthesize locationLabel = _locationLabel;
@synthesize descriptionLabel = _descriptionLabel;
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
		self.timeLabel.text = [dateFormatter stringFromDate:theEvent.startTime];
		
		CLLocation *loc = [[CLLocation alloc] initWithLatitude:[theEvent.latitude doubleValue] longitude:[theEvent.longitude doubleValue]];
		CLGeocoder *geocoder = [[CLGeocoder alloc] init];
		
		//Geocoding Block
		[geocoder reverseGeocodeLocation: loc completionHandler:^(NSArray *placemarks, NSError *error) {
			//Get nearby address
			CLPlacemark *placemark = [placemarks objectAtIndex:0];
			
			//String to hold address
			NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
			
			//Print the location to console
			NSLog(@"I am currently at %@",locatedAt);
			
			//Set the label text to current location
			[self.locationLabel setText:locatedAt];
		}];
		
	}
}

- (void) setUpMap:(NSNumber *)destLat :(NSNumber *)destLng {
	MapView *mapView = [[MapView alloc] initWithFrame:self.mapLable.bounds];
	[self.mapLable addSubview:mapView];
	
	// Get the start location
	CLLocationCoordinate2D startCoordinate = self.currentCoordinate;
	DDAnnotation *startAnnotation = [[DDAnnotation alloc] initWithCoordinate:startCoordinate addressDictionary:nil];
	
	// Get the destination location
	CLLocationCoordinate2D endCoordinate = CLLocationCoordinate2DMake([destLat doubleValue], [destLng doubleValue]);
	DDAnnotation *endAnnotation = [[DDAnnotation alloc] initWithCoordinate:endCoordinate addressDictionary:nil];
	
	[mapView showRouteFrom:startAnnotation to:endAnnotation];
}


- (void) viewDidLoad {
    [super viewDidLoad];
    [self configureView];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end