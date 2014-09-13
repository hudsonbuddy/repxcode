//
//  ConvoViewController.h
//  Rep
//
//  Created by Hudson on 5/6/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "RepViewController.h"

@interface ConvoViewController : RepViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) NSString *repname;
@property (strong, nonatomic) NSString *repref;
@property (strong, nonatomic) UIImage *imageToRep;


- (IBAction)cameraButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *cameraButtonOutlet;
@property (weak, nonatomic) IBOutlet UITableView *convoTableViewOutlet;
@property (weak, nonatomic) IBOutlet UITextView *repMessageTextView;
@property (weak, nonatomic) IBOutlet UIButton *repButtonOutlet;
- (IBAction)repButtonPressed:(id)sender;
-(void) initializeConvoViewWithRepRef: (NSString *) repRef;
@end
