//
//  RegisterViewController.h
//  Rep
//
//  Created by Hud on 2/4/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "RepViewController.h"

@interface RegisterViewController : RepViewController <UITextFieldDelegate>


@property (strong, nonatomic) IBOutlet UITextField *repnameTextFieldOutlet;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextFieldOutlet;
@property (weak, nonatomic) IBOutlet UILabel *userDictionaryLabelOutlet;
@property (weak, nonatomic) IBOutlet UIButton *registerButtonOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureOutlet;

@property (nonatomic, strong) NSString *facebookUsername;
@property (nonatomic, strong) NSDictionary *userDictionary;

- (IBAction)registerButtonPressed:(id)sender;
-(void) initializeRegisterViewWithFacebookDictionary: (NSDictionary *)dictionary;

@end
