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

#import <Foundation/Foundation.h>

@interface UIDropDownMenu : NSObject <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
{
    UITableView *dropdownTable;
    UIView *parentView;
    UITextField *selectedTextField;
    NSMutableArray *dropdownArray;
    UITapGestureRecognizer *singleTapGestureRecogniser;
    
    UIColor *textColor;    
}

@property (strong, nonatomic) UITableView *dropdownTable;
@property (strong, nonatomic) UIView *parentView;
@property (strong, nonatomic) UITextField *selectedTextField;
@property (strong, nonatomic) UITapGestureRecognizer *singleTapGestureRecogniser;
@property (strong, nonatomic) UIColor *textColor;

-(void)makeMenu:(UITextField *)textfield titleArray:(NSArray *)titleArray valueArray:(NSArray *)valueArray targetView:(UIView *)tview;
-(void)textfieldClicked:(id)sender;
-(void)dismissMenu;
-(void)setDropdownBackgroundColor:(UIColor *)color;
-(void)setDropdownTextColor:(UIColor *)color;
@end
