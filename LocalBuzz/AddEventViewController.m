//
//  AddEventViewController.m
//  LocalBuzz
//
//  Created by Vincent Leung on 10/24/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "AddEventViewController.h"
#import "TimePickerViewController.h"
#import "LocationSelectionViewController.h"
#import "AFHTTPClient.h"
#import "XMPPFramework.h"
#import "LocalBuzzAppDelegate.h"
#import "AddEventRootViewController.h"
#import "MyEventDetailViewController.h"

@interface AddEventViewController ()
{
	@private NSDate *startTime;
	@private NSDate *endTime;
	@private LocationSelectionViewController *locationSelector;
    @private NSDictionary *eventCategory;
}
@end

@implementation AddEventViewController
@synthesize titleField = _titleField;
@synthesize LocationCell = _LocationCell;
@synthesize LocationLabel = _LocationLabel;
@synthesize LocationTitle = _LocationTitle;
@synthesize latitudeCell = _latitudeCell;
@synthesize startTimeCell = _startTimeCell;
@synthesize endTimeCell = _endTimeCell;
@synthesize location = _location;
@synthesize switcher = _switcher;
@synthesize categoryID =_categoryID;
@synthesize DescriptText = _DescriptText;
@synthesize address = _address;
@synthesize categoryLabel = _categoryLabel;


- (Event *)eventToBeEdited {
    if (_eventToBeEdited == nil) {
        AddEventRootViewController *rootVC = (AddEventRootViewController *) self.navigationController;
        _eventToBeEdited = rootVC.eventToBeEdited;
    }
    return _eventToBeEdited;
}

- (NSInteger)createOrEdit {
    AddEventRootViewController *rootVC = (AddEventRootViewController *) self.navigationController;
    _createOrEdit = rootVC.createOrEdit;
    return _createOrEdit;
}

- (IBAction)cancelPressed:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)timeSelected:(UIStoryboardSegue *)segue
{
	if ([[segue identifier] isEqualToString:@"ReturnTime"]) {
		TimePickerViewController *timePicker = [segue sourceViewController];
		NSDate *pickedTime = timePicker.timePicker.date;
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		if (timePicker.timepickerMode == PickStartTime) {
			startTime = pickedTime;
			self.startTimeCell.detailTextLabel.text = [dateFormatter stringFromDate:startTime];
		}
		else if (timePicker.timepickerMode == PickEndtime) {
			endTime = pickedTime;
			self.endTimeCell.detailTextLabel.text = [dateFormatter stringFromDate:endTime];
		}
	}
}

- (IBAction)locationSelected:(UIStoryboardSegue *)segue
{
	if ([[segue identifier] isEqualToString:@"ReturnLocation"]) {
		locationSelector = [segue sourceViewController];
		CLLocationCoordinate2D selectedLatLong = locationSelector.latLong;
		CLLocation *loc = [[CLLocation alloc] initWithLatitude:selectedLatLong.latitude longitude:selectedLatLong.longitude];
		
		[self showAddress:loc];
	}
}

- (void)showAddress:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    //Geocoding Block
    [geocoder reverseGeocodeLocation: location completionHandler:^(NSArray *placemarks, NSError *error) {
        //Get nearby address
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
		
        //String to hold address
        self.address = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
		
        //Print the location to console
        NSLog(@"size of string is %d",self.address.length);
        self.numOfLines = self.address.length/25+1;
		
        [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForSelectedRows] withRowAnimation:UITableViewRowAnimationNone];
        NSLog(@"numOFline %d",self.numOfLines);
    }];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if((indexPath.section == 1) && (indexPath.row == 0)){
  	if(self.numOfLines > 1){
			[self.LocationCell.detailTextLabel setNumberOfLines:self.numOfLines];
			[self.LocationCell.detailTextLabel setText:self.address];
			return ((self.numOfLines - 1 )*21+44);
		}
	}
	else if(indexPath.section == 5){
		return 75;
	}
	return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *CellIdentifier = [NSString stringWithFormat:@"Cell_%d_%d",indexPath.section,indexPath.row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		NSLog(@"reconstruct for section #%d, row #%d",indexPath.section,indexPath.row);
		cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
			//cell.reuseIdentifier = CellIdentifier;
	}
	
	//config the cell
	//if (indexPath.section == 1 && self.numOfLines > 1) {
		//[self.LocationTitle setFrame:CGRectMake(10, 43, 75, 21)];
	//}
	return cell;
}

