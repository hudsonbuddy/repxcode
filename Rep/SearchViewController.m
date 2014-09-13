//
//  SearchViewController.m
//  Rep
//
//  Created by Hud on 2/2/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "SearchViewController.h"
#import "ProfileViewController.h"
#import "SelfViewController.h"

@interface SearchViewController (){
    
    NSMutableArray *searchResultsArray;
    NSString *lastQuery;
    NSString *currentQuery;
    NSString *user_id;
    NSMutableArray *friendsArray;

    
}

@end

@implementation SearchViewController

@synthesize searchBarOutlet, searchTableViewOutlet;

- (void)viewDidLoad
{
    [super viewDidLoad];
    searchResultsArray = [[NSMutableArray alloc] init];
    friendsArray = [[NSMutableArray alloc] init];
    [self findFriendsWithLimit:[NSString stringWithFormat:@"15"] andOffset:[NSString stringWithFormat:@"0"]];
    [searchBarOutlet setDelegate:self];
    searchTableViewOutlet.delegate = self;
    searchTableViewOutlet.dataSource = self;
    
    if (searchResultsArray == nil) {
        searchResultsArray = [[NSMutableArray alloc]init];
    }
    self.searchTableViewOutlet.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bck_GraphTexture_75opacity"]];

    [self.searchTableViewOutlet addInfiniteScrollingWithActionHandler:^{
        if ([searchBarOutlet.text length] == 0 && [lastQuery length] == 0) {
            [self findFriendsWithLimit:[NSString stringWithFormat:@"15"] andOffset:[NSString stringWithFormat:@"%i", [searchResultsArray count]]];
            
        }else{
            [self findUsersForQuery:self.searchBarOutlet.text limit:10 offset:[searchResultsArray count]];
            
        }
    }];
    
    
	// Do any additional setup after loading the view.
     

}


-(void) findFriendsWithLimit: (NSString *)limit andOffset:(NSString *)offset{
    
    RadiusRequest *inboxRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:limit, @"limit", offset, @"offset", nil] apiMethod:@"friends" httpMethod:@"POST"];
    
    [inboxRequest startWithCompletionHandler:^(id response, RadiusError *error){
        
        
        friendsArray = [NSMutableArray arrayWithArray:[response objectForKey:@"data"]];
        srandom(time(NULL));
        for (NSInteger x = 0; x < [friendsArray count]; x++) {
            NSInteger randInt = (random() % ([friendsArray count] - x)) + x;
            [friendsArray exchangeObjectAtIndex:x withObjectAtIndex:randInt];
        }
        
        for (int i=0; i<[friendsArray count]; i++) {
            
            NSString *myID = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"_id"]];
             
             
            for (int a =0; a  < [[[friendsArray objectAtIndex:i]objectForKey:@"parties"] count]; a++) {
                
                NSString *tempID = [[[friendsArray objectAtIndex:i]objectForKey:@"ids"] objectAtIndex:a];

                if (![tempID isEqualToString:myID]) {
                    [searchResultsArray addObject:[[[friendsArray objectAtIndex:i] objectForKey:@"parties"] objectForKey:tempID]];

                }
            }
            
            
        }
        [searchTableViewOutlet reloadData];
        [self.searchTableViewOutlet.infiniteScrollingView stopAnimating];
        
    }];
}

