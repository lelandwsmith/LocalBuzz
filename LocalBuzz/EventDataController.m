//
//  EventDataController.m
//  LocalBuzz
//
//  Created by Vincent Leung on 10/25/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "EventDataController.h"
#import "Event.h"
#import "AFHTTPClient.h"

@implementation EventDataController

@synthesize eventList = _eventList;

- (id) init {
    if (self = [super init]) {
        self.eventList = [[NSMutableArray alloc] init];
        return self;
    }
    return nil;
}

- (void)setEventList:(NSMutableArray *)eventList {
    if (_eventList != eventList) {
        _eventList = [eventList mutableCopy];
    }
}

- (NSUInteger) countOfEventList {
    return [self.eventList count];
}

- (Event *)objectInEventListAtIndex:(NSUInteger)index {
    return [self.eventList objectAtIndex:index];
}

- (void) addEventToEventList:(Event *)event {
    if ([event isEventValid]) {
        [self.eventList addObject:event];
    }
}

- (void) emptyEventList {
    [self.eventList removeAllObjects];
}

@end
