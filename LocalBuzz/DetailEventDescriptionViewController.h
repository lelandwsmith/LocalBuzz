//
//  DetailEventDescriptionViewController.h
//  LocalBuzz
//
//  Created by Amanda Le on 10/1/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MapViewAnnotation.h"

@interface DetailEventDescriptionViewController : UIViewController<CLLocationManagerDelegate, MKMapViewDelegate> {
	
}
@property (nonatomic) int num;

@property (strong, nonatomic) IBOutlet MKMapView *EventMapView;
@property (weak, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) NSArray *routes;
@property (weak, nonatomic) UIImageView *routeView;

-(void) showRouteFrom: (MapViewAnnotation*) f to:(MapViewAnnotation*) t;

@end
