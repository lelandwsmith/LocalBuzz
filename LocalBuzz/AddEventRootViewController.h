//
//  AddEventRootViewController.h
//  LocalBuzz
//
//  Created by Vincent Leung on 12/3/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "NavBarOrientationController.h"
#import "Event.h"
#import "AddEventViewController.h"
static const NSInteger kCreateEvent = 0;
static const NSInteger kEditEvent = 1;

@interface AddEventRootViewController : NavBarOrientationController
@property NSInteger createOrEdit;
@property (weak, nonatomic) Event *eventToBeEdited;
@property (weak, nonatomic) id <AddEventDelegate> delegatingVC;
@end
