//
//  DetailEventDescriptionViewController.m
//  LocalBuzz
//
//  Created by Amanda Le on 10/1/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "DetailEventDescriptionViewController.h"

@interface DetailEventDescriptionViewController ()
 
@end

@implementation DetailEventDescriptionViewController
@synthesize num = _num;

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
	
	/*
	self.EventMapView.delegate = self;
	
	self.locationManager = [[CLLocationManager alloc] init];
	[self.locationManager setDelegate:self];
	[self.locationManager setDistanceFilter:kCLDistanceFilterNone];
	[self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
	[self.locationManager startUpdatingLocation];
	
	self.routeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.EventMapView.frame.size.width, self.EventMapView.frame.size.height)];
	self.routeView.userInteractionEnabled = NO;
	[self.EventMapView addSubview:self.routeView];
	*/
	 
	//self.EventMapView.showsUserLocation = YES;
	//self.EventMapView.mapType = MKMapTypeStandard;
	
	// Get the data of current location
	//CLLocation *startLocation = [self.locationManager location];
	//CLLocationCoordinate2D startCoordinate = [startLocation coordinate];
	
	
	
	MapView* mapView = [[MapView alloc] initWithFrame:
											 CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	
	[self.view addSubview:mapView];
	
	
	CLLocationCoordinate2D startCoordinate = CLLocationCoordinate2DMake(37.78700, -121.40400);
	MapViewAnnotation *startAnnotation = [[MapViewAnnotation alloc] initWithTitle:@"Start" coordinate:startCoordinate];
	
	// Fake the data of destination location, and add pin to map
	CLLocationCoordinate2D endCoordinate = CLLocationCoordinate2DMake(37.78688, -122.405398);
	MapViewAnnotation *endAnnotation = [[MapViewAnnotation alloc] initWithTitle:@"Destination" coordinate:endCoordinate];
	
	
	[mapView showRouteFrom:startAnnotation to:endAnnotation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//NOTE: segue would pass necessary info to this function
//TODO: determine the member viables here and what are needed to sent from the list view (ie. title)
- (void)setNum:(int)num
{
  _num = num;
}

@end
