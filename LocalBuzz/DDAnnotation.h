//
//  DDAnnotation.h
//  LocalBuzz
//
//  Created by Amanda Le on 10/26/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface DDAnnotation : MKPlacemark {
	CLLocationCoordinate2D coordinate_;
	NSString *title_;
	NSString *subtitle_;
}

// Re-declare MKAnnotation's readonly property 'coordinate' to readwrite.
@property (nonatomic, readwrite, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;

@end
