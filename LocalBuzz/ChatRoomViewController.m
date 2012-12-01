//
//  ChatRoomViewController.m
//  LocalBuzz
//
//  Created by Vincent Leung on 11/27/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "ChatRoomViewController.h"
#import "LocalBuzzAppDelegate.h"

@interface ChatRoomViewController ()
@end

@implementation ChatRoomViewController

- (XMPPRoomHybridStorage *) xmppRoomStorage {
    if (_xmppRoomStorage == nil) {
        _xmppRoomStorage = [XMPPRoomHybridStorage sharedInstance];
    }
    return _xmppRoomStorage;
}

- (XMPPRoom *) eventChatRoom {
    if (_eventChatRoom == nil) {
        _eventChatRoom = [[XMPPRoom alloc] initWithRoomStorage:self.xmppRoomStorage jid:self.roomJID dispatchQueue:dispatch_get_main_queue()];
    }
    return _eventChatRoom;
}

- (NSMutableArray *)messages {
    if (_messages == nil) {
        _messages = [[NSMutableArray alloc] init];
    }
    return _messages;
}

- (XMPPJID *)roomJID {
    if (_roomJID == nil) {
        NSString *roomJIDString = [@"event_" stringByAppendingString:[self.eventId stringValue]];
        NSString *roomDomain = [@"conference." stringByAppendingString:[self xmppStream].hostName];
        _roomJID = [XMPPJID jidWithUser:roomJIDString domain:roomDomain resource:nil];
    }
    return _roomJID;
}

- (IBAction)sendMessage:(id)sender {
    NSString *message = self.messageInput.text;
    if(![message isEqualToString:@""])
	{
        [self.eventChatRoom sendMessage:message];
		self.messageInput.text = @"";
        
	}
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (LocalBuzzAppDelegate *) appDelegate {
    LocalBuzzAppDelegate *appDelegate = (LocalBuzzAppDelegate *) [[UIApplication sharedApplication] delegate];
    return appDelegate;
}

- (XMPPStream *) xmppStream {
    return [self appDelegate].xmppStream;
}

////////////////////////////
#pragma View Cycle
////////////////////////////

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.messageList addGestureRecognizer:gestureRecognizer];
    NSString *nickname = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    [self.eventChatRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.eventChatRoom activate:[self appDelegate].xmppStream];
    [self.eventChatRoom joinRoomUsingNickname:nickname fromJID:[[self xmppStream] myJID] history:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification object:self.view.window];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notif {
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
	self.toolbar.frame = CGRectMake(0, 156, 320, 44);
	self.messageList.frame = CGRectMake(0, 0, 320, 156);
	[UIView commitAnimations];
	
	if([self.messages count] > 0)
	{
		NSUInteger index = [self.messages count] - 1;
		[self.messageList scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
	}
}

- (BOOL) hideKeyboard {
    [self.messageInput resignFirstResponder];
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
	self.toolbar.frame = CGRectMake(0, 372, 320, 44);
	self.messageList.frame = CGRectMake(0, 0, 320, 372);
	[UIView commitAnimations];
	
	return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

///////////////////
#pragma mark UITableViewDelegate
///////////////////

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	
	UIImageView *balloonView;
	UILabel *label;
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		
		balloonView = [[UIImageView alloc] initWithFrame:CGRectZero];
		balloonView.tag = 1;
		
		label = [[UILabel alloc] initWithFrame:CGRectZero];
		label.backgroundColor = [UIColor clearColor];
		label.tag = 2;
		label.numberOfLines = 0;
		label.lineBreakMode = NSLineBreakByWordWrapping;
		label.font = [UIFont systemFontOfSize:14.0];
		
		UIView *message = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.frame.size.width, cell.frame.size.height)];
		message.tag = 0;
		[message addSubview:balloonView];
		[message addSubview:label];
		[cell.contentView addSubview:message];
	}
	else
	{
		balloonView = (UIImageView *)[[cell.contentView viewWithTag:0] viewWithTag:1];
		label = (UILabel *)[[cell.contentView viewWithTag:0] viewWithTag:2];
	}
	
	XMPPMessage *message = [self.messages objectAtIndex:indexPath.row];
    NSString *text = [[message elementForName:@"body"] stringValue];
	CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(240.0f, 480.0f) lineBreakMode:NSLineBreakByWordWrapping];
	
	UIImage *balloon;
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSString *fromOccupant = [[message attributeForName:@"from"] stringValue];
    NSString *fromUser = [[XMPPJID jidWithString:fromOccupant] resource];
	if([username isEqualToString:fromUser])
	{
		balloonView.frame = CGRectMake(320.0f - (size.width + 28.0f), 2.0f, size.width + 28.0f, size.height + 15.0f);
		balloon = [[UIImage imageNamed:@"green.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
		label.frame = CGRectMake(307.0f - (size.width + 5.0f), 8.0f, size.width + 5.0f, size.height);
	}
	else
	{
		balloonView.frame = CGRectMake(0.0, 2.0, size.width + 28, size.height + 15);
		balloon = [[UIImage imageNamed:@"grey.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
		label.frame = CGRectMake(16, 8, size.width + 5, size.height);
	}
	
	balloonView.image = balloon;
	label.text = text;
	
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	XMPPMessage *message = [self.messages objectAtIndex:indexPath.row];
    NSString *body = [[message elementForName:@"body"] stringValue];
	CGSize size = [body sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(240.0, 480.0) lineBreakMode:NSLineBreakByWordWrapping];
	return size.height + 15;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messages count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//////////////////
#pragma mark XMPPRoomDelegate
//////////////////

- (void)xmppRoomDidJoin:(XMPPRoom *)sender {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    NSLog(@"%d", [self.eventChatRoom isJoined]);
}

- (void)xmppRoomDidCreate:(XMPPRoom *)sender {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [self.messages addObject:message];
    [self.messageList reloadData];
    NSUInteger index = [self.messages count] - 1;
    [self.messageList scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

@end
