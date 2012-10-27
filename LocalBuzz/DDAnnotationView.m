//
//  DDAnnotationView.m
//  LocalBuzz
//
//  Created by Amanda Le on 10/26/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "DDAnnotationView.h"
#import "DDAnnotation.h"
#import <QuartzCore/QuartzCore.h> // For CAAnimation

@interface DDAnnotationView ()
@property (nonatomic, assign) BOOL isMoving;
@property (nonatomic, assign) CGPoint startLocation;
@property (nonatomic, assign) CGPoint originalCenter;

@property (nonatomic, retain) UIImageView *	pinShadow;
@property (nonatomic, retain) NSTimer * pinTimer;
@property (nonatomic, assign) MKMapView *mapView;

+ (CAAnimation *)pinBounceAnimation_;
+ (CAAnimation *)pinFloatingAnimation_;
+ (CAAnimation *)pinLiftAnimation_;
+ (CAAnimation *)liftForDraggingAnimation_; // Used in touchesBegan:
+ (CAAnimation *)liftAndDropAnimation_;		// Used in touchesEnded: when touchesMoved: previous triggered
- (id)initWithAnnotation_:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier mapView:(MKMapView *)mapView;
- (void)shadowLiftWillStart_:(NSString *)animationID context:(void *)context;
- (void)shadowDropDidStop_:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)resetPinPosition_:(NSTimer *)timer;
@end

@implementation DDAnnotationView

@synthesize mapView;// = mapView_;
@synthesize isMoving = isMoving_;
@synthesize startLocation = startLocation_;
@synthesize originalCenter = originalCenter_;
@synthesize pinShadow = pinShadow_;
@synthesize pinTimer = pinTimer_;


// Thanks to Bret Cheng (@bretcheng)'s suggestion on avoiding memory leaks in -initWithAnnotation:reuseIdentifier: when returning MKPinAnnotationView instead
+ (id)annotationViewWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier mapView:(MKMapView *)mapView {
	
	// iOS 3.2 will respond to isDraggable property, so use systemVersion to do the check. Thanks to Erich Wood (@erichwood) for the report.
	BOOL draggingSupport = ([[[UIDevice currentDevice] systemVersion] compare:@"4.0" options:NSNumericSearch] != NSOrderedAscending);
	
	if (draggingSupport) {
		MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
		[annotationView performSelector:NSSelectorFromString(@"setDraggable:") withObject:[NSNumber numberWithBool:YES]];
		annotationView.canShowCallout = YES;
		return annotationView;
	}
	
	return [[self alloc] initWithAnnotation_:annotation reuseIdentifier:reuseIdentifier mapView:mapView];
}

- (id)initWithAnnotation_:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier mapView:(MKMapView *)mapView {
	
	if ((self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])) {
		self.image = [UIImage imageNamed:@"Pin.png"];
		self.centerOffset = CGPointMake(8, -14);
		self.calloutOffset = CGPointMake(-8, 0);
		self.canShowCallout = YES;
		
		self.pinShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PinShadow.png"]];
		self.pinShadow.frame = CGRectMake(0, 0, 32, 39);
		self.pinShadow.hidden = YES;
		[self addSubview:self.pinShadow];
		
		self.mapView = mapView;
	}
	
	return self;
}

#pragma mark -
#pragma mark UIView animation delegates

- (void)shadowLiftWillStart_:(NSString *)animationID context:(void *)context {
	self.pinShadow.hidden = NO;
}

- (void)shadowDropDidStop_:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	self.pinShadow.hidden = YES;
}

#pragma mark NSTimer fire method

- (void)resetPinPosition_:(NSTimer *)timer {
	
	[self.pinTimer invalidate];
	self.pinTimer = nil;
	
	[self.layer addAnimation:[DDAnnotationView liftAndDropAnimation_] forKey:@"DDPinAnimation"];
	
	// TODO: animation out-of-sync with self.layer
	[UIView beginAnimations:@"DDShadowLiftDropAnimation" context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(shadowDropDidStop_:finished:context:)];
	[UIView setAnimationDuration:0.1];
	self.pinShadow.center = CGPointMake(90, -30);
	self.pinShadow.center = CGPointMake(16.0, 19.5);
	self.pinShadow.alpha = 0;
	[UIView commitAnimations];
	
	// Update the map coordinate to reflect the new position.
	CGPoint newCenter;
	newCenter.x = self.center.x - self.centerOffset.x;
	newCenter.y = self.center.y - self.centerOffset.y - self.image.size.height + 4.;
	
	DDAnnotation *theAnnotation = (DDAnnotation *)self.annotation;
	CLLocationCoordinate2D newCoordinate = [self.mapView convertPoint:newCenter toCoordinateFromView:self.superview];
	[theAnnotation setCoordinate:newCoordinate];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DDAnnotationCoordinateDidChangeNotification" object:theAnnotation];
	
	// Clean up the state information.
	self.startLocation = CGPointZero;
	self.originalCenter = CGPointZero;
	self.isMoving = NO;
}

