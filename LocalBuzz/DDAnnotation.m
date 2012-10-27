//
//  DDAnnotation.m
//  LocalBuzz
//
//  Created by Amanda Le on 10/26/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "DDAnnotation.h"

@implementation DDAnnotation

@synthesize coordinate = coordinate_;
@synthesize title = title_;
@synthesize subtitle = subtitle_;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate addressDictionary:(NSDictionary *)addressDictionary {
	
	if ((self = [super initWithCoordinate:coordinate addressDictionary:addressDictionary])) {
		self.coordinate = coordinate;
	}
	return self;
}

@end
