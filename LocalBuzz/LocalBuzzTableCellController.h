//
//  LocalBuzzTableCellController.h
//  LocalBuzz
//
//  Created by Zichao Fu on 12-11-13.
//  Copyright (c) 2012年 Vincent Leung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocalBuzzTableCellController : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *CategoryImage;
@property (nonatomic, weak) IBOutlet UIImageView *StatusImage;

@end
