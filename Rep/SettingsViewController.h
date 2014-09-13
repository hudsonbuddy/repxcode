//
//  SettingsViewController.h
//  Rep
//
//  Created by Hud on 2/6/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "RepAppDelegate.h"
#import "RepViewController.h"

@interface SettingsViewController : RepViewController
@property (strong, nonatomic) IBOutlet UIButton *logoutButtonOutlet;
@property (weak, nonatomic) IBOutlet UITextView *repManifestoTextViewOutlet;
- (IBAction)logoutButtonPressed:(id)sender;

@end
