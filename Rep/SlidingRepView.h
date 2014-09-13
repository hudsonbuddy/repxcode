//
//  SlidingRepView.h
//  Rep
//
//  Created by Hud on 2/4/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RadiusRequest.h"
#import "MFSlidingView.h"
#import "NotificationsFind.h"


@interface SlidingRepView : UIView <UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate>
@property (strong, nonatomic) IBOutlet UITextField *repnameTextFieldOutlet;
@property (strong, nonatomic) IBOutlet UIButton *repButtonOutlet;
@property (strong, nonatomic) IBOutlet UITextView *repMessageTextViewOutlet;
@property (strong, nonatomic) UIImage *imageToRep;

- (IBAction)repButtonPressed:(id)sender;

-(void)initializeSlidingRepView;

@property (nonatomic) CGFloat animatedDistance;

@property (weak, nonatomic) IBOutlet UIButton *cameraButtonOutlet;
- (IBAction)cameraButtonPressed:(id)sender;

@end

