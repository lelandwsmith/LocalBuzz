//
//  MyEventDetailViewController.h
//  LocalBuzz
//
//  Created by Vincent Leung on 12/3/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapView.h"
#import "DDAnnotation.h"
#import "XMPPFramework.h"
#import "AddEventViewController.h"

@class Event;

@interface MyEventDetailViewController : UITableViewController <UIActionSheetDelegate, UIAlertViewDelegate, XMPPRoomDelegate, AddEventDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UILabel *locationTitle;
@property (nonatomic, strong) Event *event;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic) CLLocationCoordinate2D currentCoordinate;
@property (weak, nonatomic) IBOutlet UITableViewCell *LocationCell;
@property (nonatomic) NSInteger  numOfLines;
@property (nonatomic) NSString*  locatedAt;

@property (strong, nonatomic) UIActionSheet *actionSheet;
- (void)unwindAndRefresh;
@end


