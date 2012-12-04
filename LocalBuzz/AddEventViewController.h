//
//  AddEventViewController.h
//  LocalBuzz
//
//  Created by Vincent Leung on 10/24/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "XMPPFramework.h"
#import "Event.h"
@class AddEventViewController;
@protocol AddEventDelegate <NSObject>
- (void)addEventViewController:(AddEventViewController *)addEventViewController
                didEditedEvent:(Event *)event;
- (void)addEventViewController:(AddEventViewController *)addEventViewController
               didCreatedEvent:(Event *)event;
@end

@interface AddEventViewController : UITableViewController <UITextFieldDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, XMPPRoomDelegate>
@property (weak, nonatomic) id<AddEventDelegate> addEventDelegate;
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITableViewCell *latitudeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *startTimeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *endTimeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *location;
@property (weak, nonatomic) IBOutlet UISwitch *switcher;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (nonatomic) NSInteger categoryID;
@property (weak, nonatomic) IBOutlet UITextView *DescriptText;
@property (weak, nonatomic) IBOutlet UITableViewCell *LocationCell;
@property (weak, nonatomic) IBOutlet UILabel *LocationTitle;
@property (weak, nonatomic) IBOutlet UILabel *LocationLabel;
@property (nonatomic) NSInteger numOfLines;
@property (weak, nonatomic) IBOutlet UILabel *description;
@property (nonatomic) NSString *address;
- (IBAction)timeSelected:(UIStoryboardSegue *)segue;
- (IBAction)locationSelected:(UIStoryboardSegue *)segue;
- (void)textViewChange;
@property (nonatomic) NSInteger createOrEdit;
@property (weak, nonatomic) Event *eventToBeEdited;

@end

