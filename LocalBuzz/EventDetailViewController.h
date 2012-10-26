//
//  EventDetailViewController.h
//  LocalBuzz
//
//  Created by Vincent Leung on 10/25/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapViewAnnotation.h"

@class Event;

@interface EventDetailViewController : UITableViewController<CLLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic, strong) Event *event;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) NSArray *routes;

-(void) showRouteFrom: (MapViewAnnotation*) f to: (MapViewAnnotation*) t;

@end
