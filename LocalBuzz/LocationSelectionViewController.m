//
//  LocationSelectionViewController.m
//  LocalBuzz
//
//  Created by Amanda Le on 10/25/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "LocationSelectionViewController.h"
#import "MapViewAnnotation.h"

@interface LocationSelectionViewController ()

@end

@implementation LocationSelectionViewController
@synthesize mapView = _mapView;
@synthesize locationManager = _locationManager;
@synthesize latLong = _latLong;

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
	
	self.mapView.delegate = self;
	
	self.locationManager = [[CLLocationManager alloc] init];
	[self.locationManager setDelegate:self];
	[self.locationManager setDistanceFilter:kCLDistanceFilterNone];
	[self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
	[self.locationManager startUpdatingLocation];
	
	// Zoom in to current location and show with the blue dot
	[self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
	self.mapView.showsUserLocation = YES;
	
	// Attach the recognizer
	UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
	// User needs to press for 1 sec
	longPressGestureRecognizer.minimumPressDuration = 0.5;
	[self.mapView addGestureRecognizer:longPressGestureRecognizer];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *) longPressGesture
{
	if (longPressGesture.state != UIGestureRecognizerStateBegan)
		return;
	
	// Capture the location tapped on map
	CGPoint pressPoint = [longPressGesture locationInView:self.mapView];
	CLLocationCoordinate2D pressPointCoordinate = [self.mapView convertPoint:pressPoint toCoordinateFromView:self.mapView];
	
	// Drop pin with the location
	MapViewAnnotation * annotation = [[MapViewAnnotation alloc] initWithTitle:@"New Event" coordinate:pressPointCoordinate];
	[self.mapView addAnnotation:annotation];
	
    self.latLong = pressPointCoordinate;
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
