//
//  Event.h
//  LocalBuzz
//
//  Created by Vincent Leung on 10/25/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject
@property (nonatomic, copy) NSNumber *eventId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSNumber *longitude;
@property (nonatomic, copy) NSNumber *latitude;
@property (nonatomic, copy) NSDate *startTime;
@property (nonatomic, copy) NSDate *endTime;
@property (nonatomic, copy) NSString *detailDescription;
@property (nonatomic) BOOL isPublic;

- (id) initWithDictionary:(NSDictionary *)eventDict;

- (BOOL) isEventValid;
@end
