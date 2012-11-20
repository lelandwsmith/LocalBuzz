//
//  LocalBuzzTableCellController.m
//  LocalBuzz
//
//  Created by Zichao Fu on 12-11-13.
//  Copyright (c) 2012年 Vincent Leung. All rights reserved.
//

#import "LocalBuzzTableCellController.h"

@implementation LocalBuzzTableCellController

@synthesize nameLabel = _nameLabel;
@synthesize timeLabel = _timeLabel;
@synthesize StatusImage = _StatusImage;
@synthesize CategoryImage = _CategoryImage;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
