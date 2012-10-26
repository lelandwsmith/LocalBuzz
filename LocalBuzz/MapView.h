//
//  MapView.h
//  LocalBuzz
//
//  Created by Amanda Le on 10/25/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "RegexKitLite.h"
#import "MapViewAnnotation.h"

@interface MapView : UIView<MKMapViewDelegate> {
	
	MKMapView* mapView;
	UIImageView* routeView;
	NSArray* routes;
	UIColor* lineColor;
}

@property (nonatomic, retain) UIColor* lineColor;

-(void) showRouteFrom: (MapViewAnnotation*) f to:(MapViewAnnotation*) t;

@end
