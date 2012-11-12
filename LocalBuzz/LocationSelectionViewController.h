//
//  LocationSelectionViewController.h
//  LocalBuzz
//
//  Created by Amanda Le on 10/25/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface LocationSelectionViewController : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate> {
	
}
@property (retain, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D latLong;
@property (nonatomic) CLGeocoder *geoCoder;
@property (nonatomic) NSString *address;

- (IBAction)geoCodeLocation:(UIBarButtonItem *)sender;

@end
