//
//  AddEventViewController.m
//  LocalBuzz
//
//  Created by Amanda Le on 10/24/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "AddEventViewController.h"
#import "MapViewAnnotation.h"

@interface AddEventViewController ()

@end

@implementation AddEventViewController
@synthesize NewEventMapView = _NewEventMapView;
@synthesize locationManager = _locationManager;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Set up the map view
	self.NewEventMapView.delegate = self;
	
	self.locationManager = [[CLLocationManager alloc] init];
	[self.locationManager setDelegate:self];
	[self.locationManager setDistanceFilter:kCLDistanceFilterNone];
	[self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
	[self.locationManager startUpdatingLocation];
	
	// Zoom in to current location and show with the blue dot
	[self.NewEventMapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
	self.NewEventMapView.showsUserLocation = YES;
	
	// Attach the recognizer
	UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
	// User needs to press for 1 sec
	longPressGestureRecognizer.minimumPressDuration = 1.0;
	[self.NewEventMapView addGestureRecognizer:longPressGestureRecognizer];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *) longPressGesture
{
	if (longPressGesture.state != UIGestureRecognizerStateBegan)
		return;
	
	// Capture the location tapped on map
	CGPoint pressPoint = [longPressGesture locationInView:self.NewEventMapView];
	CLLocationCoordinate2D pressPointCoordinate = [self.NewEventMapView convertPoint:pressPoint toCoordinateFromView:self.NewEventMapView];
	
	// Drop pin with the location
	MapViewAnnotation * annotation = [[MapViewAnnotation alloc] initWithTitle:@"New Event" coordinate:pressPointCoordinate];
	[self.NewEventMapView addAnnotation:annotation];
	
	// Prepare to send to server
	// NOTE: the following are  lat and lon, type of CLLocationDegrees
	//pressPointCoordinate.latitude;
	//pressPointCoordinate.longitude;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
