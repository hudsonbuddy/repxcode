//
//  LoginViewController.m
//  Rep
//
//  Created by Hud on 2/4/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "LoginViewController.h"
#import <CommonCrypto/CommonHMAC.h>

@interface LoginViewController ()<UIGestureRecognizerDelegate>{
    
    RepUserData *_myUserData;
}

@end

@implementation LoginViewController
@synthesize repnameTextFieldOutlet, passwordTextFieldOutlet, loginButtonOutlet;

static NSString * const SHA_256_HASH_SALT = @"The opposite of life is time";


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setHidden:YES];
    [self.repnameTextFieldOutlet setDelegate:self];
    [self.passwordTextFieldOutlet setDelegate:self];
    [self setupTapToDismiss];

    _myUserData = [RepUserData sharedRepUserData];
    
	// Do any additional setup after loading the view.
}

-(void)setupTapToDismiss{
    
    UITapGestureRecognizer *tapToDismissGR = [[UITapGestureRecognizer alloc]initWithTarget:self.view action:@selector(endEditing:)];
    tapToDismissGR.delegate = self;
    [self.view addGestureRecognizer:tapToDismissGR];
    
}

//-(void) dismissKeyboard: (UITapGestureRecognizer)sender{
//    
//    [self.view endEditing:YES];
//    
//}

- (IBAction)loginButtonPressed:(id)sender {
    
    NSString *facebookAppID = [[NSBundle mainBundle].infoDictionary objectForKey:@"FacebookAppID"];

    NSLog(@"%@", facebookAppID);
    
    RepAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate openSessionWithAllowLoginUI:YES];

    [self showLoadingOverlay];
//    [self goToInbox];
    
}

-(void) loginWithCredientials{
    
    [self.view endEditing:YES];
    
    NSString *passwordHashString;
    passwordHashString = [self hashString:passwordTextFieldOutlet.text withSalt:SHA_256_HASH_SALT];
    NSLog(@"%@", passwordHashString);
    
    RadiusRequest *inboxRequestReal = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:self.repnameTextFieldOutlet.text, @"repname", passwordHashString, @"password", nil] apiMethod:@"login" httpMethod:@"POST"];
    
    [inboxRequestReal startWithCompletionHandler:^(id response, RadiusError *error){
        
        NSLog(@"%@", response);
        [self dismissLoadingOverlay];
        
        if ([[response objectForKey:@"auth"]integerValue]==1) {
            
            [self showInboxView];
            _myUserData.currentUserRepName = [[response objectForKey:@"data"]objectForKey:@"repname"];
            NSLog(@"%@", _myUserData.currentUserRepName);
            NSLog(@"%@", [[response objectForKey:@"data"]objectForKey:@"repname"]);
            [self updateDeviceTokenWithToken];
            
            NSUserDefaults *myDefaults = [NSUserDefaults standardUserDefaults];
            
            NSString *repname = [[response objectForKey:@"data"]objectForKey:@"repname"];
            NSString *_id = [[response objectForKey:@"data"]objectForKey:@"_id"];

            [myDefaults setObject:_id forKey:@"_id"];
            [myDefaults setObject:repname forKey:@"repname"];

//            NSString *test = [NSString stringWithFormat:@"%@", [myDefaults objectForKey:@"_id"]];
//            NSString *testagain = [NSString stringWithFormat:@"%@", [myDefaults objectForKey:@"repname"]];

        }else{
            
//            UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Password incorrect" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
        }
        
    }];
    
}

-(void) loginFailed{
    
}

-(void) validateUserCredentials{
    
    //Used to validate for repname/email password combination
}

-(void) validateFacebookCredentials{
    
    //Used to validate for Facebook
    
}

-(void) goToInbox{
    
    [self.navigationController.navigationBar setHidden:NO];
    
    
    UIViewController *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                        instantiateViewControllerWithIdentifier:@"inboxID"];
    
    NSArray *controllers = [NSArray arrayWithObject:demoController];
    [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
    [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
    
    
}

-(NSString*)sha256HashFor:(NSString*)input
{
    const char* str = [input UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++)
    {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}
- (NSString *) hashString :(NSString *) data withSalt: (NSString *) salt {
    
    
    const char *cKey  = [salt cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSString *hash;
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", cHMAC[i]];
    hash = output;
    return hash;
    
}

-(void) updateDeviceTokenWithToken{
    
    NSString *token = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"token"]];
    
    RadiusRequest *inboxRequestReal = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:token, @"device_token", nil] apiMethod:@"apn/set" httpMethod:@"POST"];
    
    [inboxRequestReal startWithCompletionHandler:^(id response, RadiusError *error){
        
        NSLog(@"%@", response);
        
        
    }];
    
}



#pragma mark UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.repnameTextFieldOutlet) {
        [textField endEditing:YES];
        return YES;
    }else if (textField == self.passwordTextFieldOutlet){
        
        [self showLoadingOverlay];
        [self loginWithCredientials];
        return YES;
    }
    
    return YES;

}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.view];
    
    NSLog(@"x = %.0f, y = %.0f", point.x, point.y);
    if (CGRectContainsPoint(self.loginButtonOutlet.layer.frame, point))
        return NO;
    
    return YES;
}


#pragma mark Apple Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    
    [self.navigationController.navigationBar setHidden:YES];
    [self dismissLoadingOverlay];
    
}

@end
