//
//  SettingsViewController.m
//  Rep
//
//  Created by Hud on 2/6/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController (){
    
    RepUserData *_myUserData;
}

@end

@implementation SettingsViewController

@synthesize repManifestoTextViewOutlet;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setManifestoText];
    [self setTitle:@"/help"];
	// Do any additional setup after loading the view.
}

-(void) setManifestoText{
    
    NSString *manifestoText = [NSString stringWithFormat:@"-Wrap private parts of text with // and //. Swipe twice downward on a picture you want private. Anybody not in at the time of the rep will never see it. \n\n-Quote individual reps you like by holding down on the picture \n\n-Ignore reps by holding down on it in /messages \n\n -Include other people by putting ++theirRepname in the text of the rep"];
    [self.repManifestoTextViewOutlet setText:manifestoText];
    
    
}
- (IBAction)logoutButtonPressed:(id)sender {
    
//    RepAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
//    [appDelegate closeSession];
    [RepUserData resetRepUserData];

    [self showLoadingOverlay];
    
    NSString *token = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"token"]];

    
    RadiusRequest *inboxRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys: token, @"device_token", nil] apiMethod:@"logout" httpMethod:@"POST"];
    
    [inboxRequest startWithCompletionHandler:^(id response, RadiusError *error){
        [self dismissLoadingOverlay];
        NSLog(@"%@", response);
        
        if([[[response objectForKey:@"data"]objectForKey:@"message"] isEqualToString:@"You are now logged out"]){
            
            RepAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            [self showLoginView];
            [appDelegate closeSession];
            [NSUserDefaults resetStandardUserDefaults];
        }else if ([[response objectForKey:@"auth"]integerValue] == 1){
            RepAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            [self showLoginView];
            [appDelegate closeSession];
            [NSUserDefaults resetStandardUserDefaults];
        }
        
    }];
    

    
//    RadiusRequest *apnClearRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys: token, @"device_token", nil] apiMethod:@"apn/clear" httpMethod:@"POST"];
//    
//    [apnClearRequest startWithCompletionHandler:^(id response, RadiusError *error){
//        
//        NSLog(@"%@", response);
//        
//        
//    }];
    
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
    [self setRepManifestoTextViewOutlet:nil];
    [super viewDidUnload];
}
@end
