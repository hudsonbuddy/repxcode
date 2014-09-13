//
//  FeedViewController.h
//  Rep
//
//  Created by Hud on 2/26/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "RepViewController.h"

@interface FeedViewController : RepViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *feedTableViewOutlet;

@end
