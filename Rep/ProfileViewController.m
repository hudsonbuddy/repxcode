//
//  ProfileViewController.m
//  Rep
//
//  Created by Hud on 2/2/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "ProfileViewController.h"
#import "PersonViewController.h"
#import "SelfViewController.h"

@interface ProfileViewController () <UIGestureRecognizerDelegate> {
    
    NSMutableArray *consoleTextArray;
    int consoleIndex;
    CGFloat animatedDistance;
}

@end

@implementation ProfileViewController
@synthesize currentUserProfile, profilePictureOutlet, profileButtonOutlet, repnameLabelOutlet, repscoreLabelOutlet, repMessageTextViewOutlet, repname, _id;
@synthesize settingsButtonOutlet;

static NSString * const REP_MESSAGE_PLACEHOLDER = @"Type whatever then rep()";
static NSString * const THE_LAST_THING_ON_YOUR_MIND = @"#typethelastthingonyourmind";
static NSString * const FACEBOOK_MESSAGE_PLACEHOLDER = @"...doesn't look like this person has an account with us. You can still rep them, but you just have let them know IRL";

static NSString * const REP_MANIFESTO_PLACEHOLDER = @"1.Rep people to increase their rep. \n2.Higher rep and earlier join dates help. \n3.Have fun, especially with this box. ";

static NSString * const CHECKOUT_REGEX = @"^checkout\\(\\+\\+[a-z0-9]+\\)$";




static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

static const CGFloat ASYC_IMAGE_TAG = 100;
static const CGFloat ALERT_VIEW_TAG = 200;




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWakeUpFromBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
        
        //If repname was explicity set, then it is that person's profile
        
        //Setup Rep Message mechanics
        repMessageTextViewOutlet.delegate = self;
        [repMessageTextViewOutlet setTextColor:[UIColor greenColor]];
        [repMessageTextViewOutlet setReturnKeyType:UIReturnKeyDone];
        [self setupTapToRepBox];
        [repMessageTextViewOutlet setText:REP_MESSAGE_PLACEHOLDER];
        [self.settingsButtonOutlet setHidden:YES];
        self.settingsButtonOutlet.userInteractionEnabled = NO;
    
    
    [self findUserInfo];


    
}

-(void) initializeWithRepname: (NSString *)myRepname{

    self.repname = myRepname;
    
}

-(void)initializeWithID:(NSString *)myID{
    
    self._id = myID;
    
    
}

-(void) findUserInfo{
    
    RadiusRequest *userQueryRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys: _id, @"_id", nil] apiMethod:@"user/get" httpMethod:@"POST"];
    
    [userQueryRequest startWithCompletionHandler:^(id response, RadiusError *error){
        
        NSLog(@"%@", response);
        
        if([[response objectForKey:@"success"]integerValue] == 1){
            
            [self setupUserProfileWithDictionary:[response objectForKey:@"data"]];
            
        }
        
    }];
    
}


-(void) setupUserProfileWithDictionary: (NSDictionary *)userDictionary{
    
    if (userDictionary !=nil) {
        
    
        if ([userDictionary count]>0) {
            NSURL *myURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [userDictionary objectForKey:@"pic"]]];
            AsyncImageView *newAsync = [[AsyncImageView alloc] initWithFrame:self.profilePictureOutlet.frame imageURL:myURL cache:nil loadImmediately:YES];
            newAsync.tag = ASYC_IMAGE_TAG;
            [self.view addSubview:newAsync];
            [self.view sendSubviewToBack:[self.view viewWithTag:ASYC_IMAGE_TAG]];
            self.profilePictureOutlet.hidden = NO;
            
            //Repname label
            if ([userDictionary objectForKey:@"repname"]) {
                self.repname = [NSString stringWithFormat:@"%@", [userDictionary objectForKey:@"repname"]];
                self.repnameLabelOutlet.text = [NSString stringWithFormat:@"%@",[userDictionary objectForKey:@"repname"]];

            }else{
                self.repnameLabelOutlet.text = [NSString stringWithFormat:@"%@",[userDictionary objectForKey:@"name"]];


            }
            //Score Label
            if ([userDictionary objectForKey:@"score"]) {
                NSString *myScore = [NSString stringWithFormat:@"%@",[userDictionary objectForKey:@"score"]] ;
                if ([myScore integerValue] == 0) {
                    self.repscoreLabelOutlet.text = [NSString stringWithFormat:@"++%@,", myScore];
                }else{
                    self.repscoreLabelOutlet.text = [NSString stringWithFormat:@"++%i,", [myScore integerValue]];

                }

            }else{
                self.repscoreLabelOutlet.text = [NSString stringWithFormat:@"++0,"];
            }
            
            //Date joined
            self.dateJoinedLabelOutlet.text =[NSString stringWithFormat:@"%@}",[userDictionary objectForKey:@"ts"]];

            
            
        }

    }
    
}

