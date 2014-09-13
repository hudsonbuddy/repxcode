//
//  RegisterViewController.m
//  Rep
//
//  Created by Hud on 2/4/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "RegisterViewController.h"
#import <CommonCrypto/CommonHMAC.h>

@interface RegisterViewController (){
    
    RepUserData *_myUserData;
    CGFloat animatedDistance;

    AsyncImageView *newAsync;

}

@end

@implementation RegisterViewController
@synthesize facebookUsername, repnameTextFieldOutlet, passwordTextFieldOutlet, userDictionaryLabelOutlet, userDictionary,registerButtonOutlet, profilePictureOutlet;

static NSString * const SHA_256_HASH_SALT = @"The opposite of life is time";

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
static const CGFloat ASYC_IMAGE_TAG = 100;

-(void) initializeRegisterViewWithFacebookDictionary:(NSDictionary *)dictionary{
    
    
    facebookUsername = [dictionary objectForKey:@"username"];
    userDictionary = dictionary;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _myUserData = [RepUserData sharedRepUserData];
    self.passwordTextFieldOutlet.delegate = self;
    self.repnameTextFieldOutlet.delegate = self;
    [self setupAsyncImageView];
    [self setupViewAndAnimations];

	// Do any additional setup after loading the view.
}

-(void)setupAsyncImageView{
    
//    NSString *testURLString = [NSString stringWithFormat:@"https://graph.facebook.com/1127566442/picture?width=320&height=200"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@", [userDictionary objectForKey:@"pic"]];
    NSURL *myURL = [NSURL URLWithString:urlString];
    newAsync = [[AsyncImageView alloc] initWithFrame:self.profilePictureOutlet.frame imageURL:myURL cache:nil loadImmediately:YES];
    newAsync.tag = ASYC_IMAGE_TAG;
    [self.view addSubview:newAsync];
    
    
}

-(void)setupViewAndAnimations{
    
//    self.repnameTextFieldOutlet.text = facebookUsername;
    self.userDictionaryLabelOutlet.text = [NSString stringWithFormat:@"%@", userDictionary];
    newAsync.alpha = 0;
    self.registerButtonOutlet.alpha = 0;

    UITapGestureRecognizer *tapToDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [newAsync addGestureRecognizer:tapToDismiss];
    
    UIActivityIndicatorView *AIV = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    AIV.frame = registerButtonOutlet.frame;
    [self.view addSubview:AIV];
    [AIV startAnimating];
    
    [UIView animateWithDuration:10
                          delay:2
                        options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         
                         newAsync.alpha =.9;
                     
                     }
                     completion:^(BOOL finished){
                     
                         self.registerButtonOutlet.userInteractionEnabled = YES;
                         self.registerButtonOutlet.alpha = 1;
                         [AIV stopAnimating];

                     }];
    
    
}



- (IBAction)registerButtonPressed:(id)sender {
    

    [self registerNewUser];
    
}

-(void)registerNewUser{
    
    NSString *passwordHashString;
    passwordHashString = [self hashString:passwordTextFieldOutlet.text withSalt:SHA_256_HASH_SALT];
    NSLog(@"%@", passwordHashString);
    
    if ([self.repnameTextFieldOutlet.text length]>0 && [self.passwordTextFieldOutlet.text length]>0) {
        RadiusRequest *inboxRequestReal = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:self.repnameTextFieldOutlet.text, @"repname", passwordHashString, @"password", nil] apiMethod:@"user/update" httpMethod:@"POST"];
        
        [inboxRequestReal startWithCompletionHandler:^(id response, RadiusError *error){
            
            NSLog(@"%@", response);
            
            if ([[response objectForKey:@"data"]objectForKey:@"repname"]) {
                
                [self showInboxView];
                NSUserDefaults *myDefaults = [NSUserDefaults standardUserDefaults];
                
                NSString *repname = [[response objectForKey:@"data"]objectForKey:@"repname"];
                NSString *_id = [[response objectForKey:@"data"]objectForKey:@"_id"];
                
                [myDefaults setObject:_id forKey:@"_id"];
                [myDefaults setObject:repname forKey:@"repname"];

                
            }else if ([[response objectForKey:@"err"]objectForKey:@"message"]){
                
                UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", [[response objectForKey:@"err"] objectForKey:@"message"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [successAlert show];
                
            }
            
        }];
    }
    
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

#pragma mark Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField endEditing:YES];
    
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    CGRect textFieldRect =
    [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect =
    [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
    

    
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


- (void)viewDidUnload {
    [self setUserDictionaryLabelOutlet:nil];
    [self setRegisterButtonOutlet:nil];
    [self setProfilePictureOutlet:nil];
    [super viewDidUnload];
}
@end
