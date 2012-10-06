//
//  DetailEventDescriptionViewController.m
//  LocalBuzz
//
//  Created by Amanda Le on 10/1/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "DetailEventDescriptionViewController.h"

@interface DetailEventDescriptionViewController ()

@end

@implementation DetailEventDescriptionViewController
@synthesize num = _num;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//NOTE: segue would pass necessary info to this function
//TODO: determine the member viables here and what are needed to sent from the list view (ie. title)
- (void)setNum:(int)num
{
  _num = num;
}

@end
