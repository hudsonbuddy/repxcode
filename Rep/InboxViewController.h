//
//  InboxViewController.h
//  Rep
//
//  Created by Hud on 2/2/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RepViewController.h"

@interface InboxViewController : RepViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UITableView *inboxTableViewOutlet;
@property (strong, nonatomic) IBOutlet UITableView *outboxTableViewOutlet;
@property (strong, nonatomic) IBOutlet UIButton *inboxButtonOutlet;
@property (strong, nonatomic) IBOutlet UIButton *outboxButtonOutlet;
//- (IBAction)inboxButtonPressed:(id)sender;
//- (IBAction)outboxButtonPressed:(id)sender;
//- (IBAction)outboxButtonTouchUpOutside:(id)sender;
-(void)refreshInbox;
@end
