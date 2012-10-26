//
//  EventDataController.h
//  LocalBuzz
//
//  Created by Vincent Leung on 10/25/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Event;

@interface EventDataController : NSObject

@property (nonatomic, strong) NSMutableArray *eventList;

- (NSUInteger) countOfEventList;
- (Event *)objectInEventListAtIndex:(NSUInteger)index;
- (void) addEventToEventList:(Event *)event;

@end
