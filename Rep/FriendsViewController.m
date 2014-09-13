//
//  FriendsViewController.m
//  Rep
//
//  Created by Hud on 2/2/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "FriendsViewController.h"

@interface FriendsViewController (){
    
    RepUserData *_repUserData;
    NSMutableArray *userFacebookFriends;
}

@end

@implementation FriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.friendsTableViewOutlet.delegate = self;
    self.friendsTableViewOutlet.dataSource = self;
    _repUserData = [RepUserData sharedRepUserData];
    [self findFriends];

	// Do any additional setup after loading the view.
}

-(void) findFriends{
    
    RadiusRequest *inboxRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys: nil] apiMethod:@"friends" httpMethod:@"POST"];
    
    [inboxRequest startWithCompletionHandler:^(id response, RadiusError *error){
        
        
        
    }];
    
}

- (void)findFacebookFriends {
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMyFriends] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary *friendsResponse,
           NSError *error) {
             if (!error) {
                 
                 
                 NSLog(@"%@", friendsResponse);
                 
                 userFacebookFriends = [[NSMutableArray alloc]initWithArray:[friendsResponse objectForKey:@"data"]];
                 [self.friendsTableViewOutlet reloadData];
                 

                 
             }
         }];
    }
}

#pragma mark Table Cell Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ([_repUserData.friends count]>0) {
        return [_repUserData.friends count];
        
    }else if ([userFacebookFriends count]>0)
        return [userFacebookFriends count];
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    

    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [[userFacebookFriends objectAtIndex:indexPath.row]objectForKey:@"name"]];
    
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UIViewController *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
//                                        instantiateViewControllerWithIdentifier:@"profileID"];
//    
//    NSArray *controllers = [NSArray arrayWithObject:demoController];
//    [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
//    [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
    
    
    if (FBSession.activeSession.isOpen) {
        RepAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate sendGeneralFacebookRequest];
    }



    
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44;
}


#pragma mark Apple Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
