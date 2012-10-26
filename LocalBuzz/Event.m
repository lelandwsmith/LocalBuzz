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
    self = [super init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    if (self) {
        _title = [eventDict objectForKey:@"title"];
        _longitude = [eventDict objectForKey:@"longitude"];
        _latitude = [eventDict objectForKey:@"latitude"];
        _detailDescription = [eventDict objectForKey:@"description"];
        _time = [dateFormatter dateFromString:[eventDict objectForKey:@"time"]];
        _isPublic = NO;
        if ([_detailDescription isKindOfClass:[NSNull class]]) {
            _detailDescription = @"";
        }
        return self;
    }
    return nil;
}

- (BOOL) isEventValid {
    return !([self.title isKindOfClass:[NSNull class]] || [self.longitude isKindOfClass:[NSNull class]] || [self.latitude isKindOfClass:[NSNull class]] || [self.time isKindOfClass:[NSNull class]]);
}
@end
