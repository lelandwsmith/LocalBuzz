//
//  MapViewAnnotation.m
//  LocalBuzz
//
//  Created by Amanda Le on 10/22/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "MapViewAnnotation.h"

@implementation MapViewAnnotation

@synthesize title = _title;
@synthesize coordinate = _coordinate;

-(id) initWithTitle:(NSString *) t coordinate:(CLLocationCoordinate2D) c
{
	_title = t;
	_coordinate = c;
	return self;
}

@end
