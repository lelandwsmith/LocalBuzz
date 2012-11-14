#import "LoginViewController.h"
#import "LocalBuzzAppDelegate.h"
#import "AFHTTPClient.h"
@interface LoginViewController ()
@property (strong, nonatomic) IBOutlet UITextView *textview;
@property (strong, nonatomic) IBOutlet UIButton *loginbtn;

- (IBAction)click :(UIButton *)sender;

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
    //LocalBuzzAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
  //  NSLog(@"run the login view");
 //   NSLog(@"current permission is :%@",appDelegate.session.permissions);
    [self.loginbtn setTitle:@"Login" forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:FBSessionStateChangedNotification
     object:nil];
   // LocalBuzzAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    //NSLog(@"viewDIdLoad place#2");
   // [appDelegate openSessionWithAllowLoginUI:NO];

}



- (void)sessionStateChanged:(NSNotification*)notification {
    if (FBSession.activeSession.isOpen) {
        [self.loginbtn setTitle:@"Logout" forState:UIControlStateNormal];
        self.textview.hidden = NO;
        NSUserDefaults *user_data = [NSUserDefaults standardUserDefaults];
        [FBRequestConnection
         startForMeWithCompletionHandler:^(FBRequestConnection *connection,
                                           id<FBGraphUser> user,
                                           NSError *error) {
             //NSLog(@"getting user data");

             if (!error) {
                 NSString *username = user.name;
                 NSString *fbId = user.id;
                 NSString *firstName = user.first_name;
                 NSString *lastName = user.last_name;
                 NSString *location = [user.location objectForKey:@"name"];
                 [user_data setObject:username forKey:@"name"];
                 [user_data setObject:location forKey:@"location"];
                 [user_data setObject:fbId forKey:@"id"];
                 NSURL *createUserURL = [NSURL URLWithString:@"http://localbuzz.vforvincent.info/"];
                 AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:createUserURL];
                 NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                         username, @"user[username]",
                                         firstName, @"user[first_name]",
                                         lastName, @"user[last_name]",
                                         fbId, @"user[fb_id]", 
                                         nil];
                 [httpClient postPath:@"/users.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                     self.textview.text = responseString;
                     NSLog(@"Response: %@", responseString);
                 }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"afherror  %@", [error localizedDescription]);
                 }];
             } else {
                // NSLog(@"error!!!!!!!login");
             }
         }];
        self.textview.hidden = NO;
    } else {
        [self.loginbtn setTitle:@"Login" forState:UIControlStateNormal];
        self.textview.hidden = YES;
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
    LocalBuzzAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (FBSession.activeSession.isOpen) {
         [appDelegate closeSession];
    } else {
       // NSLog(@"hit bottom#1");
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
