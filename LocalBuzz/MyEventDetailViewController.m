//
//  MyEventDetailViewController.m
//  LocalBuzz
//
//  Created by Vincent Leung on 12/3/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "MyEventDetailViewController.h"
#import "DDAnnotation.h"
#import "Event.h"
#import "AFHTTPClient.h"
#import "PostedEventViewController.h"
#import "LocalBuzzAppDelegate.h"
#import "AddEventRootViewController.h"

@interface MyEventDetailViewController ()

@end

@implementation MyEventDetailViewController

@synthesize titleLabel = _titleLabel;
@synthesize timeLabel = _timeLabel;
@synthesize locationLabel = _locationLabel;
@synthesize descriptionLabel = _descriptionLabel;
@synthesize mapView = _mapView;
@synthesize numOfLines =_numOfLines;
@synthesize currentCoordinate = _currentCoordinate;
@synthesize locationTitle = _locationTitle;
@synthesize locatedAt =_locatedAt;

- (void) setEvent:(Event *)event {
    if (_event != event) {
        _event = event;
        [self configureView];
    }
}

- (UIActionSheet *)actionSheet {
    if (_actionSheet == nil) {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Edit", nil];
    }
    return _actionSheet;
}

- (void) configureView {
	Event *theEvent = self.event;
	if (theEvent) {
		[self setUpMap:theEvent.latitude :theEvent.longitude];
		
		self.titleLabel.text = theEvent.title;
		self.descriptionLabel.text = theEvent.detailDescription;
		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		self.timeLabel.text = [dateFormatter stringFromDate:theEvent.startTime];
		
		CLLocation *loc = [[CLLocation alloc] initWithLatitude:[theEvent.latitude doubleValue] longitude:[theEvent.longitude doubleValue]];
		CLGeocoder *geocoder = [[CLGeocoder alloc] init];
		
		//Geocoding Block
		[geocoder reverseGeocodeLocation: loc completionHandler:^(NSArray *placemarks, NSError *error) {
			//Get nearby address
			CLPlacemark *placemark = [placemarks objectAtIndex:0];
			
			//String to hold address
			self.locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
			
			//Set the label text to current location
            self.numOfLines = self.locatedAt.length/25+1;
            
			[self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
		}];
	}
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if((indexPath.section==0)&&(indexPath.row==2)){
        if(self.numOfLines>1){
            [self.LocationCell.detailTextLabel setNumberOfLines:self.numOfLines];
            [self.LocationCell.detailTextLabel setText:self.locatedAt];
            return ((self.numOfLines - 1 )*21+44);
        }
    } else if (indexPath.section == 1){
        return 224;
    }
    return 44;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell_%d_%d",indexPath.section,indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSLog(@"reconstruct for section #%d, row #%d",indexPath.section,indexPath.row);
        
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        if((indexPath.row==2)&&(self.numOfLines>1)){
            NSLog(@"calling");
            
        }
        //cell.reuseIdentifier = CellIdentifier;
    }
    //config the cell
    return cell;
}

- (void) setUpMap:(NSNumber *)destLat :(NSNumber *)destLng {
	CLLocationCoordinate2D endCoordinate = CLLocationCoordinate2DMake([destLat doubleValue], [destLng doubleValue]);
    self.mapView.showsUserLocation = NO;
    DDAnnotation *endAnnotation = [[DDAnnotation alloc] initWithCoordinate:endCoordinate addressDictionary:nil];
    [self.mapView addAnnotation:endAnnotation];
    self.mapView.scrollEnabled = YES;
    self.mapView.region = MKCoordinateRegionMakeWithDistance(endCoordinate, 1000, 1000);
    [self.mapView setCenterCoordinate:endCoordinate animated:YES];
}


- (void) viewDidLoad {
    [super viewDidLoad];
    [self configureView];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
- (IBAction)editButtonPressed:(id)sender {
    [self.actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (XMPPStream *)xmppStream {
    LocalBuzzAppDelegate *appDelegate = (LocalBuzzAppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.xmppStream;
}

- (void)deleteEvent {
    NSURL *host = [NSURL URLWithString:@"http://localbuzz.vforvincent.info"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:host];
    NSString *deletePath = [@"/events/" stringByAppendingString:[self.event.eventId stringValue]];
    [httpClient deletePath:deletePath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"deleted");
        NSString *roomJIDUser = [@"event_" stringByAppendingString:[self.event.eventId stringValue]];
        XMPPRoomHybridStorage *roomStorage = [XMPPRoomHybridStorage sharedInstance];
        NSString *roomDomain = [@"conference." stringByAppendingString:[[self xmppStream] hostName]];
        XMPPJID *roomJID = [XMPPJID jidWithUser:roomJIDUser domain:roomDomain resource:nil];
        XMPPRoom *chatRoom = [[XMPPRoom alloc] initWithRoomStorage:roomStorage jid:roomJID];
        [chatRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [chatRoom activate:[self xmppStream]];
        [chatRoom destoryRoom];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (void)editEvent {
    [self performSegueWithIdentifier:@"EditEvent" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EditEvent"]) {
        AddEventRootViewController *navVC = [segue destinationViewController];
        navVC.createOrEdit = kEditEvent;
        navVC.eventToBeEdited = self.event;
        navVC.delegatingVC = self;
    }
}

- (void)unwindAndRefresh {
    NSUInteger numControllers = [self.navigationController.viewControllers count];
    PostedEventViewController *prevVC = (PostedEventViewController *)[self.navigationController.viewControllers objectAtIndex:numControllers - 2];
    [prevVC refreshEvents];
    [[self navigationController] popViewControllerAnimated:YES];
}

////////////////
#pragma mark - UIActionSheetDelegate
///////////////
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"Button pressed: %d", buttonIndex);
    UIAlertView *alert;
    switch (buttonIndex) {
        case 0:
            alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Do you really want to delete this event?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [alert show];
            break;
        case 1:
            [self editEvent];
        default:
            break;
    }
}

/////////////////
#pragma mark - UIAlertViewDelegate
/////////////////

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"pressed: %d", buttonIndex);
    switch (buttonIndex) {
        case 1:
            [self deleteEvent];
            break;
        default:
            break;
    }
    
}

//////////////////
#pragma mark - XMPPRoomDelegate
/////////////////
- (void)xmppRoomDidDestroy:(XMPPRoom *)sender {
    [self unwindAndRefresh];
}

/////////////////
#pragma mark - AddEventDelegate
/////////////////
- (void)addEventViewController:(AddEventViewController *)addEventViewController didEditedEvent:(Event *)event {
    [self unwindAndRefresh];
}

@end
