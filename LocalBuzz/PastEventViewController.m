//
//  PastEventViewController.m
//  LocalBuzz
//
//  Created by Amanda Le on 10/1/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "PastEventViewController.h"
#import "EventDetailViewController.h"
#import "EventDetailViewController.h"
#import "AFHTTPClient.h"
#import "Event.h"
#import "LocalBuzzTableCellController.h"

@interface PastEventViewController ()

@end

@implementation PastEventViewController
@synthesize dataController;
@synthesize locationManager = _locationManager;

#define kGetPastEvents 1

- (CLLocationManager *) locationManager {
	if (_locationManager == nil) {
		_locationManager = [[CLLocationManager alloc] init];
		if ([CLLocationManager locationServicesEnabled]) {
			_locationManager.delegate = self;
			_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
			_locationManager.distanceFilter = kCLDistanceFilterNone;
		}
	}
	return _locationManager;
}

- (void) awakeFromNib {
	[super awakeFromNib];
	self.dataController = [[EventDataController alloc] init];
}

- (id)initWithStyle:(UITableViewStyle)style {
	self = [super initWithStyle:style];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad {
	UIImage *selectedImage0 = [UIImage imageNamed:@"73-radar-select.png"];
	UIImage *unselectedImage0 = [UIImage imageNamed:@"73-radar.png"];
	
	UIImage *selectedImage1 = [UIImage imageNamed:@"28-star-select.png"];
	UIImage *unselectedImage1 = [UIImage imageNamed:@"28-star.png"];
	
	UIImage *selectedImage2 = [UIImage imageNamed:@"19-gear-select.png"];
	UIImage *unselectedImage2 = [UIImage imageNamed:@"19-gear.png"];
	
	UITabBar *tabBar = self.tabBarController.tabBar;
	UITabBarItem *item0 = [tabBar.items objectAtIndex:0];
	UITabBarItem *item1 = [tabBar.items objectAtIndex:1];
	UITabBarItem *item2 = [tabBar.items objectAtIndex:2];
	
	[item0 setFinishedSelectedImage:selectedImage0 withFinishedUnselectedImage:unselectedImage0];
	[item1 setFinishedSelectedImage:selectedImage1 withFinishedUnselectedImage:unselectedImage1];
	[item2 setFinishedSelectedImage:selectedImage2 withFinishedUnselectedImage:unselectedImage2];
	
	[[UIBarButtonItem appearance] setTintColor:[[UIColor alloc]initWithRed:227.0/255.0 green:110.0/255.0 blue:81.0/255.0 alpha:0.3]];
	
	[super viewDidLoad];
	[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
	[self.tabBarController.tabBar setBackgroundImage:[UIImage imageNamed:@"tabbar.png"]];
    
	// Uncomment the following line to preserve selection between presentations.
	// self.clearsSelectionOnViewWillAppear = NO;
    
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	// self.navigationItem.rightBarButtonItem = self.editButtonItem;
	[self.locationManager startUpdatingLocation];
	UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
	refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to refresh"];
	[refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
	self.refreshControl = refresh;
	//self.view.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:202.0f/255.0f blue:84.0f/255.0f alpha:1.0f];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (IBAction)eventCreated:(UIStoryboardSegue *)segue {
	if ([segue.identifier isEqualToString:@"EventCreated"]) {
		[self refreshEvents];
	}
}

- (void) refreshEvents {
	NSURL *url = [NSURL URLWithString:@"http://localbuzz.vforvincent.info"];
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
	CLLocationCoordinate2D currentCoord = [[self.locationManager location] coordinate];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"];
	dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
													[NSNumber numberWithDouble:currentCoord.latitude], @"lat",
													[NSNumber numberWithDouble:currentCoord.longitude], @"lng",
													[dateFormatter stringFromDate:[NSDate date]], @"time",
													[[NSUserDefaults standardUserDefaults] valueForKey:@"range"], @"range",
													[NSNumber numberWithInteger:kGetPastEvents], @"past",
													nil];
	//NSLog(@"%@", params);
	NSLog(@"current is %@ |%@",[NSNumber numberWithDouble:currentCoord.latitude],[NSNumber numberWithDouble:currentCoord.longitude]);
	[httpClient getPath:@"events.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		[self.dataController emptyEventList];
		NSDictionary *events = [NSJSONSerialization JSONObjectWithData:responseObject options: NSJSONReadingMutableContainers error:nil];
		NSEnumerator *enumerator = [events objectEnumerator];
		id value;
		while (value = [enumerator nextObject]) {
			Event *eventToBeAdded = [[Event alloc] initWithDictionary:value];
			[self.dataController addEventToEventList:eventToBeAdded];
		}
		[self.tableView reloadData];
		events = nil;
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"%@", [error localizedDescription]);
	}];
}

