//
//  ProfileHeaderView.m
//  Rep
//
//  Created by Hudson on 5/6/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "ProfileHeaderView.h"
#import "RadiusRequest.h"
#import "NotificationsFind.h"
#import "SelfViewController.h"
#import "PictureViewController.h"
#import "PictureDelegate.h"

@interface ProfileHeaderView () <PictureManager>  {

}
@property (nonatomic, retain) PictureDelegate *myPictureDelegate;

@end


@implementation ProfileHeaderView{
    
    CGFloat animatedDistance;
    SelfViewController *parentViewController;
    PictureDelegate *myPictureDelegate;
    BOOL pic_private;

}
@synthesize repButtonOutlet, repMessageTextViewOutlet, repnameLabelOutlet, repscoreLabelOutlet, dateJoinedLabelOutlet, _id, cameraButtonOutlet, imageToRep, myPictureDelegate;

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

static const CGFloat ALERT_VIEW_TAG = 200;

static NSString * const REP_MESSAGE_PLACEHOLDER = @"Type whatever";
static NSString * const TAKE_PICTURE_NOW = @"Take Picture Now";
static NSString * const CHOOSE_EXISTING = @"Choose Existing";


-(void)initializeProfileHeader{
    
    repMessageTextViewOutlet.delegate = self;
    [repMessageTextViewOutlet setText:REP_MESSAGE_PLACEHOLDER];
    
    [cameraButtonOutlet setImage:[UIImage imageNamed:@"cameraiconinverted"] forState:UIControlStateHighlighted];
    cameraButtonOutlet.layer.cornerRadius = 5;

    
}

- (IBAction)pictureButtonPressed:(id)sender {
    
    if (parentViewController == nil) {
        parentViewController = (SelfViewController *)[self firstAvailableUIViewController];
    }

    
    UIActionSheet *pictureActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:TAKE_PICTURE_NOW, CHOOSE_EXISTING, nil];
    pictureActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    pictureActionSheet.tag = 300;
    [pictureActionSheet showInView:parentViewController.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];

    
    if (actionSheet.tag == 300){
        if ([buttonTitle isEqualToString:TAKE_PICTURE_NOW]) {
            myPictureDelegate = [[PictureDelegate alloc] init];
            myPictureDelegate.myPictureManager = self;
            [parentViewController startCameraControllerFromViewController:parentViewController usingDelegate:myPictureDelegate];
        }else if ([buttonTitle isEqualToString:CHOOSE_EXISTING] ){
            myPictureDelegate = [[PictureDelegate alloc] init];
            myPictureDelegate.myPictureManager = self;
            [parentViewController startMediaBrowserFromViewController:parentViewController usingDelegate:myPictureDelegate];
        }
    }
    
}

- (IBAction)repButtonPressed:(id)sender {
    
    if (![repMessageTextViewOutlet.text isEqualToString: REP_MESSAGE_PLACEHOLDER] && [repMessageTextViewOutlet.text length] > 0) {
        
        [self repUser];
        
    }else{
        
        UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Enter a quick message" message:[NSString stringWithFormat:@"Don't you want to send a message?"] delegate:self cancelButtonTitle:@"Go Back" otherButtonTitles: @"Just #repalready", nil];
        successAlert.tag = ALERT_VIEW_TAG;
        [successAlert show];
        
        
    }
}

-(void) repUser{
    
    repMessageTextViewOutlet.alpha = .5;
    repButtonOutlet.alpha =.5;
    repMessageTextViewOutlet.userInteractionEnabled = NO;
    repButtonOutlet.userInteractionEnabled = NO;
    
    
    NSString *messageString;
    if ([repMessageTextViewOutlet.text isEqualToString:REP_MESSAGE_PLACEHOLDER]) {
        messageString = [NSString stringWithFormat:@" "];

    }else{
        messageString = [NSString stringWithFormat:@"%@", repMessageTextViewOutlet.text];

    }
    
    RadiusRequest *repRequest;
    NSData *imageData = UIImageJPEGRepresentation(imageToRep, 0.1);

    
    NSDictionary *params;
    if (_id == nil) {
        if (pic_private == NO) {
            params = [NSDictionary dictionaryWithObjectsAndKeys:messageString, @"message", nil];
        }else if (pic_private == YES){
            params = [NSDictionary dictionaryWithObjectsAndKeys:messageString, @"message", @"YES", @"pic_private",nil];

        }
    }else{
        if (pic_private == NO) {
            params = [NSDictionary dictionaryWithObjectsAndKeys:_id, @"recipient_id", messageString, @"message", nil];
        }else if (pic_private == YES){
            params = [NSDictionary dictionaryWithObjectsAndKeys:_id, @"recipient_id", messageString, @"message", @"YES", @"pic_private",nil];
            
        }
        
    }
    
    
    repRequest = [RadiusRequest requestWithParameters:params apiMethod:@"rep" multipartData:imageData, nil];
    
        
    [repRequest startWithCompletionHandler:^(id response, RadiusError *error){
        
        NSLog(@"%@", response);
        
        if ([[response objectForKey:@"success"]integerValue]==1) {
            
            if ([[response objectForKey:@"data"] objectForKey:@"_id"]) {
                UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Rep sent!" message:[NSString stringWithFormat:@"Rep sent!"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                successAlert.tag = ALERT_VIEW_TAG;
                [successAlert show];
                [cameraButtonOutlet setImage:[UIImage imageNamed:@"cameraicon"] forState:UIControlStateNormal];
                imageToRep = nil;
                [repMessageTextViewOutlet setText:REP_MESSAGE_PLACEHOLDER];
                [self showInboxView];
            }
            
            
        }else{
            
            if ([[[response objectForKey:@"err"] objectForKey:@"bypass"]integerValue] !=1) {
                UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", [[response objectForKey:@"err"] objectForKey:@"message"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                successAlert.tag = ALERT_VIEW_TAG;
                [successAlert show];
            }
            
        }
        
        repMessageTextViewOutlet.alpha = 1;
        repButtonOutlet.alpha =1;
        repMessageTextViewOutlet.userInteractionEnabled = YES;
        repButtonOutlet.userInteractionEnabled = YES;
        
        
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

-(void) showInboxView {
    
    UIViewController *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                        instantiateViewControllerWithIdentifier:@"inboxID"];
    
    NSArray *controllers = [NSArray arrayWithObject:demoController];
    [demoController setTitle:@"/messages"];
    [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
    [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
    
    
}

#pragma mark Delegate Methods

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

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    repButtonOutlet.userInteractionEnabled = YES;
    
    if (textView == repMessageTextViewOutlet) {
        
        if (parentViewController == nil) {
            parentViewController = (SelfViewController *)[self firstAvailableUIViewController];
        }
        [parentViewController.repboxTableViewOutlet setContentSize:CGSizeMake(320, 1000)];
        [parentViewController.repboxTableViewOutlet scrollRectToVisible:CGRectMake(0, 348, 320, 138) animated:YES];
        
        if ([textView.text isEqualToString:REP_MESSAGE_PLACEHOLDER]) {
            [textView setText:@""];

        }
        
    }
    
}


- (void)textViewDidEndEditing:(UITextView *)textView {
    
    
    
    if (textView == repMessageTextViewOutlet) {
        
        if ([textView.text isEqualToString:@""]){
            [textView setText:REP_MESSAGE_PLACEHOLDER];
        }
        
        [parentViewController.repboxTableViewOutlet scrollRectToVisible:CGRectMake(0, 0, 320, 138) animated:YES];
    }

    
    self.repButtonOutlet.userInteractionEnabled = YES;
    
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
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

@end
