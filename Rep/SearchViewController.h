//
//  SearchViewController.h
//  Rep
//
//  Created by Hud on 2/2/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RepViewController.h"

@interface SearchViewController : RepViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (strong, nonatomic) IBOutlet UISearchBar *searchBarOutlet;
@property (strong, nonatomic) IBOutlet UITableView *searchTableViewOutlet;

@end