- (void)refreshView:(UIRefreshControl *)refresh {
	[self.locationManager startUpdatingLocation];
	refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing events..."];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"MMM d, h:mm a"];
	NSString *lastUpdate = [NSString stringWithFormat:@"Last updated at: %@", [formatter stringFromDate:[NSDate date]]];
	refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdate];
	[refresh endRefreshing];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	if ([locations count] > 1) {
		CLLocation *latest = [locations lastObject];
		CLLocation *secondToLatest = [locations objectAtIndex:([locations count]- 2)];
		if ([latest distanceFromLocation:secondToLatest] > 10) {
			[self refreshEvents];
		}
	}
	else if ([locations count] == 1) {
		[self refreshEvents];
	}
	[self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"%@", [error localizedDescription]);
	[self.locationManager stopUpdatingLocation];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	//self.currentEventTitles = nil;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows in the section.
	return [self.dataController countOfEventList];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *TableIdentifier = @"LocalBuzzTableCell";
	LocalBuzzTableCellController *cell = (LocalBuzzTableCellController *)[tableView dequeueReusableCellWithIdentifier:TableIdentifier];
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LocalBuzzTableCell" owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}
	
	cell.nameLabel.text = [self.dataController objectInEventListAtIndex:[indexPath row]].title;
	cell.StatusImage.image = [UIImage imageNamed:@"73-radar.png"];
	cell.CategoryImage.image = [UIImage imageNamed:@"73-radar.png"];
	NSDate* end =[self.dataController objectInEventListAtIndex:[indexPath row]].endTime;
	NSDate* start =[self.dataController objectInEventListAtIndex:[indexPath row]].startTime;
	NSDate* now = [[NSDate alloc] init];
	if([start compare:now]==NSOrderedDescending){
        NSTimeInterval distanceBetweenDates = [start timeIntervalSinceNow];
        cell.StatusImage.image = [UIImage imageNamed:@"button_pause.png"];
        double secondsInAnHour = 3600;
        NSInteger hoursBetweenDates = distanceBetweenDates / secondsInAnHour;
        if(hoursBetweenDates >= 24){
            NSInteger remainingDays = hoursBetweenDates/24;
            hoursBetweenDates = hoursBetweenDates - remainingDays*24;
            cell.timeLabel.text = [NSString stringWithFormat:@"starts in %d D %d H",remainingDays,hoursBetweenDates ];
        }
        else {
            cell.timeLabel.text = [NSString stringWithFormat:@"starts in %d H",hoursBetweenDates ];
        }
	}
	else {
        
        cell.StatusImage.image = [UIImage imageNamed:@"button_stop.png"];
		NSTimeInterval distanceBetweenDates = [end timeIntervalSinceNow];
		if (distanceBetweenDates < 0) {
			cell.timeLabel.text = @"ended";
		}
		else {
            cell.StatusImage.image = [UIImage imageNamed:@"button_play.png"];
			double secondsInAnHour = 3600;
			NSInteger hoursBetweenDates = distanceBetweenDates / secondsInAnHour;
			if(hoursBetweenDates >= 24){
				NSInteger remainingDays = hoursBetweenDates/24;
				hoursBetweenDates = hoursBetweenDates - remainingDays*24;
				cell.timeLabel.text = [NSString stringWithFormat:@"ends in %d D %d H",remainingDays,hoursBetweenDates ];
			}
			else {
				cell.timeLabel.text = [NSString stringWithFormat:@"ends in %d H",hoursBetweenDates ];
			}
		}
	}
    NSInteger cid;
    cid = [self.dataController objectInEventListAtIndex:[indexPath row]].category.integerValue;
    NSString * picturename =[NSString stringWithFormat:@"category%d.png",cid];
    cell.CategoryImage.image = [UIImage imageNamed:picturename];
	return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the specified item to be editable.
	return NO;
}

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Navigation logic may go here. Create and push another view controller.
	/*
	<#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
	// ...
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:detailViewController animated:YES];
	*/
	[self performSegueWithIdentifier:@"ShowPastEventDetail" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"ShowPastEventDetail"]) {
		EventDetailViewController *eventDetailController = [segue destinationViewController];
		eventDetailController.event = [self.dataController objectInEventListAtIndex:[self.tableView indexPathForSelectedRow].row];
		eventDetailController.currentCoordinate = [[self.locationManager location] coordinate];
	}
}

@end
