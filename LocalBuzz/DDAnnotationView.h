//
//  DDAnnotationView.h
//  LocalBuzz
//
//  Created by Amanda Le on 10/26/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface DDAnnotationView : MKAnnotationView {
@private
	MKMapView *mapView_;
	
	BOOL isMoving_;
	CGPoint startLocation_;
	CGPoint originalCenter_;
	UIImageView *pinShadow_;
	NSTimer *pinTimer_;
}

// Please use this class method to create DDAnnotationView (on iOS 3) or built-in draggble MKPinAnnotationView (on iOS 4).
+ (id)annotationViewWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier mapView:(MKMapView *)mapView;

@end
