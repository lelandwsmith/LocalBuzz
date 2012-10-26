//
//  DetailEventDescriptionViewController.m
//  LocalBuzz
//
//  Created by Amanda Le on 10/1/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "DetailEventDescriptionViewController.h"
#import "RegexKitLite.h"

#define MINIMUM_ZOOM_ARC 0.014 //approximately 1 miles (1 degree of arc ~= 69 miles)
#define ANNOTATION_REGION_PAD_FACTOR 1.15
#define MAX_DEGREES_ARC 360


@interface DetailEventDescriptionViewController ()

-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) from to: (CLLocationCoordinate2D) to;
-(void) updateRouteView;
-(void) centerMap;

@end

@implementation DetailEventDescriptionViewController
@synthesize num = _num;
@synthesize EventMapView = _EventMapView;
@synthesize locationManager = _locationManager;
@synthesize routes = _routes;
@synthesize routeView = _routeView;


/*- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
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
	[self.locationManager startUpdatingLocation];
	
	self.routeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.EventMapView.frame.size.width, self.EventMapView.frame.size.height)];
	self.routeView.userInteractionEnabled = NO;
	[self.EventMapView addSubview:self.routeView];
	
	//self.EventMapView.showsUserLocation = YES;
	//self.EventMapView.mapType = MKMapTypeStandard;
	//self.EventMapView.mapType = MKMapTypeSatellite;
	//self.EventMapView.mapType = MKMapTypeHybrid;
	
	// Get the data of current location
	//CLLocation *startLocation = [self.locationManager location];
	//CLLocationCoordinate2D startCoordinate = [startLocation coordinate];
	CLLocationCoordinate2D startCoordinate = CLLocationCoordinate2DMake(37.78700, -121.40400);
	MapViewAnnotation *startAnnotation = [[MapViewAnnotation alloc] initWithTitle:@"Start" coordinate:startCoordinate];
	[self.EventMapView addAnnotation:startAnnotation];
	
	// Fake the data of destination location, and add pin to map
	CLLocationCoordinate2D endCoordinate = CLLocationCoordinate2DMake(37.78688, -122.405398);
	MapViewAnnotation *endAnnotation = [[MapViewAnnotation alloc] initWithTitle:@"Destination" coordinate:endCoordinate];
	[self.EventMapView addAnnotation:endAnnotation];
	
	
	NSLog(@"routes size is %i", self.routes.count);
	[self showRouteFrom:startAnnotation to:endAnnotation];
	NSLog(@"routes size is %i", self.routes.count);
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

-(void) showRouteFrom: (MapViewAnnotation*) f to:(MapViewAnnotation*) t
{
	if(self.routes) {
    [self.EventMapView removeAnnotations:[self.EventMapView annotations]];
	}
	
	//[self.EventMapView addAnnotation:f];
	//[self.EventMapView addAnnotation:t];
	
	// Get the route
	self.routes = [self calculateRoutesFrom:f.coordinate to:t.coordinate];
	/*
	 NSInteger numberOfSteps = self.routes.count;
	 
	 CLLocationCoordinate2D coordinates[numberOfSteps];
	 for (NSInteger index = 0; index < numberOfSteps; index++) {
	 CLLocation *location = [self.routes objectAtIndex:index];
	 CLLocationCoordinate2D coordinate = location.coordinate;
	 coordinates[index] = coordinate;
	 }
	 MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:numberOfSteps];
	 [self.EventMapView addOverlay:polyLine];
	 */
	
	// Draw the route
	[self updateRouteView];
	// Center the map to show route properly
	[self centerMap];
}

-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t
{
	NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
	NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
	
	NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@", saddr, daddr];
	NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
	
	NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl];
	NSString* encodedPoints = [apiResponse stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L];
	
	return [self decodePolyLine:[encodedPoints mutableCopy]];
}

