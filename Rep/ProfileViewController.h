//
//  ProfileViewController.h
//  Rep
//
//  Created by Hud on 2/2/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RepViewController.h"

@interface ProfileViewController : RepViewController <UITextViewDelegate, UIAlertViewDelegate>


@property (nonatomic) BOOL currentUserProfile;

@property (strong, nonatomic) IBOutlet UILabel *dateJoinedLabelOutlet;
@property (strong, nonatomic) IBOutlet UIImageView *profilePictureOutlet;
@property (strong, nonatomic) IBOutlet UILabel *repnameLabelOutlet;
@property (strong, nonatomic) IBOutlet UILabel *repscoreLabelOutlet;
@property (strong, nonatomic) IBOutlet UIButton *profileButtonOutlet;
- (IBAction)profileButtonPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *settingsButtonOutlet;
- (IBAction)settingsButtonPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UITextView *repMessageTextViewOutlet;

@property (strong, nonatomic) NSString *repname;
@property (strong, nonatomic) NSString *_id;

-(void) initializeWithRepname: (NSString *)myRepname;
-(void )initializeWithID:(NSString *)myID;

@end
