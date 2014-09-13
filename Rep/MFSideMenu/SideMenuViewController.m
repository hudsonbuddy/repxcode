//
//  SideMenuViewController.m
//  Rep
//
//  Created by Hud on 2/2/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "SideMenuViewController.h"
#import "MFSideMenu.h"

@interface SideMenuViewController (){
    
    NSMutableArray *repNavigationArray;
    NSMutableArray *repViewIDArray;
    NSMutableArray *repTitleArray;


    
}

@end

@implementation SideMenuViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self setupSideMenuArrays];
    [self setupBackgroundAndFonts];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)setupBackgroundAndFonts{
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bck_GraphTexture_75opacity"]];
//    self.tableView.backgroundColor = [UIColor clearColor];
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bck_GraphTexture60.png"]];
    
}

#pragma mark - Table view data source

-(void) setupSideMenuArrays{
    
    repNavigationArray = [[NSMutableArray alloc] init];
//    [repNavigationArray addObject:@"++ Reps"];
//    [repNavigationArray addObject:@"|| Self"];
//    [repNavigationArray addObject:@"&& Friends"];
//    [repNavigationArray addObject:@"\"\" Feed"];
//    [repNavigationArray addObject:@"?? Search"];

    [repNavigationArray addObject:@"/messages"];
    [repNavigationArray addObject:@"/feed"];
    [repNavigationArray addObject:@"/venues"];
    [repNavigationArray addObject:@"/self"];
    [repNavigationArray addObject:@"/search"];
    [repNavigationArray addObject:@"/help"];

    
    
    repViewIDArray = [[NSMutableArray alloc]init];
    [repViewIDArray addObject:@"inboxID"];
    [repViewIDArray addObject:@"feedID"];
    [repViewIDArray addObject:@"venueID"];
    [repViewIDArray addObject:@"selfID"];
    [repViewIDArray addObject:@"searchID"];
    [repViewIDArray addObject:@"settingsID"];

    
    repTitleArray = [[NSMutableArray alloc] init];
    [repTitleArray addObject:@"/messages"];
    [repTitleArray addObject:@"/feed"];
    [repTitleArray addObject:@"/venues"];
    [repTitleArray addObject:@"/self"];
    [repTitleArray addObject:@"/search"];
    [repTitleArray addObject:@"/help"];

    
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ([repNavigationArray count]>0) {
        return [repNavigationArray count];

    }else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SideMenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [repNavigationArray objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Courier" size:24];
    cell.textLabel.backgroundColor = [UIColor whiteColor];
    cell.textLabel.highlightedTextColor = [UIColor colorWithRed:0x00/255.0f
                                                                         green:0xCC/255.0f
                                                                          blue:0x00/255.0f alpha:1];
    cell.backgroundColor = [UIColor whiteColor];
    
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor blackColor]];
    [cell setSelectedBackgroundView:bgColorView];
    
    // Configure the cell...
    
    return cell;
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
    UIViewController *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                        instantiateViewControllerWithIdentifier:[repViewIDArray objectAtIndex:indexPath.row]];
    demoController.title = [NSString stringWithFormat:@"%@",[repTitleArray objectAtIndex:indexPath.row]];
    
    NSArray *controllers = [NSArray arrayWithObject:demoController];
    [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
    [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.backgroundColor = [UIColor clearColor];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

     


@end
