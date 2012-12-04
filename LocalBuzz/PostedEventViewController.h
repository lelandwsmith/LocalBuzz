//
//  PostedEventViewController.h
//  LocalBuzz
//
//  Created by Amanda Le on 11/12/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@class EventDataController;

@interface PostedEventViewController : UITableViewController

@property (strong, nonatomic) EventDataController *dataController;
- (void)refreshEvents;

@end
