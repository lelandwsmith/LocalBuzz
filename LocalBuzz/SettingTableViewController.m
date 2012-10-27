//
//  SettingTableViewController.m
//  LocalBuzz
//
//  Created by Zichao Fu on 12-10-26.
//  Copyright (c) 2012年 Vincent Leung. All rights reserved.
//

#import "SettingTableViewController.h"
#import "LocalBuzzAppDelegate.h"
#import "UserInfoTableViewController.h"
@interface SettingTableViewController ()

@end

@implementation SettingTableViewController
@synthesize logoutBT=_logoutCell;
@synthesize UserInfoCell = _UserInfoCell;
@synthesize UserInfoLabel =_UserInfoLabel;
@synthesize currentRange = _currentRange;
@synthesize slider =_slider;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.UserInfoLabel.text=@"My Profile";
    NSUserDefaults *user_data = [NSUserDefaults standardUserDefaults];
    self.slider.maximumValue = 10;
    self.slider.minimumValue = 0.5;
    self.slider.value =[[user_data valueForKey:@"range"] floatValue];
    int progresAsInt = (int)(self.slider.value +0.5f);
    NSString *newText = [[NSString alloc] initWithFormat:@"%d miles",progresAsInt];
    self.currentRange.text = newText;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (IBAction)setRange:(id)sender {
     NSUserDefaults *user_data = [NSUserDefaults standardUserDefaults];
    int progresAsInt = (int)(self.slider.value +0.5f);
    NSString *newText = [[NSString alloc] initWithFormat:@"%d miles",progresAsInt];
    self.currentRange.text = newText;
    if(self.slider!=0){
        [user_data setObject:[NSNumber numberWithFloat:self.slider.value] forKey:@"range"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"User Information", @"User Information");
            break;
        case 1:
            sectionName = NSLocalizedString(@"Event Search Range", @"Event Search Range");
            break;
            // ...
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if((indexPath.section== 0)&&(indexPath.row==0)){
        //user info page should pop out
        UIStoryboard* Storyboard =
        [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        UserInfoTableViewController* detailPage =
        [Storyboard instantiateViewControllerWithIdentifier:@"userinfo"];
        [self.navigationController pushViewController:detailPage animated:YES];
        return;
    }else if((indexPath.section== 2)&&(indexPath.row==0)){
        //user click the logout button
        self.tabBarController.selectedIndex = 0;
        [FBSession.activeSession closeAndClearTokenInformation];
        return;
    } else {
        return;
    }
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
