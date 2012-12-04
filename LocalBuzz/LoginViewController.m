#import "LoginViewController.h"
#import "LocalBuzzAppDelegate.h"
#import "AFHTTPClient.h"
@interface LoginViewController ()
@property (strong, nonatomic) IBOutlet UIButton *loginbtn;

- (IBAction)click :(UIButton *)sender;

@end

@implementation LoginViewController

@synthesize spinner;
@synthesize loginbtn;

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[loginbtn setImage: [UIImage imageNamed:@"LoginWithFacebookNormal@2x.png"] forState:UIControlStateNormal];
	[self.spinner stopAnimating];
	[self.loginbtn setTitle:@"Login" forState:UIControlStateNormal];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStateChanged:) name:FBSessionStateChangedNotification object:nil];
	
	// Set up the background image
	UIGraphicsBeginImageContext(self.view.frame.size);
	[[UIImage imageNamed:@"background_logo.png"] drawInRect:self.view.bounds];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}

- (void)sessionStateChanged:(NSNotification*)notification {
	if (FBSession.activeSession.isOpen) {
		NSUserDefaults *user_data = [NSUserDefaults standardUserDefaults];
		[FBRequestConnection
		 startForMeWithCompletionHandler:^(FBRequestConnection *connection,
																			 id<FBGraphUser> user,
																			 NSError *error) {
			 if (!error) {
				 NSString *username = user.username;
				 NSString *fbId = user.id;
				 NSString *firstName = user.first_name;
				 NSString *lastName = user.last_name;
				 NSString *location = [user.location objectForKey:@"name"];
				 [user_data setObject:username forKey:@"username"];
				 [user_data setObject:location forKey:@"location"];
				 [user_data setObject:fbId forKey:@"fb_id"];
				 NSURL *createUserURL = [NSURL URLWithString:@"http://localbuzz.vforvincent.info/"];
				 AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:createUserURL];
				 NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
																 username, @"user[username]",
																 firstName, @"user[first_name]",
																 lastName, @"user[last_name]",
																 fbId, @"user[fb_id]",
																 nil];
				 [httpClient postPath:@"/users.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
					 NSDictionary *user = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
					 [user_data setObject:[user objectForKey:@"id"] forKey:@"id"];
					 [user_data setObject:[[firstName stringByAppendingString:@" "] stringByAppendingString:lastName]  forKey:@"full_name"];
				 }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
					 // NSLog(@"afherror  %@", [error localizedDescription]);
				 }];
			 } else {
				 // NSLog(@"error!!!!!!!login");
			 }
		 }];
		
	} else {
		[self.loginbtn setTitle:@"Login" forState:UIControlStateNormal];
	}
}

-(IBAction)click :(UIButton *)sender {
	[self.spinner startAnimating];
	LocalBuzzAppDelegate *appDelegate =(LocalBuzzAppDelegate *) [[UIApplication sharedApplication]delegate];
	[appDelegate openSessionWithAllowLoginUI:YES];
}

#pragma mark Template generated code

- (void)viewDidUnload {
	self.loginbtn = nil;
	self.spinner = nil;
	[super viewDidUnload];
}

- (BOOL)shouldAutorotate {
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
	NSUInteger orientations = UIInterfaceOrientationMaskPortrait;
	orientations |= UIInterfaceOrientationMaskAll;
	return orientations;
}

#pragma mark -

@end
