

#import "LoginViewController.h"
#import "LocalBuzzAppDelegate.h"

@interface LoginViewController ()
@property (strong, nonatomic) IBOutlet UITextView *textview;
@property (strong, nonatomic) IBOutlet UIButton *loginbtn;


- (IBAction)click :(UIButton *)sender;
- (void)updateView;

@end

@implementation LoginViewController

@synthesize textview ;
@synthesize loginbtn ;
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:FBSessionStateChangedNotification
     object:nil];
    // Check the session for a cached token to show the proper authenticated
    // UI. However, since this is not user intitiated, do not show the login UX.
    LocalBuzzAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate openSessionWithAllowLoginUI:NO];

}



- (void)sessionStateChanged:(NSNotification*)notification {
    if (FBSession.activeSession.isOpen) {
        //NSLog(@"isIN");
        [self.loginbtn setTitle:@"Logout" forState:UIControlStateNormal];
        self.textview.hidden = NO;
        NSUserDefaults *user_data = [NSUserDefaults standardUserDefaults]; 
        [FBRequestConnection
         startForMeWithCompletionHandler:^(FBRequestConnection *connection,
                                           id<FBGraphUser> user,
                                           NSError *error) {
             if (!error) {
                 NSString *userInfo = @"";
                 
                 //get user name
                 userInfo = [userInfo
                             stringByAppendingString:
                             [NSString stringWithFormat:@"Name: %@\n\n",
                              user.name]];
                 NSString* uname =user.name;
                 [user_data setObject:uname forKey:@"name"];
                 //get user birthday
                 userInfo = [userInfo
                             stringByAppendingString:
                             [NSString stringWithFormat:@"Birthday: %@\n\n",
                              user.birthday]];
                 NSString* ubirthday =user.birthday;
                 [user_data setObject:ubirthday forKey:@"birthday"];
                 //get user location
                 userInfo = [userInfo
                             stringByAppendingString:
                             [NSString stringWithFormat:@"Location: %@\n\n",
                              [user.location objectForKey:@"name"]]];
                 NSString* ulocation =[user.location objectForKey:@"name"];
                 [user_data setObject:ulocation forKey:@"location"];
                 //get friend-list
                 FBRequest* friendsRequest = [FBRequest requestForMyFriends];
                 [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                               NSDictionary* result,
                                                               NSError *error) {
                     NSArray* friends = [result objectForKey:@"data"];
                     NSMutableArray *friendlist = [[NSMutableArray alloc] init];
                     NSLog(@"Found: %i friends", friends.count);
                     for (NSDictionary<FBGraphUser>* friend in friends) {
                         NSLog(@"I have a friend named %@ with id %@", friend.name, friend.id);
                        
                         friendinfo* temp = [friendinfo alloc];
                         //NSString *tempS =[NSString stringWithFormat:@""];
                       // temp->Fid = tempS;
                        temp->Fid = [[NSString alloc] initWithFormat:(@"%@"),friend.id];
                        temp->Fname = [[NSString alloc] initWithFormat:(@"%@"), friend.name];
                         [friendlist addObject:temp];
                        // NSLog(@"iiii");
                         
                         
                     }
                     [user_data setObject:friendlist forKey:@"friends"];
                 }];
                 
                 // Display the user info
                 self.textview.text = userInfo;
             }
         }];
        //store data locally
        
        
        ////////////
        self.textview.hidden = NO;
    } else {
        //NSLog(@"isOUTS");
        [self.loginbtn setTitle:@"Login" forState:UIControlStateNormal];
        self.textview.hidden = YES;
    }
}

-(IBAction)click :(UIButton *)sender{
    // get the app delegate so that we can access the session property
    LocalBuzzAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (FBSession.activeSession.isOpen) {
        //NSLog(@"want to log out");
         [appDelegate closeSession];
    } else {
        // The user has initiated a login, so call the openSession method
        // and show the login UX if necessary.
        //NSLog(@"want to log in");
        [appDelegate openSessionWithAllowLoginUI:YES];
    }


}



#pragma mark Template generated code

- (void)viewDidUnload
{
    self.loginbtn = nil;
    self.textview = nil;
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark -

@end