-(void)repUser{
    
    [self showLoadingOverlay];
    
    NSString *messageString;
    
        
    messageString = [NSString stringWithFormat:@"%@", repMessageTextViewOutlet.text];
    
    if (_id == nil) {
        
        RadiusRequest *inboxRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:messageString, @"message", nil] apiMethod:@"rep" httpMethod:@"POST"];
        
        [inboxRequest startWithCompletionHandler:^(id response, RadiusError *error){
            
            [self dismissLoadingOverlay];
            NSLog(@"%@", response);
            
            if ([[response objectForKey:@"success"]integerValue]==1) {
                
                if ([[response objectForKey:@"data"] objectForKey:@"_id"]) {
                    UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Rep sent!" message:[NSString stringWithFormat:@"Rep sent!"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    successAlert.tag = ALERT_VIEW_TAG;
                    [successAlert show];
                    
                    [repMessageTextViewOutlet setText:REP_MESSAGE_PLACEHOLDER];
                }
                
                
            }else{
                
                if ([[[response objectForKey:@"err"] objectForKey:@"bypass"]integerValue] !=1) {
                    UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", [[response objectForKey:@"err"] objectForKey:@"message"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    successAlert.tag = ALERT_VIEW_TAG;
                    [successAlert show];
                }
                
            }
            
            
            
            
        }];
        
        return;
    }
    
    RadiusRequest *inboxRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys: _id, @"recipient_id", messageString, @"message", nil] apiMethod:@"rep" httpMethod:@"POST"];
    
    [inboxRequest startWithCompletionHandler:^(id response, RadiusError *error){
        
        [self dismissLoadingOverlay];
        NSLog(@"%@", response);
        
        if ([[response objectForKey:@"success"]integerValue]==1) {
            
            if ([[response objectForKey:@"data"] objectForKey:@"_id"]) {
                UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Rep sent!" message:[NSString stringWithFormat:@"Rep sent!"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                successAlert.tag = ALERT_VIEW_TAG;
                [successAlert show];
                
                [repMessageTextViewOutlet setText:REP_MESSAGE_PLACEHOLDER];
            }
            

        }else{
            
            if ([[[response objectForKey:@"err"] objectForKey:@"bypass"]integerValue] !=1) {
                UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", [[response objectForKey:@"err"] objectForKey:@"message"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                successAlert.tag = ALERT_VIEW_TAG;
                [successAlert show];
            }
            

            
        }
        
        
        
        
    }];
    
    
}



-(void) goToSettings{
    
    UIViewController *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                        instantiateViewControllerWithIdentifier:@"settingsID"];
    
    [self.navigationController pushViewController:demoController animated:YES];
}

-(void) goToRepBox: (id)sender {
    
    SelfViewController *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                             instantiateViewControllerWithIdentifier:@"selfID"];
    
    NSString *theID = _id;
    [demoController initializeSelfWithID:theID];
    demoController.repname = self.repname;
    [self.navigationController pushViewController:demoController animated:YES];
    
}



#pragma mark View Related Methods

-(void) setupTapToDismiss{
    
    UITapGestureRecognizer *tapToDismissKeyBoard = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(endEditingForView:)];
    tapToDismissKeyBoard.delegate = self;
    
}

-(void) setupTapToRepBox{
    
    UIButton *tapToRepBox = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.profilePictureOutlet.frame.size.width, self.profilePictureOutlet.frame.size.height - 50)];
    [tapToRepBox addTarget:self action:@selector(goToRepBox:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tapToRepBox];
    
    
}


-(void) setupSwipeToSeeText{
    
    UISwipeGestureRecognizer *swipeUpToChangeText = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(showPreviousConsoleText:)];
    swipeUpToChangeText.delegate = self;
    swipeUpToChangeText.direction = UISwipeGestureRecognizerDirectionUp;
    
    [self.repMessageTextViewOutlet addGestureRecognizer:swipeUpToChangeText];
    
    UISwipeGestureRecognizer *swipeDownToChangeText = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(showNextConsoleText:)];
    swipeDownToChangeText.delegate = self;
    swipeDownToChangeText.direction = UISwipeGestureRecognizerDirectionDown;
    
    [self.repMessageTextViewOutlet addGestureRecognizer:swipeDownToChangeText];
    
}

