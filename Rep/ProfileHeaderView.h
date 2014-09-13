//
//  ProfileHeaderView.h
//  Rep
//
//  Created by Hudson on 5/6/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileHeaderView : UIView <UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel *repnameLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *repscoreLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *dateJoinedLabelOutlet;
@property (weak, nonatomic) IBOutlet UITextView *repMessageTextViewOutlet;
@property (weak, nonatomic) IBOutlet UIButton *repButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *cameraButtonOutlet;


@property (strong, nonatomic) NSString *_id;
@property (strong, nonatomic) UIImage *imageToRep;


- (IBAction)repButtonPressed:(id)sender;
-(void) initializeProfileHeader;
- (IBAction)pictureButtonPressed:(id)sender;

@end
