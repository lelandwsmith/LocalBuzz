//
//  AddEventViewController.h
//  LocalBuzz
//
//  Created by Amanda Le on 10/24/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AddEventViewController : UIViewController< CLLocationManagerDelegate, MKMapViewDelegate> {
	
}
@property (weak, nonatomic) IBOutlet MKMapView *NewEventMapView;
@property (weak, nonatomic) CLLocationManager *locationManager;

@end
