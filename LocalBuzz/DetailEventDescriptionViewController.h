//
//  DetailEventDescriptionViewController.h
//  LocalBuzz
//
//  Created by Amanda Le on 10/1/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface DetailEventDescriptionViewController : UIViewController<CLLocationManagerDelegate, MKMapViewDelegate> {
	
}
@property (nonatomic) int num;

@property (strong, nonatomic) IBOutlet MKMapView *EventMapView;
@property (weak, nonatomic) CLLocationManager * locationManager;

@end
