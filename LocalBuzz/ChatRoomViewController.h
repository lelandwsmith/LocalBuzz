//
//  ChatRoomViewController.h
//  LocalBuzz
//
//  Created by Vincent Leung on 11/27/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatRoomViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (retain, nonatomic) IBOutlet UITableView *messageList;
@property (retain, nonatomic) IBOutlet UITextField *messageInput;
@property (retain, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) NSMutableArray *messages;
@end