- (IBAction)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([[segue identifier] isEqualToString:@"SelectStartTime"]) {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		startTime = [dateFormatter dateFromString:self.startTimeCell.detailTextLabel.text];
		NSLog(@"%@", [startTime description]);
		TimePickerViewController *timePickerController = segue.destinationViewController;
		timePickerController.timeToDisplay = startTime;
		timePickerController.minimumDate = [[NSDate date] dateByAddingTimeInterval:-300];
		timePickerController.timepickerMode = PickStartTime;
	}
	if ([[segue identifier] isEqualToString:@"SelectEndTime"]) {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		endTime = [dateFormatter dateFromString:self.endTimeCell.detailTextLabel.text];
		NSLog(@"%@", [endTime description]);
		TimePickerViewController *timePickerController = segue.destinationViewController;
		timePickerController.timeToDisplay = endTime;
		timePickerController.minimumDate = startTime;
		timePickerController.timepickerMode = PickEndtime;
	}
}

- (void)createEventChatRoom:(NSNumber *)eventId {
    NSString *roomJIDUser = [@"event_" stringByAppendingString:[eventId stringValue]];
    XMPPRoomHybridStorage *roomStorage = [XMPPRoomHybridStorage sharedInstance];
    NSString *roomDomain = [@"conference." stringByAppendingString:[[self xmppStream] hostName]];
    XMPPJID *roomJID = [XMPPJID jidWithUser:roomJIDUser domain:roomDomain resource:nil];
    XMPPRoom *chatRoom = [[XMPPRoom alloc] initWithRoomStorage:roomStorage jid:roomJID];
    [chatRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [chatRoom activate:[self xmppStream]];
    [chatRoom joinRoomUsingNickname:@"owner" fromJID:[[self xmppStream] myJID] history:nil];
}

- (LocalBuzzAppDelegate *)appDelegate {
    return (LocalBuzzAppDelegate *) [[UIApplication sharedApplication] delegate];
}

- (XMPPStream *) xmppStream {
    return [self appDelegate].xmppStream;
}
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
	[self.DescriptText setText:@""];
	[self.DescriptText setTextColor:[UIColor blueColor]];
	return YES;
}

-(void)textViewChange
{
	[self textViewShouldBeginEditing:self.DescriptText];
}

- (void) viewDidLoad
{
    eventCategory = [NSDictionary dictionaryWithObjectsAndKeys:
                     @"Entertainment", [NSNumber numberWithInt:0],
                     @"Sport", [NSNumber numberWithInteger:1],
                     @"Academic", [NSNumber numberWithInt:2],
                     @"Work", [NSNumber numberWithInt:3],
                     @"Charity", [NSNumber numberWithInt:4],
                     @"Other", [NSNumber numberWithInt:5],
                     nil];
	[super viewDidLoad];
	[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewChange) name:UITextViewTextDidBeginEditingNotification object:self.DescriptText];
    
	self.categoryID = 0;
    [self.categoryLabel setText:[eventCategory objectForKey:[NSNumber numberWithInteger:self.categoryID]]];
	[self.DescriptText setTextColor:[UIColor lightGrayColor]];
	self.titleField.delegate = self;
	self.tableView.delegate = self;
	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
	tapGestureRecognizer.cancelsTouchesInView = NO;
	[self.tableView addGestureRecognizer:tapGestureRecognizer];
    if (self.createOrEdit == kEditEvent) {
        [self loadEvent];
        self.title = @"Edit";
    }
    AddEventRootViewController *rootVC = (AddEventRootViewController *)self.navigationController;
    self.addEventDelegate = rootVC.delegatingVC;
}

- (void)loadEvent {
    self.titleField.text = self.eventToBeEdited.title;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[self.eventToBeEdited.latitude doubleValue] longitude:[self.eventToBeEdited.longitude doubleValue]];
    [self showAddress:location];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    self.startTimeCell.detailTextLabel.text = [formatter stringFromDate:self.eventToBeEdited.startTime];
    startTime = self.eventToBeEdited.startTime;
    self.endTimeCell.detailTextLabel.text = [formatter stringFromDate:self.eventToBeEdited.endTime];
    endTime = self.eventToBeEdited.endTime;
    self.switcher.on = self.eventToBeEdited.isPublic;
    NSLog(@"Event public: %d", self.eventToBeEdited.isPublic);
    NSLog(@"Public: %d", self.switcher.on);
    self.DescriptText.text = self.eventToBeEdited.detailDescription;
    self.categoryID = [self.eventToBeEdited.category integerValue];
    self.categoryLabel.text = [eventCategory objectForKey:[NSNumber numberWithInteger:self.categoryID]];
    NSLog(@"Category: %@", [eventCategory objectForKey:self.eventToBeEdited.category]);
}

