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

@interface AddEventViewController ()
{
	@private NSDate *startTime;
	@private NSDate *endTime;
	@private LocationSelectionViewController *locationSelector;
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
		
		CLGeocoder *geocoder = [[CLGeocoder alloc] init];
		
		//Geocoding Block
		[geocoder reverseGeocodeLocation: loc completionHandler:^(NSArray *placemarks, NSError *error) {
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
	if ([[segue identifier] isEqualToString:@"EventCreated"]) {
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
		NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
														self.titleField.text, @"event[title]",
														[dateFormatter stringFromDate:startTime], @"event[start_time]",
														[dateFormatter stringFromDate:endTime], @"event[end_time]",
														[[NSNumber numberWithDouble:locationSelector.latLong.longitude] stringValue], @"event[longitude]",
														[[NSNumber numberWithDouble:locationSelector.latLong.latitude] stringValue], @"event[latitude]",
														isPublic, @"event[public]",
															eventDescription, @"event[description]",
														nil];
		[httpClient postPath:@"/events.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *newEvent = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSNumber *newEventId = [newEvent objectForKey:@"id"];
            [self createEventChatRoom:newEventId];
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			NSLog(@"%@", [error localizedDescription]);
		}];
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
	[super viewDidLoad];
	[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewChange) name:UITextViewTextDidBeginEditingNotification object:self.DescriptText];
    
	self.categoryID = 1;
	[self.DescriptText setTextColor:[UIColor lightGrayColor]];
	self.titleField.delegate = self;
	self.tableView.delegate = self;
	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
	tapGestureRecognizer.cancelsTouchesInView = NO;
	[self.tableView addGestureRecognizer:tapGestureRecognizer];
    
}

- (void) viewDidUnload
{
	[super viewDidUnload];
}

- (IBAction)leftClickCategory:(id)sender
{
	self.categoryID--;
	if(self.categoryID<0) {
		self.categoryID+=5;
	}
	[self.categoryLabel setText:[NSString stringWithFormat:@"Category #%d",self.categoryID]];
}

- (IBAction)rightClickCategory:(id)sender
{
	self.categoryID++;
	if(self.categoryID>4) {
		self.categoryID-=5;
	}
	[self.categoryLabel setText:[NSString stringWithFormat:@"Category #%d",self.categoryID]];
}

- (IBAction)SwitchChange:(id)sender
{}

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
