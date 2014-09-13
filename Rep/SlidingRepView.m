//
//  SlidingRepView.m
//  Rep
//
//  Created by Hud on 2/4/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "SlidingRepView.h"
#import "Facebook.h"
#import "RepUserData.h"
#import "RepAppDelegate.h"
#import "RepViewController.h"   
@interface SlidingRepView () <PictureManager>  {
    
}
@property (nonatomic, retain) PictureDelegate *myPictureDelegate;

@end

RepUserData *_myUserData;
NSUserDefaults *myDefaults;
RepViewController *parentViewController;
BOOL pic_private;

@implementation SlidingRepView
@synthesize repButtonOutlet, repMessageTextViewOutlet, repnameTextFieldOutlet, animatedDistance, cameraButtonOutlet, myPictureDelegate, imageToRep;


//static NSString * const REP_MESSAGE_PLACEHOLDER = @"Type the last thing on your \n                       mind";
static NSString * const REP_MESSAGE_PLACEHOLDER = @"Use ++repname to include people";
static NSString * const TAKE_PICTURE_NOW = @"Take Picture Now";
static NSString * const CHOOSE_EXISTING = @"Choose Existing";

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

static const CGFloat ASYC_IMAGE_TAG = 100;
static const CGFloat ALERT_VIEW_TAG = 200;


-(void) initializeSlidingRepView{
    
    _myUserData = [RepUserData sharedRepUserData];
    myDefaults = [NSUserDefaults standardUserDefaults];
    
    repnameTextFieldOutlet.delegate = self;
    [repnameTextFieldOutlet setReturnKeyType:UIReturnKeyDone];

    
    repMessageTextViewOutlet.delegate = self;
    [repMessageTextViewOutlet setText:REP_MESSAGE_PLACEHOLDER];
    [repMessageTextViewOutlet setTextColor:[UIColor grayColor]];
    [repMessageTextViewOutlet setReturnKeyType:UIReturnKeyDone];
    [cameraButtonOutlet setImage:[UIImage imageNamed:@"cameraiconinverted"] forState:UIControlStateHighlighted];
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bck_GraphTexture_75opacity"]];

}

- (IBAction)repButtonPressed:(id)sender {
    
    if (![repMessageTextViewOutlet.text isEqualToString: REP_MESSAGE_PLACEHOLDER] && [repMessageTextViewOutlet.text length] > 0 ) {
        
        [self repUser];
        
    }else if([repMessageTextViewOutlet.text isEqualToString: REP_MESSAGE_PLACEHOLDER] || [repMessageTextViewOutlet.text length] == 0){
        
        UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Enter a quick message" message:[NSString stringWithFormat:@"Don't you want to send a message?"] delegate:self cancelButtonTitle:@"Go Back" otherButtonTitles: @"Just #repalready", nil];
        successAlert.tag = ALERT_VIEW_TAG;
        [successAlert show];
        
    }else if (![repnameTextFieldOutlet.text length]>0){
        UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"++repname missing" message:[NSString stringWithFormat:@"Don't forget to enter somebody to rep!"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [successAlert show];
        
    }
    

}

- (IBAction)cameraButtonPressed:(id)sender {
    
    if (parentViewController == nil) {
        parentViewController = (RepViewController *)[self traverseResponderChainForUIViewController];
    }
    
    
    UIActionSheet *pictureActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:TAKE_PICTURE_NOW, CHOOSE_EXISTING, nil];
    pictureActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    pictureActionSheet.tag = 300;
    [pictureActionSheet showInView:[MFSideMenuManager sharedManager].navigationController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    
    if (actionSheet.tag == 300){
        if ([buttonTitle isEqualToString:TAKE_PICTURE_NOW]) {
            myPictureDelegate = [[PictureDelegate alloc] init];
            myPictureDelegate.myPictureManager = self;
            [parentViewController startCameraControllerFromViewController:[MFSideMenuManager sharedManager].navigationController usingDelegate:myPictureDelegate];
        }else if ([buttonTitle isEqualToString:CHOOSE_EXISTING] ){
            myPictureDelegate = [[PictureDelegate alloc] init];
            myPictureDelegate.myPictureManager = self;
            [parentViewController startMediaBrowserFromViewController:[MFSideMenuManager sharedManager].navigationController usingDelegate:myPictureDelegate];
        }
    }
    
}

-(void)repUser{
    
    self.repButtonOutlet.userInteractionEnabled = NO;
    self.cameraButtonOutlet.userInteractionEnabled = NO;
    
    NSString *messageString;
    
    if (![repMessageTextViewOutlet.text isEqualToString: REP_MESSAGE_PLACEHOLDER]) {
        
        messageString = [NSString stringWithFormat:@"%@", repMessageTextViewOutlet.text];
    }else{
        
        messageString = [NSString stringWithFormat:@" "];
        
    }
    
    
    NSData *imageData = UIImageJPEGRepresentation(imageToRep, 0.1);
    
    RadiusRequest *repRequest;
    
    if (pic_private == NO) {
        repRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys: self.repnameTextFieldOutlet.text, @"repname", messageString, @"message", nil] apiMethod:@"rep" multipartData:imageData, nil];
    }else if (pic_private == YES){
        repRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys: self.repnameTextFieldOutlet.text, @"repname", messageString, @"message", @"YES", @"pic_private",nil] apiMethod:@"rep" multipartData:imageData, nil];
    }

    
    
    [repRequest startWithCompletionHandler:^(id response, RadiusError *error){
        
        NSLog(@"%@", response);
        self.repButtonOutlet.userInteractionEnabled = YES;
        self.cameraButtonOutlet.userInteractionEnabled = YES;
        
        
        if ([[response objectForKey:@"success"]integerValue]==1) {
            
            if ([[response objectForKey:@"data"] objectForKey:@"_id"]) {
                UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Success!" message:[NSString stringWithFormat:@"Rep sent!"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                successAlert.tag = ALERT_VIEW_TAG;
                [successAlert show];
                [MFSlidingView slideOut];
                
                RepAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;

                [appDelegate showInboxView];
                
                
            }
            
            
        }
        
        
        
    }];
    

    
    
}

