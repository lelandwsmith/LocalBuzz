//
//  NavBarOrientationController.m
//  LocalBuzz
//
//  Created by Amanda Le on 10/31/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "NavBarOrientationController.h"

@interface NavBarOrientationController ()

@end

@implementation NavBarOrientationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
	return NO;
}

/*- (NSUInteger)supportedInterfaceOrientations {
	NSUInteger orientations = UIInterfaceOrientationMaskPortrait;
	orientations |= UIInterfaceOrientationMaskAll;
	return orientations;
}*/

@end
