//
//  ChatRoomViewController.m
//  LocalBuzz
//
//  Created by Vincent Leung on 11/27/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "ChatRoomViewController.h"

@interface ChatRoomViewController ()
@end

@implementation ChatRoomViewController

- (NSMutableArray *)messages {
    if (_messages == nil) {
        _messages = [[NSMutableArray alloc] init];
    }
    return _messages;
}

- (IBAction)sendMessage:(id)sender {
    NSString *message = self.messageInput.text;
    if(![message isEqualToString:@""])
	{
		[self.messages addObject:message];
		[self.messageList reloadData];
		NSUInteger index = [self.messages count] - 1;
        [self.messageList scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
		
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.messageList addGestureRecognizer:gestureRecognizer];
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
	
	NSString *text = [self.messages objectAtIndex:indexPath.row];
	CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(240.0f, 480.0f) lineBreakMode:NSLineBreakByWordWrapping];
	
	UIImage *balloon;
	
	if(indexPath.row % 2 == 0)
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
	NSString *body = [self.messages objectAtIndex:indexPath.row];
	CGSize size = [body sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(240.0, 480.0) lineBreakMode:NSLineBreakByWordWrapping];
	return size.height + 15;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messages count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}



@end