- (NSMutableArray *)decodePolyLine: (NSMutableString *)encoded
{
	[encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\" options:NSLiteralSearch range:NSMakeRange(0, [encoded length])];
	NSInteger len = [encoded length];
	NSInteger index = 0;
	NSMutableArray *array = [[NSMutableArray alloc] init];
	NSInteger lat=0;
	NSInteger lng=0;
	while (index < len) {
		NSInteger b;
		NSInteger shift = 0;
		NSInteger result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lat += dlat;
		shift = 0;
		result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lng += dlng;
		NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
		NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
		//printf("[%f,", [latitude doubleValue]);
		//printf("%f]", [longitude doubleValue]);
		CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
		[array addObject:loc];
	}
	
	return array;
}

-(void) centerMap
{
	MKCoordinateRegion region;
	
	CLLocationDegrees maxLat = -90;
	CLLocationDegrees maxLon = -180;
	CLLocationDegrees minLat = 90;
	CLLocationDegrees minLon = 180;
	for(int idx = 0; idx < self.routes.count; idx++)
	{
		CLLocation* currentLocation = [self.routes objectAtIndex:idx];
		if(currentLocation.coordinate.latitude > maxLat)
			maxLat = currentLocation.coordinate.latitude;
		if(currentLocation.coordinate.latitude < minLat)
			minLat = currentLocation.coordinate.latitude;
		if(currentLocation.coordinate.longitude > maxLon)
			maxLon = currentLocation.coordinate.longitude;
		if(currentLocation.coordinate.longitude < minLon)
			minLon = currentLocation.coordinate.longitude;
	}
	region.center.latitude     = (maxLat + minLat) / 2;
	region.center.longitude    = (maxLon + minLon) / 2;
	region.span.latitudeDelta  = maxLat - minLat;
	region.span.longitudeDelta = maxLon - minLon;
	
	[self.EventMapView setRegion:region animated:YES];

	
	/*
	//NSArray *annotations = mapView.annotations;
	int count = self.routes.count;
	if ( count == 0) { return; } //bail if no annotations
	
	//convert NSArray of id <MKAnnotation> into an MKCoordinateRegion that can be used to set the map size
	//can't use NSArray with MKMapPoint because MKMapPoint is not an id
	MKMapPoint points[count]; //C array of MKMapPoint struct
	for( int i=0; i<count; i++ ) //load points C array by converting coordinates to points
	{
		CLLocation *loc = [self.routes objectAtIndex:i];
		points[i] = MKMapPointForCoordinate([loc coordinate]);
	}
	
	//create MKMapRect from array of MKMapPoint
	MKMapRect mapRect = [[MKPolygon polygonWithPoints:points count:count] boundingMapRect];

	//convert MKCoordinateRegion from MKMapRect
	MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
	
	//add padding so pins aren't scrunched on the edges
	region.span.latitudeDelta  *= ANNOTATION_REGION_PAD_FACTOR;
	region.span.longitudeDelta *= ANNOTATION_REGION_PAD_FACTOR;
	
	//but padding can't be bigger than the world
	if( region.span.latitudeDelta > MAX_DEGREES_ARC )
	{ region.span.latitudeDelta  = MAX_DEGREES_ARC; }

	if( region.span.longitudeDelta > MAX_DEGREES_ARC )
	{ region.span.longitudeDelta = MAX_DEGREES_ARC; }
	
	//and don't zoom in stupid-close on small samples
	if( region.span.latitudeDelta  < MINIMUM_ZOOM_ARC )
	{ region.span.latitudeDelta  = MINIMUM_ZOOM_ARC; }

	if( region.span.longitudeDelta < MINIMUM_ZOOM_ARC )
	{ region.span.longitudeDelta = MINIMUM_ZOOM_ARC; }

	//and if there is a sample of 1 we want the max zoom-in instead of max zoom-out
	if( count == 1 ) {
		region.span.latitudeDelta = MINIMUM_ZOOM_ARC;
		region.span.longitudeDelta = MINIMUM_ZOOM_ARC;
	}
	
	[self.EventMapView setRegion:region animated:YES];
	
	
	MKPolyline * routeLine = [MKPolyline polylineWithPoints:points count:count];
	[self.EventMapView addOverlay:routeLine];
	*/
}

-(void) updateRouteView {
	CGContextRef context = CGBitmapContextCreate(nil,
																							 self.routeView.frame.size.width,
																							 self.routeView.frame.size.height,
																							 8,
																							 4 * self.routeView.frame.size.width,
																							 CGColorSpaceCreateDeviceRGB(),
																							 kCGImageAlphaPremultipliedLast);
	
	CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
	CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
	CGContextSetLineWidth(context, 3.0);
	
	for(int i = 0; i < self.routes.count; i++) {
		CLLocation* location = [self.routes objectAtIndex:i];
		CGPoint point = [self.EventMapView convertCoordinate:location.coordinate toPointToView:self.routeView];
		
		if(i == 0) {
			CGContextMoveToPoint(context, point.x, self.routeView.frame.size.height - point.y);
		} else {
			CGContextAddLineToPoint(context, point.x, self.routeView.frame.size.height - point.y);
		}
	}
	
	CGContextStrokePath(context);
	
	CGImageRef image = CGBitmapContextCreateImage(context);
	UIImage* img = [UIImage imageWithCGImage:image];
	
	self.routeView.image = img;
	CGContextRelease(context);	
}

/*
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	MKAnnotationView* annotationView = [views objectAtIndex:0];
	id<MKAnnotation> mp = [annotationView annotation];
	
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate], 10000, 10000);
	[self.EventMapView setRegion:region animated:YES];
}
 */

#pragma mark mapView delegate functions
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
	self.routeView.hidden = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	[self updateRouteView];
	self.routeView.hidden = NO;
	[self.routeView setNeedsDisplay];
}

/*#pragma mark MKPolyline delegate functions
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
	MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
	polylineView.fillColor = [UIColor blueColor];
	polylineView.strokeColor = [UIColor blueColor];
	polylineView.lineWidth = 3.0;
	polylineView.lineCap = kCGLineCapSquare;
	return polylineView;
}*/

@end
