//
//  LoginViewController.h
//  Rep
//
//  Created by Hud on 2/4/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RepViewController.h"
#import "RepAppDelegate.h"

@interface LoginViewController : RepViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *repnameTextFieldOutlet;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextFieldOutlet;
@property (strong, nonatomic) IBOutlet UIButton *loginButtonOutlet;
- (IBAction)loginButtonPressed:(id)sender;
-(void)loginFailed;

@end
