#import "LoginViewController.h"
#import "LocalBuzzAppDelegate.h"
#import "AFHTTPClient.h"
@interface LoginViewController ()
@property (strong, nonatomic) IBOutlet UIButton *loginbtn;

- (IBAction)click :(UIButton *)sender;

@end

@implementation LoginViewController

@synthesize spinner;
@synthesize loginbtn ;
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [loginbtn setImage:
     [UIImage imageNamed:@"LoginWithFacebookNormal@2x.png"]
                 forState:UIControlStateNormal]; 
    [self.spinner stopAnimating];
    [self.loginbtn setTitle:@"Login" forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:FBSessionStateChangedNotification
     object:nil];
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
                 //NSString *userInfo = @"";
                 
//                 //get user name
//                 userInfo = [userInfo
//                             stringByAppendingString:
//                             [NSString stringWithFormat:@"Name: %@\n\n",
//                              user.name]];
//                 NSString* uname =user.name;
//                 [user_data setObject:uname forKey:@"name"];
//                 //get user birthday
//                 userInfo = [userInfo
//                             stringByAppendingString:
//                             [NSString stringWithFormat:@"Birthday: %@\n\n",
//                              user.birthday]];
//                 NSString* ubirthday =user.birthday;
//                 [user_data setObject:ubirthday forKey:@"birthday"];
//                 //get user location
//                 userInfo = [userInfo
//                             stringByAppendingString:
//                             [NSString stringWithFormat:@"Location: %@\n\n",
//                              [user.location objectForKey:@"name"]]];
//                 NSString* ulocation =[user.location objectForKey:@"name"];
//                 [user_data setObject:ulocation forKey:@"location"];
//                 //get friend-list
//                 FBRequest* friendsRequest = [FBRequest requestForMyFriends];
//                 [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
//                                                               NSDictionary* result,
//                                                               NSError *error) {
//                     NSArray* friends = [result objectForKey:@"data"];
//                     NSMutableArray *friendlist = [[NSMutableArray alloc] init];
//                     NSLog(@"Found: %i friends", friends.count);
//                     for (NSDictionary<FBGraphUser>* friend in friends) {
//                         NSLog(@"I have a friend named %@ with id %@", friend.name, friend.id);
//                        
//                         friendinfo* temp = [friendinfo alloc];
//                         //NSString *tempS =[NSString stringWithFormat:@""];
//                       // temp->Fid = tempS;
//                        temp->Fid = [[NSString alloc] initWithFormat:(@"%@"),friend.id];
//                        temp->Fname = [[NSString alloc] initWithFormat:(@"%@"), friend.name];
//                         [friendlist addObject:temp];
//                        // NSLog(@"iiii");//                         
//                         
//                     }
//                     [user_data setObject:friendlist forKey:@"friends"];
//                 }];
                 
                 // Display the user info
                 //self.textview.text = userInfo;


-(IBAction)click :(UIButton *)sender{
    [self.spinner startAnimating];
    LocalBuzzAppDelegate *appDelegate =(LocalBuzzAppDelegate *) [[UIApplication sharedApplication]delegate];
    [appDelegate openSessionWithAllowLoginUI:YES];


}



#pragma mark Template generated code

- (void)viewDidUnload
{
    self.loginbtn = nil;
    self.spinner = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotate
{
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
	NSUInteger orientations = UIInterfaceOrientationMaskPortrait;
	orientations |= UIInterfaceOrientationMaskAll;
	return orientations;
}

#pragma mark -

@end
