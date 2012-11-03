//
//  MapView.m
//  LocalBuzz
//
//  Created by Amanda Le on 10/25/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "MapView.h"

@interface MapView()

-(NSMutableArray *)decodePolyLine: (NSMutableString *)encoded;
-(void) updateRouteView;
-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) from to: (CLLocationCoordinate2D) to;
-(void) centerMap;

@end

@implementation MapView

@synthesize mapView = _mapView;
@synthesize routeView = _routeView;
@synthesize routes = _routes;
@synthesize lineColor = _lineColor;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake
										(0, 0, frame.size.width, frame.size.height)];
		self.mapView.showsUserLocation = YES;
		[self.mapView setDelegate:self];
		[self addSubview:self.mapView];
		self.routeView = [[UIImageView alloc] initWithFrame:CGRectMake
											(0, 0, self.mapView.frame.size.width, self.mapView.frame.size.height)];
		self.routeView.userInteractionEnabled = NO;
		[self.mapView addSubview:self.routeView];
		
		self.lineColor = [UIColor redColor];
	}
	return self;
}

- (void)showRouteFrom: (DDAnnotation*) f to:(DDAnnotation*) t {
	
	if(self.routes) {
		[self.mapView removeAnnotations:[self.mapView annotations]];
	}
	
	[self.mapView addAnnotation:f];
	[self.mapView addAnnotation:t];
	
	// Get the route
	self.routes = [self calculateRoutesFrom:f.coordinate to:t.coordinate];
	// Draw the route
	[self updateRouteView];
	// Center the route in map
	[self centerMap];
}

- (NSArray*)calculateRoutesFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t {
	NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
	NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
	
	NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@", saddr, daddr];
	NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];

	NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl encoding:NSASCIIStringEncoding error:nil];
	NSString* encodedPoints = [apiResponse stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L];
	
	return [self decodePolyLine:[encodedPoints mutableCopy]];
}


- (NSMutableArray *)decodePolyLine: (NSMutableString *)encoded {
	[encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
															options:NSLiteralSearch
																range:NSMakeRange(0, [encoded length])];
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
		printf("[%f,", [latitude doubleValue]);
		printf("%f]", [longitude doubleValue]);
		CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue]
																								 longitude:[longitude floatValue]];
		[array addObject:loc];
	}
	
	return array;
}

- (void)updateRouteView
{
	CGContextRef context = 	CGBitmapContextCreate
	(nil, self.routeView.frame.size.width, self.routeView.frame.size.height, 8,
	 4 * self.routeView.frame.size.width, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
	
	CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
	CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
	CGContextSetLineWidth(context, 3.0);
	
	for(int i = 0; i < self.routes.count; i++) {
		CLLocation* location = [self.routes objectAtIndex:i];
		CGPoint point = [self.mapView convertCoordinate:location.coordinate toPointToView:self.routeView];
		
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

- (void)centerMap
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
	
	[self.mapView setRegion:region animated:YES];
}

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

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