- (void) viewDidUnload
{
	[super viewDidUnload];
}

- (IBAction)leftClickCategory:(id)sender
{
	self.categoryID--;
    self.categoryID %= 6;
    if (self.categoryID < 0) {
        self.categoryID += 6;
    }
	[self.categoryLabel setText:[eventCategory objectForKey:[NSNumber numberWithInteger:self.categoryID]]];
    NSLog(@"%d", self.categoryID);
}

- (IBAction)rightClickCategory:(id)sender
{
	self.categoryID++;
    self.categoryID %= 6;
	[self.categoryLabel setText:[eventCategory objectForKey:[NSNumber numberWithInteger:self.categoryID]]];
    NSLog(@"%d", self.categoryID);
}

- (IBAction)SwitchChange:(id)sender
{}

- (IBAction)savePressed:(id)sender {
    NSURL *createUserURL = [NSURL URLWithString:@"http://localbuzz.vforvincent.info/"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:createUserURL];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSNumber *isPublic = [[NSNumber alloc] initWithBool:self.switcher.isOn];
    NSString *eventDescription;
    if ([self.DescriptText.text isEqualToString:@"Tap to edit"]) {
        eventDescription = @"";
    } else {
        eventDescription = self.DescriptText.text;
    }
    NSDictionary *params;
    if (self.createOrEdit == kCreateEvent) {
        params = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.titleField.text, @"event[title]",
                                [dateFormatter stringFromDate:startTime], @"event[start_time]",
                                [dateFormatter stringFromDate:endTime], @"event[end_time]",
                                [[NSNumber numberWithDouble:locationSelector.latLong.longitude] stringValue], @"event[longitude]",
                                [[NSNumber numberWithDouble:locationSelector.latLong.latitude] stringValue], @"event[latitude]",
                                isPublic, @"event[public]",
                                eventDescription, @"event[description]",
                                [[NSUserDefaults standardUserDefaults] objectForKey:@"fb_id"], @"event[owner]",
                                [NSNumber numberWithInteger:self.categoryID], @"event[category]",
                                nil];
        [httpClient postPath:@"/events.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *newEvent = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSNumber *newEventId = [newEvent objectForKey:@"id"];
            [self createEventChatRoom:newEventId];
            [[self addEventDelegate] addEventViewController:self didCreatedEvent:[[Event alloc] initWithDictionary:newEvent]];
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			NSLog(@"%@", [error localizedDescription]);
		}];
    } else if (self.createOrEdit == kEditEvent) {
        params = [NSDictionary dictionaryWithObjectsAndKeys:
                  self.titleField.text, @"event[title]",
                  [dateFormatter stringFromDate:startTime], @"event[start_time]",
                  [dateFormatter stringFromDate:endTime], @"event[end_time]",
                  self.eventToBeEdited.longitude, @"event[longitude]",
                  self.eventToBeEdited.latitude, @"event[latitude]",
                  isPublic, @"event[public]",
                  eventDescription, @"event[description]",
                  [[NSUserDefaults standardUserDefaults] objectForKey:@"fb_id"], @"event[owner]",
                  [NSNumber numberWithInteger:self.categoryID], @"event[category]",
                  nil];
        NSLog(@"%@", params);
        NSString *putPath = [[@"/events/" stringByAppendingString:[self.eventToBeEdited.eventId stringValue]] stringByAppendingString:@".json"];
        [httpClient putPath:putPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            Event *editedEvent = [[Event alloc] initWithDictionary:response];
            [[self addEventDelegate] addEventViewController:self didEditedEvent:editedEvent];
            NSLog(@"%@", response);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error.localizedDescription);
        }];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) hideKeyboard
{
	[self.titleField resignFirstResponder];
	[self.DescriptText resignFirstResponder];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
	return [textField resignFirstResponder];
}

/////////////////////
#pragma mark XMPPRoomDelegate
/////////////////////
- (void)xmppRoomDidCreate:(XMPPRoom *)sender {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}


@end