-(void) endEditingForView: (UITapGestureRecognizer *) sender{
    
    [self.repMessageTextViewOutlet endEditing:YES];
    
}

-(void) showPreviousConsoleText: (UISwipeGestureRecognizer *) sender{
    if (consoleIndex > 0) {
        consoleIndex--;
        if (consoleIndex >=0) {
            [repMessageTextViewOutlet setText:[consoleTextArray objectAtIndex:consoleIndex]];
            return;
        }
    }else if (consoleIndex == 0){
        consoleIndex--;

        [repMessageTextViewOutlet setText:@""];

        
    }


    

    
}

-(void) showNextConsoleText: (UISwipeGestureRecognizer *) sender{
    
    int arrayIndex = [consoleTextArray count] -1;
    
    if (consoleIndex < arrayIndex) {
        consoleIndex++;
        if (consoleIndex <= [consoleTextArray count]-1) {
            
            [repMessageTextViewOutlet setText:[consoleTextArray objectAtIndex:consoleIndex]];
            return;
        }
    }else if (consoleIndex == [consoleTextArray count] -1){
        consoleIndex++;

        [repMessageTextViewOutlet setText:@""];
        
    }


    

    
}

- (IBAction)profileButtonPressed:(id)sender {
    
    //If not the current user profile, this reps them. If it is, then it's a button that will allow the user to change his information.
        
        if (![repMessageTextViewOutlet.text isEqualToString: REP_MESSAGE_PLACEHOLDER] && ![repMessageTextViewOutlet.text isEqualToString: FACEBOOK_MESSAGE_PLACEHOLDER] && ![repMessageTextViewOutlet.text isEqualToString: THE_LAST_THING_ON_YOUR_MIND]) {
            
            [self repUser];

        }else{
            
            UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Enter a quick message" message:[NSString stringWithFormat:@"Don't you want to send a message?"] delegate:self cancelButtonTitle:@"Go Back" otherButtonTitles: @"Just #repalready", nil];
            successAlert.tag = ALERT_VIEW_TAG;
            [successAlert show];
            
            
        }

    
}

- (IBAction)settingsButtonPressed:(id)sender {
    
    
    [self goToSettings];
    
    
}

#pragma mark UIAlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == ALERT_VIEW_TAG) {
        
        if (buttonIndex == 0) {
            return;
        }
        
        if (buttonIndex == 1) {
            [self repUser];
        }
    }
    
    
}



#pragma mark UITextView Delegate Methods

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    self.profileButtonOutlet.userInteractionEnabled = NO;

    if (textView == repMessageTextViewOutlet) {
        
        if ([textView.text isEqualToString:REP_MESSAGE_PLACEHOLDER] || [textView.text isEqualToString:REP_MANIFESTO_PLACEHOLDER] ||[textView.text isEqualToString:FACEBOOK_MESSAGE_PLACEHOLDER] || [textView.text isEqualToString:THE_LAST_THING_ON_YOUR_MIND]) {
            [textView setText:@""];
            textView.textColor = [UIColor greenColor];
        }
        
    }
    
    CGRect textFieldRect =
    [self.view.window convertRect:textView.bounds fromView:textView];
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


- (void)textViewDidEndEditing:(UITextView *)textView {
    

    
    if (textView == repMessageTextViewOutlet) {
        
        if ([textView.text isEqualToString:@""]){
            [textView setText:THE_LAST_THING_ON_YOUR_MIND];
            textView.textColor = [UIColor greenColor];
        }
        
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
    
    self.profileButtonOutlet.userInteractionEnabled = YES;

}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    
    if (textView == repMessageTextViewOutlet) {
        
        if ([text isEqualToString:@"\n"]) {
            
                [textView endEditing:YES];
                return NO;
        }
        
        NSUInteger newLength = [textView.text length] + [text length] - range.length;
        
        if (newLength > 200) {
            UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"Hey!" message:@"Message is a little wordy..." delegate:nil cancelButtonTitle:@"Fine, fine" otherButtonTitles: nil];
            [myAlert show];
            return NO;
        }else{
            return YES;
        }
    }
    return YES;
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.view];
    
    NSLog(@"x = %.0f, y = %.0f", point.x, point.y);
    if (CGRectContainsPoint(self.settingsButtonOutlet.layer.frame, point) ||CGRectContainsPoint(self.profileButtonOutlet.layer.frame, point))
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

-(void)viewWillAppear:(BOOL)animated{
    
    [self.navigationController.navigationBar setHidden:NO];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:YES];
    [self.view resignFirstResponder];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
