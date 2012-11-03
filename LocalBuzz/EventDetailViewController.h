//
//  EventDetailViewController.h
//  LocalBuzz
//
//  Created by Vincent Leung on 10/25/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapView.h"
#import "DDAnnotation.h"

@class Event;

@interface EventDetailViewController : UITableViewController {
	
}

@property (nonatomic, strong) Event *event;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UITableViewCell *mapLable;
@property (nonatomic) CLLocationCoordinate2D currentCoordinate;

@end
