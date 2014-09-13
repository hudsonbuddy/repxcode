//
//  SelfViewController.h
//  Rep
//
//  Created by Hudson on 5/7/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "RepViewController.h"

@interface SelfViewController : RepViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) NSString *repname;
@property (strong, nonatomic) NSString *facebookID;
@property (strong, nonatomic) NSString *_id;
@property (nonatomic) BOOL currentUserProfile;

@property (weak, nonatomic) IBOutlet UITableView *repboxTableViewOutlet;

-(void) initializeSelfWithID: (NSString *)theID;

@end
