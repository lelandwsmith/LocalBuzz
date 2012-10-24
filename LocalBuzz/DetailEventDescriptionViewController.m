//
//  DetailEventDescriptionViewController.m
//  LocalBuzz
//
//  Created by Amanda Le on 10/1/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "DetailEventDescriptionViewController.h"
#import "MapViewAnnotation.h"

@interface DetailEventDescriptionViewController ()

@end

@implementation DetailEventDescriptionViewController
@synthesize num = _num;
@synthesize EventMapView = _EventMapView;
@synthesize locationManager = _locationManager;


/*
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	CLLocationCoordinate2D newCordinate = newLocation.coordinate;
	CLLocationCoordinate2D oldCordinate = oldLocation.coordinate;
	
	MKMapPoint * pointsArray = malloc(sizeof(CLLocationCoordinate2D) * 2);
	
	pointsArray[0] = MKMapPointForCoordinate(oldCordinate);
	pointsArray[1] = MKMapPointForCoordinate(newCordinate);
	
	MKPolyline * routeLine = [MKPolyline polylineWithPoints:pointsArray count:2];
	free(pointsArray);
	
	[self.EventMapView addOverlay:routeLine];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
	MKOverlayView * overlayView = nil;
	MKPolylineView * _routeLineView = [[MKPolylineView alloc] initWithPolyline:overlay];
	_routeLineView.fillColor = [UIColor blueColor];
	_routeLineView.strokeColor = [UIColor blueColor];
	_routeLineView.lineWidth = 3;
	_routeLineView.lineCap = kCGLineCapSquare;
	
	overlayView = _routeLineView;
	return overlayView;
}
*/




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
	
	self.EventMapView.delegate = self;
	
	self.locationManager = [[CLLocationManager alloc] init];
	[self.locationManager setDelegate:self];
	
	[self.locationManager setDistanceFilter:kCLDistanceFilterNone];
	[self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
	
	//[self.EventMapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
	
	
	self.EventMapView.showsUserLocation = YES;
	self.EventMapView.mapType = MKMapTypeStandard;
	//self.EventMapView.mapType = MKMapTypeSatellite;
	//self.EventMapView.mapType = MKMapTypeHybrid;
	
	/*
	// Add pin to some point
	CLLocationCoordinate2D location;
	location.latitude = 37.78608;
	location.longitude = -122.405398;
	MapViewAnnotation * mapAnnotation = [[MapViewAnnotation alloc] initWithTitle:@"Custom Annotation" coordinate:location];
	[self.EventMapView addAnnotation:mapAnnotation];
	
	// Draw line here
	CLLocationCoordinate2D commuterLotCoords[4] = {
		CLLocationCoordinate2DMake(37.78688, -122.405398),
		CLLocationCoordinate2DMake(37.785012, -122.406428),
		CLLocationCoordinate2DMake(37.78391, -122.404604),
		CLLocationCoordinate2DMake(37.78608, -122.405398)
	};
	
	MKPolygon * poly = [MKPolygon polygonWithCoordinates:commuterLotCoords count:4];
	[self.EventMapView addOverlay:poly];
	*/
	
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
	MKPolygonView * polyView = [[MKPolygonView  alloc] initWithOverlay:overlay];
	polyView.lineWidth = 1;
	polyView.strokeColor = [UIColor blueColor];
	return polyView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	MKAnnotationView* annotationView = [views objectAtIndex:0];
	id<MKAnnotation> mp = [annotationView annotation];
	
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate], 250, 250);
	[self.EventMapView setRegion:region animated:YES];
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
