//
//  MapView.h
//  LocalBuzz
//
//  Created by Amanda Le on 10/25/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "RegexKitLite.h"
#import "DDAnnotation.h"

@interface MapView : UIView<MKMapViewDelegate> {

}

@property (nonatomic, retain) MKMapView* mapView;
@property (nonatomic, retain) UIImageView* routeView;
@property (nonatomic, retain) NSArray* routes;
@property (nonatomic, retain) UIColor* lineColor;

-(void) showRouteFrom: (DDAnnotation*) f to:(DDAnnotation*) t;

@end
