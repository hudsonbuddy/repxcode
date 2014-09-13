//
//  FriendsViewController.h
//  Rep
//
//  Created by Hud on 2/2/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RepViewController.h"

@interface FriendsViewController : RepViewController <UITableViewDataSource, UITableViewDelegate>


@property (strong, nonatomic) IBOutlet UITableView *friendsTableViewOutlet;

@end
