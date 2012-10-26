//
//  LocationSelectionViewController.h
//  LocalBuzz
//
//  Created by Amanda Le on 10/25/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationSelectionViewController : UIViewController< CLLocationManagerDelegate, MKMapViewDelegate> {
	
}
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D latLong;

@end