-(void)updateCameraIconWithImage:(UIImage *)imageToUse andPrivate:(BOOL)privacySetting{
    
    [self.cameraButtonOutlet setImage:imageToUse forState:UIControlStateNormal];
    if (imageToRep == nil) {
        imageToRep = [[UIImage alloc] init];
    }
    imageToRep = imageToUse;
    pic_private = privacySetting;
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

#pragma mark Text Field and TextView Delegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == repnameTextFieldOutlet) {
        [textField endEditing:YES];
        return YES;
    }else
        return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{

    return YES;
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    if (textView == repMessageTextViewOutlet) {
        
        if ([textView.text isEqualToString:REP_MESSAGE_PLACEHOLDER]) {
            [textView setText:@""];
            textView.textColor = [UIColor blackColor];
        }
        
    }
    UIViewController * myController = [self firstAvailableUIViewController];

    CGRect textFieldRect =
    [myController.view.window convertRect:textView.bounds fromView:textView];
    CGRect viewRect =
    [myController.view.window convertRect:myController.view.bounds fromView:myController.view];
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
    CGRect viewFrame = myController.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [myController.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}


- (void)textViewDidEndEditing:(UITextView *)textView {
    
    if (textView == repMessageTextViewOutlet) {
        
        if ([textView.text isEqualToString:@""]) {
            [textView setText:REP_MESSAGE_PLACEHOLDER];
            textView.textColor = [UIColor grayColor];
        }
        
    }
    UIViewController * myController = [self firstAvailableUIViewController];

    CGRect viewFrame = myController.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [myController.view setFrame:viewFrame];
    
    [UIView commitAnimations];
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
#pragma mark Random Stuff

//Legacy FB Code

//    if (_myUserData.facebookPublishActions == YES || [[myDefaults objectForKey:@"publish_actions"]isEqualToString:[NSString stringWithFormat:@"YES"]]) {
//        [self repUser];
//    }else{
//        NSArray *writePermissions = [[NSArray alloc] initWithObjects:
//                                @"publish_actions",
//                                nil];
//
//        [FBSession.activeSession reauthorizeWithPublishPermissions:writePermissions defaultAudience:FBSessionDefaultAudienceEveryone completionHandler:^(FBSession *session, NSError *error){
//
//            NSLog(@"authorized %@", [FBSession.activeSession.permissions objectAtIndex:0] );
//
//            //do what we were going to do
//            _myUserData.facebookPublishActions = YES;
//            [myDefaults setObject:[NSString stringWithFormat:@"YES"] forKey:[NSString stringWithFormat:@"publish_actions"]];
//            [self repUser];
//
//
//
//        }];
//
//    }

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


@end
