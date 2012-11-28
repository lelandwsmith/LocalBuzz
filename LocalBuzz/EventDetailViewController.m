//
//  EventDetailViewController.m
//  LocalBuzz
//
//  Created by Vincent Leung on 10/25/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "EventDetailViewController.h"
#import "Event.h"
#import "RegexKitLite.h"
#import "ChatRoomViewController.h"

@interface EventDetailViewController ()

@end

@implementation EventDetailViewController
@synthesize titleLabel = _titleLabel;
@synthesize timeLabel = _timeLabel;
@synthesize locationLabel = _locationLabel;
@synthesize descriptionLabel = _descriptionLabel;
@synthesize mapLable = _mapLable;
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
	MapView *mapView = [[MapView alloc] initWithFrame:self.mapLable.bounds];
	[self.mapLable addSubview:mapView];
	
	// Get the start location
	CLLocationCoordinate2D startCoordinate = self.currentCoordinate;
	DDAnnotation *startAnnotation = [[DDAnnotation alloc] initWithCoordinate:startCoordinate addressDictionary:nil];
	
	// Get the destination location
	CLLocationCoordinate2D endCoordinate = CLLocationCoordinate2DMake([destLat doubleValue], [destLng doubleValue]);
	DDAnnotation *endAnnotation = [[DDAnnotation alloc] initWithCoordinate:endCoordinate addressDictionary:nil];
	
	[mapView showRouteFrom:startAnnotation to:endAnnotation];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowChatRoom"]) {
        ChatRoomViewController *chatRoomViewController = [segue destinationViewController];
        chatRoomViewController.hidesBottomBarWhenPushed = YES;
    }
}
@end