-(void) findUsersForQuery:(NSString *)query limit:(NSUInteger)limit offset:(NSUInteger)offset {
    
    RadiusRequest *searchRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:query, @"terms",[NSNumber numberWithInteger:offset],@"offset",[NSNumber numberWithInteger:limit],@"limit",nil] apiMethod:@"user/search" httpMethod:@"POST"];
    [searchRequest startWithCompletionHandler:^(id response, RadiusError *error) {
        
        NSLog(@"%@", response);
        
        if (![query isEqualToString:lastQuery]) {
            return;
        }
        

        
        NSMutableArray *responseData = [NSMutableArray arrayWithArray:[response objectForKey:@"data"]];
        
        if ([responseData count]>0) {
            if (offset > 0) {
                [searchResultsArray addObjectsFromArray:responseData];
                [searchTableViewOutlet reloadData];
                [self.searchTableViewOutlet.infiniteScrollingView stopAnimating];

            }else{
                searchResultsArray = responseData;
                [searchTableViewOutlet reloadData];
                [searchTableViewOutlet scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                [self.searchTableViewOutlet.infiniteScrollingView stopAnimating];


            }
        }else if ([query length]>0){
            
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No more search results" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [av show];
            [self.searchTableViewOutlet.infiniteScrollingView stopAnimating];

        }
        


        
    }];
}

-(void)performSearch
{
    
    NSString *searchQueryString = [self.searchBarOutlet.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    lastQuery = searchQueryString;
    if(![searchQueryString isEqualToString:@""]) {
        [self findUsersForQuery:searchQueryString limit:10 offset:0];
    } else {
    }
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self performSearch];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [searchBar endEditing:YES];
    
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
    if ([searchResultsArray count]>0 && [searchResultsArray count]<15)
        return [searchResultsArray count];
    else if ([searchResultsArray count] >=15){
        return [searchResultsArray count];
    }
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == [searchResultsArray count] ) {
        static NSString *moreCellIdentifier = @"MoreButtonCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:moreCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:moreCellIdentifier];
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"More results"];
        cell.textLabel.font = [UIFont fontWithName:@"Courier" size:15];
        cell.textLabel.highlightedTextColor = [UIColor greenColor];
        UIView *backView = [[UIView alloc] initWithFrame:cell.frame];
        backView.backgroundColor = [UIColor blackColor];
        cell.selectedBackgroundView = backView;
        return cell;

    }
    static NSString *friendCellIdentifier = @"FriendCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:friendCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:friendCellIdentifier];
    }
    
    
    
    
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [[searchResultsArray objectAtIndex:indexPath.row]objectForKey:@"name"]];
    cell.textLabel.font = [UIFont fontWithName:@"Courier" size:15];
    cell.textLabel.highlightedTextColor = [UIColor greenColor];
    UIView *backView = [[UIView alloc] initWithFrame:cell.frame];
    backView.backgroundColor = [UIColor blackColor];
    cell.selectedBackgroundView = backView;
    // Configure the cell...
    
    return cell;
}

-(void) tableView: (UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if([cell.reuseIdentifier isEqualToString:@"FriendCell"]){
//        ProfileViewController *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
//                                                 instantiateViewControllerWithIdentifier:@"profileID"];
//        
//            
//            
//            NSString *theID = [NSString stringWithFormat:@"%@",[[searchResultsArray objectAtIndex:indexPath.row] objectForKey:@"_id"]];
//            [demoController initializeWithID:theID];
//            [tableView deselectRowAtIndexPath:indexPath animated:YES];
//            [self.navigationController pushViewController:demoController animated:YES];
        
        SelfViewController *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                              instantiateViewControllerWithIdentifier:@"selfID"];
        
        NSString *theID = [NSString stringWithFormat:@"%@",[[searchResultsArray objectAtIndex:indexPath.row] objectForKey:@"_id"]];
        [demoController initializeSelfWithID:theID];
        
        [self.navigationController pushViewController:demoController animated:YES];

        
    }else if (indexPath.row == [searchResultsArray count]){
        
        //find more users for that query
        if ([searchBarOutlet.text length] == 0 && [lastQuery length] == 0) {
            [self findFriendsWithLimit:[NSString stringWithFormat:@"15"] andOffset:[NSString stringWithFormat:@"%i", [searchResultsArray count]]];

        }else{
            [self findUsersForQuery:self.searchBarOutlet.text limit:10 offset:[searchResultsArray count]];

        }
    }
    
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.backgroundColor = [UIColor clearColor];
    
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
