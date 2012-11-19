//
//  UIDropDownMenu.m
//  DropDownMenu
//
//  Created by and on 30/03/2012.
//  Copyright (c) 2012 Add Image
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//

#import "UIDropDownMenu.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIDropDownMenu
@synthesize dropdownTable, selectedTextField, parentView, singleTapGestureRecogniser, textColor;

UIInterfaceOrientation orientation;


-(void)makeMenu:(UITextField *)textfield titleArray:(NSArray *)titleArray valueArray:(NSArray *)valueArray targetView:(UIView *)tview;
{

    // Create the drop down menu mutable array and add the title and value arrays
    dropdownArray = [[NSMutableArray alloc] init]; 
    [dropdownArray addObject:titleArray];
    [dropdownArray addObject:valueArray];
    
    // create a UIView instance and assign it to the target view
    self.parentView = [[UIView alloc] initWithFrame:tview.frame];
    self.parentView = tview;
    
    // Get the current device orientation
    orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    // create the list table and set the delegate, datasource and border style
    self.dropdownTable = [[UITableView alloc] initWithFrame:parentView.bounds style:UITableViewStylePlain];
    self.dropdownTable.hidden = true;
    self.dropdownTable.delegate = self;
    self.dropdownTable.dataSource = self;
    
    // set the default color scheme
    self.dropdownTable.layer.cornerRadius = 10;
    self.dropdownTable.layer.borderColor = [[UIColor grayColor]CGColor];
    self.dropdownTable.layer.borderWidth = 1;       
    self.dropdownTable.backgroundColor = [UIColor whiteColor];
    self.textColor = [UIColor blackColor];
    
    [self.parentView addSubview:self.dropdownTable]; 
    
    // create a UITextField instance and assign it to the source text field
    self.selectedTextField = [[UITextField alloc] init]; 
    self.selectedTextField = textfield;
    
    self.selectedTextField.delegate = self;
    [self.selectedTextField addTarget:self action:@selector(textfieldClicked:) forControlEvents:UIControlEventTouchDown];
    
}


-(void)textfieldClicked:(id)sender{
    // Add an observer to remove the menu if the device orientation changes
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(didChangeOrientation:) name: UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    // add touch detection on parent view, this will allow the menu to dissapear when the user touches outside of the menu.
    singleTapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    singleTapGestureRecogniser.numberOfTapsRequired = 1;
    singleTapGestureRecogniser.delegate = self;
    [self.parentView addGestureRecognizer:singleTapGestureRecogniser];
 
    // set the size and position of the menu
    // if the device is an iPad the menu will be sized to the same width and position as the target text field, 
    // if the device is an iPhone or iPod touch the menu is set to fill the screen.
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        // Device is an iPad
        
        CGRect screenRect = [[UIScreen mainScreen]bounds];
        int screenheight = 0;
        // use the height or width depending on device orientation
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])){
            screenheight = screenRect.size.height;
        }
        else{
            screenheight = screenRect.size.width; 
        }
 
        int tableheight;
        if (((self.selectedTextField.frame.origin.y + self.selectedTextField.frame.size.height) + ([[dropdownArray objectAtIndex:0] count] * 40)) >= screenRect.size.height - 50){
            tableheight = screenheight - 50 - (self.selectedTextField.frame.origin.y + self.selectedTextField.frame.size.height);

            // enable scrolling and bounce
            self.dropdownTable.scrollEnabled = YES;
        }
        else{
            tableheight = [[dropdownArray objectAtIndex:0] count] * 40;
            // disable scrolling and bounce
            self.dropdownTable.scrollEnabled = NO;
        }
        
        self.dropdownTable.frame = CGRectMake(self.selectedTextField.frame.origin.x, self.selectedTextField.frame.origin.y, self.selectedTextField.frame.size.width, self.selectedTextField.frame.size.height);
        
        [UIView beginAnimations:@"slide down" context:NULL];
        [UIView setAnimationDuration:0.2]; 
            self.dropdownTable.hidden = false;
            self.dropdownTable.frame = CGRectMake(self.selectedTextField.frame.origin.x, self.selectedTextField.frame.origin.y + self.selectedTextField.frame.size.height, self.selectedTextField.frame.size.width, tableheight);
        [UIView commitAnimations];
        
    }
    else{
        // Device is an iPhone or iPod Touch
        
        // ensure autosizing enabled
        self.dropdownTable.autoresizesSubviews = YES;
        [self.dropdownTable setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];

        
        self.dropdownTable.alpha = 0.0;
        
        [UIView beginAnimations:@"Zoom" context:NULL];
        [UIView setAnimationDuration:0.3];        
        self.dropdownTable.hidden = false;
        self.dropdownTable.alpha = 1.0;
        [UIView commitAnimations];
        self.dropdownTable.scrollEnabled = YES;
        self.dropdownTable.bounces = YES;
    }
    
    // reload the tableview
    [self.dropdownTable reloadData];
}




-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    // Hide both keyboard and blinking cursor.    
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self.dropdownTable]) {        
        // Don't let gesture recognizer fire if the table was touched
        return NO;
    }
    else{
        [self dismissMenu];
        return YES;
    }    
}


- (void) didChangeOrientation:(NSNotification *)notification
{
    // remove the menu on rotation
    if (orientation != [[UIApplication sharedApplication] statusBarOrientation]){
        orientation = [[UIApplication sharedApplication] statusBarOrientation];        
        [self textfieldClicked:nil];
    }
}

-(void)dismissMenu{
    // remove the tap guesture recognizer and hide the menu
    [self.parentView removeGestureRecognizer:singleTapGestureRecogniser];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    self.dropdownTable.hidden = true;

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (dropdownArray.count > 0){
        return [[dropdownArray objectAtIndex:0] count];
    }
    else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];  
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    cell.textLabel.text = [[dropdownArray objectAtIndex:0] objectAtIndex:row];
    cell.textLabel.font = [UIFont systemFontOfSize:17.0];
    cell.textLabel.textColor = self.textColor;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    self.selectedTextField.text = [[dropdownArray objectAtIndex:1] objectAtIndex:row];
    self.dropdownTable.alpha = 1.0;
    [UIView beginAnimations:@"Ending" context:NULL];
    [UIView setAnimationDuration:0.3];  
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(FadeOutComplete)];
    self.dropdownTable.hidden = false;
    self.dropdownTable.alpha = 0.0;    
    [UIView commitAnimations];
}

- (void)FadeOutComplete{
    self.dropdownTable.alpha = 1.0;
    [self dismissMenu];
}

// color scheme methods

-(void)setDropdownBackgroundColor:(UIColor *)color{
    dropdownTable.backgroundColor = color;
}
-(void)setDropdownTextColor:(UIColor *)color{
    textColor = color;
}

@end
