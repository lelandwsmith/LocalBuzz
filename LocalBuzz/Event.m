//
//  Event.m
//  LocalBuzz
//
//  Created by Vincent Leung on 10/25/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "Event.h"

@implementation Event

- (id) initWithDictionary:(NSDictionary *)eventDict {
    NSLog(@"%@", eventDict);
    self = [super init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    if (self) {
        _title = [eventDict objectForKey:@"title"];
        _longitude = [eventDict objectForKey:@"longitude"];
        _latitude = [eventDict objectForKey:@"latitude"];
        _description = [eventDict objectForKey:@"description"];
        _time = [dateFormatter dateFromString:[eventDict objectForKey:@"time"]];
        _isPublic = NO;
        if (!_title || !_longitude || !_latitude || !_description || !_time) {
            return nil;
        }
        return self;
    }
    return nil;
}

@end
