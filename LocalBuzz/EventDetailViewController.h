//
//  EventDetailViewController.h
//  LocalBuzz
//
//  Created by Vincent Leung on 10/25/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapView.h"
#import "MapViewAnnotation.h"

@class Event;

@interface EventDetailViewController : UITableViewController <CLLocationManagerDelegate>

@property (nonatomic, strong) Event *event;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *mapLable;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end
