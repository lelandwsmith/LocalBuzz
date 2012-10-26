//
//  CurrentEventViewController.h
//  LocalBuzz
//
//  Created by Amanda Le on 10/1/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EventDataController;

@interface CurrentEventViewController : UITableViewController

@property (strong, nonatomic) EventDataController *dataController;

-(IBAction)eventCreated:(UIStoryboardSegue *)segue;
@end
