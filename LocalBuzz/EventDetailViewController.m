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

-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) from to: (CLLocationCoordinate2D) to;
-(void) centerMap;

@end

@implementation EventDetailViewController
@synthesize titleLabel = _titleLabel;
@synthesize descriptionLabel = _descriptionLabel;
@synthesize timeLabel = _timeLabel;
@synthesize locationLabel = _locationLabel;
@synthesize mapView = _mapView;
@synthesize locationManager = _locationManager;
@synthesize routes = _routes;

- (void) setEvent:(Event *)event {
    if (_event != event) {
        _event = event;
        [self configureView];
    }
}

- (void) configureView {
    Event *theEvent = self.event;
    if (theEvent) {
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
        
        [self setUpMap];
    }
}

- (void) setUpMap {
    self.mapView.delegate = self;
	self.locationManager = [[CLLocationManager alloc] init];
	[self.locationManager setDelegate:self];
	[self.locationManager setDistanceFilter:kCLDistanceFilterNone];
	[self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
	[self.locationManager startUpdatingLocation];
	
	// Get the data of current location
	CLLocationCoordinate2D startCoordinate = CLLocationCoordinate2DMake(37.78700, -121.40400);
	MapViewAnnotation *startAnnotation = [[MapViewAnnotation alloc] initWithTitle:@"Start" coordinate:startCoordinate];
	[self.mapView addAnnotation:startAnnotation];
	
	// Fake the data of destination location
	CLLocationCoordinate2D endCoordinate = CLLocationCoordinate2DMake(37.78688, -122.405398);
	MapViewAnnotation *endAnnotation = [[MapViewAnnotation alloc] initWithTitle:@"Destination" coordinate:endCoordinate];
	[self.mapView addAnnotation:endAnnotation];
	
	[self showRouteFrom:startAnnotation to:endAnnotation];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self configureView];
}

- (NSMutableArray *)decodePolyLine: (NSMutableString *)encoded
{
	[encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\" options:NSLiteralSearch range:NSMakeRange(0, [encoded length])];
	NSInteger len = [encoded length];
	NSInteger index = 0;
	NSMutableArray *array = [[NSMutableArray alloc] init];
	NSInteger lat=0;
	NSInteger lng=0;
	while (index < len)
	{
		NSInteger b;
		NSInteger shift = 0;
		NSInteger result = 0;
		do
		{
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lat += dlat;
		shift = 0;
		result = 0;
		do
		{
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lng += dlng;
		NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
		NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
		CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
		[array addObject:loc];
	}
	
	return array;
}

-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t
{
	NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
	NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
	
	NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@", saddr, daddr];
	NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
	
	NSError* error = nil;
	
	NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl encoding:NSASCIIStringEncoding error:&error];
	NSString *tmp = @"points:\\\"([^\\\"]*)\\\"";
	NSString *encodedPoints = [apiResponse stringByMatching:tmp capture:1L];
	
	return [self decodePolyLine:[encodedPoints mutableCopy]];
}

-(void) centerMap
{
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
	
	[self.mapView setRegion:region animated:YES];
	
	MKPolyline * routeLine = [MKPolyline polylineWithPoints:points count:count];
	[self.mapView addOverlay:routeLine];
}

-(void) showRouteFrom: (MapViewAnnotation*) f to:(MapViewAnnotation*) t
{
	if(self.routes) {
        [self.mapView removeAnnotations:[self.mapView annotations]];
	}
	
	[self.mapView addAnnotation:f];
	[self.mapView addAnnotation:t];
	self.routes = [self calculateRoutesFrom:f.coordinate to:t.coordinate];
	[self centerMap];
}

#pragma mark MKPolyline delegate functions
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
	MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
	polylineView.fillColor = [UIColor blueColor];
	polylineView.strokeColor = [UIColor blueColor];
	polylineView.lineWidth = 3.0;
	polylineView.lineCap = kCGLineCapSquare;
	return polylineView;
}

@end