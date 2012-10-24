//
//  MapViewAnnotation.h
//  LocalBuzz
//
//  Created by Amanda Le on 10/22/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewAnnotation : NSObject<MKAnnotation> {
	NSString * title;
	//NSString * subTitle;
	CLLocationCoordinate2D coordinate;
}

@property (nonatomic, copy) NSString *title;
//@property (nonatomic, copy) NSString *subTitle;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

-(id) initWithTitle:(NSString *) t coordinate:(CLLocationCoordinate2D) c;

@end
