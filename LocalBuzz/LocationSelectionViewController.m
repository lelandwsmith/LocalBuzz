//
//  LocationSelectionViewController.m
//  LocalBuzz
//
//  Created by Amanda Le on 10/25/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "LocationSelectionViewController.h"
#import "DDAnnotation.h"
#import "DDAnnotationView.h"

@interface LocationSelectionViewController ()

@end

@implementation LocationSelectionViewController
@synthesize mapView = _mapView;
@synthesize locationManager = _locationManager;
@synthesize latLong = _latLong;
@synthesize geoCoder = _geoCoder;
@synthesize address = _address;

- (CLLocationManager *)locationManager {
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [_locationManager setDistanceFilter:kCLDistanceFilterNone];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

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
	[self.locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self setUpMap:[locations lastObject]];
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@", [error localizedDescription]);
}

- (void)setUpMap:(CLLocation *)location
{
	// Set up the map view
	self.mapView.delegate = self;

	// Zoom in to current location and show with the blue dot
	[self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
	self.mapView.showsUserLocation = YES;
	[self.mapView setCenterCoordinate:location.coordinate animated:YES];
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000, 1000);
	[self.mapView setRegion:region];
	
	// Attach the recognizer
	UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
	// User needs to press for 0.5 sec
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
	DDAnnotation *annotation = [[DDAnnotation alloc] initWithCoordinate:pressPointCoordinate addressDictionary:nil];
	annotation.title = @"New Event";
	annotation.subtitle = [NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
	[self.mapView addAnnotation:annotation];
	
	// Return lat and lon
	self.latLong = pressPointCoordinate;
}

- (IBAction)geoCodeLocation:(UIBarButtonItem *)sender
{
	NSLog(@"enter geoCodeLocation");
	
	CLLocation *loc = [[CLLocation alloc] initWithLatitude:self.latLong.latitude longitude:self.latLong.longitude];
	//Geocoding Block
	[self.geoCoder reverseGeocodeLocation: loc completionHandler:^(NSArray *placemarks, NSError *error) {
		
		//Get nearby address
		CLPlacemark *placemark = [placemarks objectAtIndex:0];
		
		//String to hold address
		self.address = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
		
		//Print the location to console
		NSLog(@"I am currently at %@", self.address);
		//NSLog(@" %@", placemark.addressDictionary);
		
		//Set the label text to current location
		//self.location.detailTextLabel.text = locatedAt;
	}];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	
	self.mapView.delegate = nil;
	self.mapView = nil;
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
	
	if (oldState == MKAnnotationViewDragStateDragging) {
		DDAnnotation *annotation = (DDAnnotation *)annotationView.annotation;
		annotation.subtitle = [NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
	}
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    NSLog(@"new location: lat:%f, long%f", userLocation.coordinate.latitude, userLocation.coordinate.longitude);
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	if ([annotation isKindOfClass:[MKUserLocation class]]) {
		return nil;
	}
	
	static NSString * const kPinAnnotationIdentifier = @"PinIdentifier";
	MKAnnotationView *draggablePinView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];
	
	if (draggablePinView) {
		draggablePinView.annotation = annotation;
	} else {
		// Use class method to create DDAnnotationView (on iOS 3) or built-in draggble MKPinAnnotationView (on iOS 4).
		draggablePinView = [DDAnnotationView annotationViewWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier mapView:self.mapView];
		
		if ([draggablePinView isKindOfClass:[DDAnnotationView class]]) {
			// draggablePinView is DDAnnotationView on iOS 3.
		} else {
			// draggablePinView instance will be built-in draggable MKPinAnnotationView when running on iOS 4.
		}
	}
	
	return draggablePinView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
