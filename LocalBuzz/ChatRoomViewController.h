//
//  ChatRoomViewController.h
//  LocalBuzz
//
//  Created by Vincent Leung on 11/27/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"

@interface ChatRoomViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, XMPPRoomDelegate>
@property (retain, nonatomic) IBOutlet UITableView *messageList;
@property (retain, nonatomic) IBOutlet UITextField *messageInput;
@property (retain, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) NSMutableArray *messages;
@property (weak, nonatomic) NSNumber *eventId;

@property (strong, nonatomic) XMPPRoom *eventChatRoom;
@property (weak, nonatomic) XMPPRoomHybridStorage *xmppRoomStorage;
@property (weak, nonatomic) XMPPJID *roomJID;
@end
