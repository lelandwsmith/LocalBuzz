//
//  PastEventViewController.h
//  LocalBuzz
//
//  Created by Amanda Le on 10/1/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "EventDataController.h"

@interface PastEventViewController : UITableViewController <CLLocationManagerDelegate>
@property (strong, nonatomic) EventDataController *dataController;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end