#pragma mark -
#pragma mark Handling events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if (self.mapView) {
		[self.layer removeAllAnimations];
		
		[self.layer addAnimation:[DDAnnotationView liftForDraggingAnimation_] forKey:@"DDPinAnimation"];
		
		[UIView beginAnimations:@"DDShadowLiftAnimation" context:NULL];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationWillStartSelector:@selector(shadowLiftWillStart_:context:)];
		[UIView setAnimationDuration:0.2];
		self.pinShadow.center = CGPointMake(80, -20);
		self.pinShadow.alpha = 1;
		[UIView commitAnimations];
	}
	
	// The view is configured for single touches only.
	self.startLocation = [[touches anyObject] locationInView:[self superview]];
	self.originalCenter = self.center;
	
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	CGPoint newLocation = [[touches anyObject] locationInView:[self superview]];
	CGPoint newCenter;
	
	// If the user's finger moved more than 5 pixels, begin the drag.
	if ((abs(newLocation.x - self.startLocation.x) > 5.0) || (abs(newLocation.y - self.startLocation.y) > 5.0)) {
		self.isMoving = YES;
	}
	
	// If dragging has begun, adjust the position of the view.
	if (self.mapView && self.isMoving) {
		
		newCenter.x = self.originalCenter.x + (newLocation.x - self.startLocation.x);
		newCenter.y = self.originalCenter.y + (newLocation.y - self.startLocation.y);
		
		self.center = newCenter;
		
		[self.pinTimer invalidate];
		self.pinTimer = nil;
		self.pinTimer = [NSTimer timerWithTimeInterval:0.3 target:self selector:@selector(resetPinPosition_:) userInfo:nil repeats:NO];
		[[NSRunLoop currentRunLoop] addTimer:self.pinTimer forMode:NSDefaultRunLoopMode];
	} else {
		// Let the parent class handle it.
		[super touchesMoved:touches withEvent:event];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if (self.mapView) {
		if (self.isMoving) {
			[self.pinTimer invalidate];
			self.pinTimer = nil;
			
			[self.layer addAnimation:[DDAnnotationView liftAndDropAnimation_] forKey:@"DDPinAnimation"];
			
			// TODO: animation out-of-sync with self.layer
			[UIView beginAnimations:@"DDShadowLiftDropAnimation" context:NULL];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(shadowDropDidStop_:finished:context:)];
			[UIView setAnimationDuration:0.1];
			self.pinShadow.center = CGPointMake(90, -30);
			self.pinShadow.center = CGPointMake(16.0, 19.5);
			self.pinShadow.alpha = 0;
			[UIView commitAnimations];
			
			// Update the map coordinate to reflect the new position.
			CGPoint newCenter;
			newCenter.x = self.center.x - self.centerOffset.x;
			newCenter.y = self.center.y - self.centerOffset.y - self.image.size.height + 4.;
			
			DDAnnotation* theAnnotation = (DDAnnotation *)self.annotation;
			CLLocationCoordinate2D newCoordinate = [self.mapView convertPoint:newCenter toCoordinateFromView:self.superview];
			
			[theAnnotation setCoordinate:newCoordinate];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"DDAnnotationCoordinateDidChangeNotification" object:theAnnotation];
			
			// Clean up the state information.
			self.startLocation = CGPointZero;
			self.originalCenter = CGPointZero;
			self.isMoving = NO;
		} else {
			
			// TODO: Currently no drop down effect but pin bounce only
			[self.layer addAnimation:[DDAnnotationView pinBounceAnimation_] forKey:@"DDPinAnimation"];
			
			// TODO: animation out-of-sync with self.layer
			[UIView beginAnimations:@"DDShadowDropAnimation" context:NULL];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(shadowDropDidStop_:finished:context:)];
			[UIView setAnimationDuration:0.2];
			self.pinShadow.center = CGPointMake(16.0, 19.5);
			self.pinShadow.alpha = 0;
			[UIView commitAnimations];
		}
	} else {
		[super touchesEnded:touches withEvent:event];
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if (self.mapView) {
		// TODO: Currently no drop down effect but pin bounce only
		[self.layer addAnimation:[DDAnnotationView pinBounceAnimation_] forKey:@"DDPinAnimation"];
		
		// TODO: animation out-of-sync with self.layer
		[UIView beginAnimations:@"DDShadowDropAnimation" context:NULL];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(shadowDropDidStop_:finished:context:)];
		[UIView setAnimationDuration:0.2];
		self.pinShadow.center = CGPointMake(16.0, 19.5);
		self.pinShadow.alpha = 0;
		[UIView commitAnimations];
		
		if (self.isMoving) {
			[self.pinTimer invalidate];
			self.pinTimer = nil;
			
			// Move the view back to its starting point.
			self.center = self.originalCenter;
			
			// Clean up the state information.
			self.startLocation = CGPointZero;
			self.originalCenter = CGPointZero;
			self.isMoving = NO;
		}
	} else {
		[super touchesCancelled:touches withEvent:event];
	}
}

@end
