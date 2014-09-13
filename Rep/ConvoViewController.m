//
//  ConvoViewController.m
//  Rep
//
//  Created by Hudson on 5/6/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "ConvoViewController.h"
#import "ProfileFeedCell.h"
#import "ProfileViewController.h"
#import "SelfViewController.h"
#import "PictureDelegate.h"

@interface ConvoViewController () <PictureManager>{
    
    NSMutableArray *convoReps;
    NSMutableDictionary *imageCacheDictionary;
    CGFloat animatedDistance;
    NSString *mostRecentID;
    NSIndexPath *indexPathForQuote;
    BOOL pic_private;

}
@property (nonatomic, retain) PictureDelegate *myPictureDelegate;

@end

@implementation ConvoViewController
@synthesize convoTableViewOutlet, repname, repButtonOutlet, repMessageTextView, repref, cameraButtonOutlet, myPictureDelegate, imageToRep;


static NSString * const REP_MESSAGE_PLACEHOLDER = @"Type whatever";
static NSString * const VIEW_CONVERSATION = @"View Conversation";
static NSString * const REMOVE_QUOTE = @"Remove Quote";
static NSString * const ADD_QUOTE = @"Add Quote";
static NSString * const FLAG = @"Flag Rep";
static NSString * const TAKE_PICTURE_NOW = @"Take Picture Now";
static NSString * const CHOOSE_EXISTING = @"Choose Existing";

static const CGFloat ASYC_IMAGE_TAG = 100;
static const CGFloat ALERT_VIEW_TAG = 200;
static const CGFloat QUOTE_ACTION_SHEET_TAG = 300;
static const CGFloat MEDIA_ACTION_SHEET_TAG = 400;


static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

-(void) initializeConvoViewWithRepRef: (NSString *) repRefArg{
    
    self.repref = repRefArg;
    
    if (convoReps == nil) {
        convoReps = [[NSMutableArray alloc] init];
    }
    
    if(!imageCacheDictionary) {
        imageCacheDictionary = [[NSMutableDictionary alloc] init];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self showLoadingOverlay];
    
    [self setTitle:@"/convo"];


    convoTableViewOutlet.delegate = self;
    convoTableViewOutlet.dataSource = self;
    repMessageTextView.delegate = self;

    self.repMessageTextView.transform = CGAffineTransformIdentity;
    self.repButtonOutlet.transform = CGAffineTransformIdentity;
    self.convoTableViewOutlet.transform = CGAffineTransformIdentity;

    [cameraButtonOutlet setImage:[UIImage imageNamed:@"cameraiconinverted"] forState:UIControlStateHighlighted];
    self.convoTableViewOutlet.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bck_GraphTexture_75opacity"]];

    self.repMessageTextView.text = REP_MESSAGE_PLACEHOLDER;
    [self refreshConvo];
    
    
    [self.convoTableViewOutlet addPullToRefreshWithActionHandler:^{
        [self refreshConvo];
    }];
    
    
    [self.convoTableViewOutlet addInfiniteScrollingWithActionHandler:^{
        [self findConvoRepsWithOffset:[NSString stringWithFormat:@"%i", [convoReps count]] andLimit:[NSString stringWithFormat:@"8"]];
    }];
    

}

-(void) refreshConvo {
    
    [convoReps removeAllObjects];
    [self findConvoRepsWithOffset:[NSString stringWithFormat:@"0"] andLimit:[NSString stringWithFormat:@"8"]];
}

-(void) findConvoRepsWithOffset: (NSString *)offset andLimit: (NSString *)limit {
    
    RadiusRequest *outboxRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:repref, @"ref", limit, @"limit", offset, @"offset", nil] apiMethod:@"rep/convo" httpMethod:@"POST"];
    
    [outboxRequest startWithCompletionHandler:^(id response, RadiusError *error){
        
        NSLog(@"%@", response);
        [self dismissLoadingOverlay];
        
        
        if([[response objectForKey:@"success"]integerValue] == 1){
            if([[response objectForKey:@"data"]count]>0){
                [convoReps addObjectsFromArray:[response objectForKey:@"data"]];
                [convoTableViewOutlet reloadData];
                [self.convoTableViewOutlet.pullToRefreshView stopAnimating];
                [self.convoTableViewOutlet.infiniteScrollingView stopAnimating];
                mostRecentID = [NSString stringWithFormat:@"%@", [[convoReps objectAtIndex:0] objectForKey:@"_id"]];
                
            }else if([convoReps count]>0){
                
                UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"No more results! :(" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                [successAlert show];
                [self.convoTableViewOutlet.pullToRefreshView stopAnimating];
                [self.convoTableViewOutlet.infiniteScrollingView stopAnimating];
                
                
            }else{
                [self.convoTableViewOutlet.pullToRefreshView stopAnimating];
                [self.convoTableViewOutlet.infiniteScrollingView stopAnimating];
            }
        }
        
    }];

}

-(void) repUser {
    [self showLoadingOverlay];
    
    NSString *messageString;
    
    if ([repMessageTextView.text isEqualToString:REP_MESSAGE_PLACEHOLDER]) {
        messageString = [NSString stringWithFormat:@" "];

    }else{
        messageString = [NSString stringWithFormat:@"%@", repMessageTextView.text];

    }
    

        
    
//    RadiusRequest *inboxRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:mostRecentID, @"ref", messageString, @"message", nil] apiMethod:@"rep" httpMethod:@"POST"];
    
    NSData *imageData = UIImageJPEGRepresentation(imageToRep, 0.0);
    
    RadiusRequest *repRequest;
    
    if (pic_private == NO) {
        repRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:mostRecentID, @"ref", repref, @"conv_ref",messageString, @"message", nil]  apiMethod:@"rep" multipartData:imageData, nil];
    }else if (pic_private == YES){
        repRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:mostRecentID, @"ref", repref, @"conv_ref",messageString, @"message", @"YES", @"pic_private", nil]  apiMethod:@"rep" multipartData:imageData, nil];

    }
    

    [repRequest startWithCompletionHandler:^(id response, RadiusError *error){
        
        [self dismissLoadingOverlay];
        NSLog(@"%@", response);
        
        if ([[response objectForKey:@"success"]integerValue]==1) {
            
            if ([[response objectForKey:@"data"] objectForKey:@"_id"]) {
                UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Rep sent!" message:[NSString stringWithFormat:@"Rep sent!"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                successAlert.tag = ALERT_VIEW_TAG;
                [successAlert show];
                
                [repMessageTextView setText:REP_MESSAGE_PLACEHOLDER];
                [cameraButtonOutlet setImage:[UIImage imageNamed:@"cameraicon"] forState:UIControlStateNormal];

                [self refreshConvo];
                imageToRep = nil;
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
- (IBAction)repButtonPressed:(id)sender {
    
    if ([repMessageTextView.text isEqualToString:REP_MESSAGE_PLACEHOLDER] || [repMessageTextView.text length] == 0) {
        
        UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Enter a quick message" message:[NSString stringWithFormat:@"Don't you want to send a message?"] delegate:self cancelButtonTitle:@"Go Back" otherButtonTitles: @"Just #repalready", nil];
        successAlert.tag = ALERT_VIEW_TAG;
        [successAlert show];

    }else{
        
        [repMessageTextView endEditing:YES];
        [self repUser];
        
    }

    
}

- (IBAction)cameraButtonPressed:(id)sender {
    
//    if (parentViewController == nil) {
//        parentViewController = (RepViewController *)[self traverseResponderChainForUIViewController];
//    }
    
    
    UIActionSheet *pictureActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:TAKE_PICTURE_NOW, CHOOSE_EXISTING, nil];
    pictureActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    pictureActionSheet.tag = MEDIA_ACTION_SHEET_TAG;
    [pictureActionSheet showInView:[MFSideMenuManager sharedManager].navigationController.view];
}

-(void)updateCameraIconWithImage:(UIImage *)imageToUse andPrivate:(BOOL)privacySetting{
    
    [self.cameraButtonOutlet setImage:imageToUse forState:UIControlStateNormal];
    if (imageToRep == nil) {
        imageToRep = [[UIImage alloc] init];
    }
    imageToRep = imageToUse;
    pic_private = privacySetting;

}

- (void) handleLongPress: (UILongPressGestureRecognizer *) sender{
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"hello world");
        
        CGPoint longPressLocation = [sender locationInView:self.convoTableViewOutlet];
        NSIndexPath *myPath = [self.convoTableViewOutlet indexPathForRowAtPoint:longPressLocation];
        indexPathForQuote = myPath;
        NSLog(@"%i", indexPathForQuote.row);
        
        UIActionSheet *repBoxActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:FLAG otherButtonTitles:ADD_QUOTE, nil];
        repBoxActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        repBoxActionSheet.tag = QUOTE_ACTION_SHEET_TAG;
        [repBoxActionSheet showInView:self.view];
        
    }
}

-(void) quoteRep{
    
    [self showLoadingOverlay];
    
    RadiusRequest *quoteRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@", [[convoReps objectAtIndex:indexPathForQuote.row] objectForKey:@"_id"]], @"_id",nil] apiMethod:@"rep/box/add" httpMethod:@"POST"];
    
    [quoteRequest startWithCompletionHandler:^(id response, RadiusError *error){
        
        [self dismissLoadingOverlay];
        NSLog(@"%@", response);
        
        if ([[response objectForKey:@"success"]integerValue]==1) {
            
            if ([[response objectForKey:@"data"] objectForKey:@"_id"]) {
                UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Quoted!" message:[NSString stringWithFormat:@"QFT"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                successAlert.tag = ALERT_VIEW_TAG;
                [successAlert show];
                

            }
            
            
        }
    }];
}

-(void) flagRep{
    
    [self showLoadingOverlay];
    
    RadiusRequest *quoteRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@", [[convoReps objectAtIndex:indexPathForQuote.row] objectForKey:@"_id"]], @"_id",nil] apiMethod:@"rep/flag" httpMethod:@"POST"];
    
    [quoteRequest startWithCompletionHandler:^(id response, RadiusError *error){
        
        [self dismissLoadingOverlay];
        NSLog(@"%@", response);
        
        if ([[response objectForKey:@"success"]integerValue]==1) {
            
            if ([[response objectForKey:@"data"] objectForKey:@"_id"]) {
                UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Really?" message:[NSString stringWithFormat:@"You really flagged something?"] delegate:nil cancelButtonTitle:@"YES" otherButtonTitles: nil];
                successAlert.tag = ALERT_VIEW_TAG;
                [successAlert show];
                
                
            }
            
            
        }
    }];
}

#pragma mark Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    
    if (actionSheet.tag == QUOTE_ACTION_SHEET_TAG){
        if ([buttonTitle isEqualToString:VIEW_CONVERSATION]) {
            // this is obsolete
        }else if ([buttonTitle isEqualToString:ADD_QUOTE] ){
            [self quoteRep];
            
        }else if ([buttonTitle isEqualToString:FLAG]){
            [self flagRep];
        }
    }else if (actionSheet.tag == MEDIA_ACTION_SHEET_TAG){
        if ([buttonTitle isEqualToString:TAKE_PICTURE_NOW]) {
            myPictureDelegate = [[PictureDelegate alloc] init];
            myPictureDelegate.myPictureManager = self;
            [self startCameraControllerFromViewController:self usingDelegate:myPictureDelegate];
        }else if ([buttonTitle isEqualToString:CHOOSE_EXISTING] ){
            myPictureDelegate = [[PictureDelegate alloc] init];
            myPictureDelegate.myPictureManager = self;
            [self startMediaBrowserFromViewController:self usingDelegate:myPictureDelegate];
        }
    }
    
}

#pragma mark Text View Methods

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    
    if (textView == repMessageTextView) {
        
        if ([textView.text isEqualToString:REP_MESSAGE_PLACEHOLDER]) {
            [textView setText:@""];
        }
        
    }
    
    [UIView animateWithDuration:KEYBOARD_ANIMATION_DURATION
                          delay:0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                        
                        
                         self.convoTableViewOutlet.frame = CGRectMake(self.convoTableViewOutlet.frame.origin.x, self.convoTableViewOutlet.frame.origin.y, self.convoTableViewOutlet.frame.size.width, self.view.frame.size.height - PORTRAIT_KEYBOARD_HEIGHT - self.repMessageTextView.frame.size.height);
                         self.repMessageTextView.frame = CGRectMake(self.repMessageTextView.frame.origin.x, self.view.frame.size.height - PORTRAIT_KEYBOARD_HEIGHT - self.repMessageTextView.frame.size.height, self.repMessageTextView.frame.size.width, self.repMessageTextView.frame.size.height);
                        self.repButtonOutlet.frame = CGRectMake(self.repButtonOutlet.frame.origin.x, self.view.frame.size.height - PORTRAIT_KEYBOARD_HEIGHT, self.repButtonOutlet.frame.size.width, self.repButtonOutlet.frame.size.height);
                         
                        self.cameraButtonOutlet.frame = CGRectMake(self.cameraButtonOutlet.frame.origin.x, self.view.frame.size.height - PORTRAIT_KEYBOARD_HEIGHT, self.cameraButtonOutlet.frame.size.width, self.cameraButtonOutlet.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         
                         
                         
                     }];
}


- (void)textViewDidEndEditing:(UITextView *)textView {
    
    
    
    if (textView == repMessageTextView) {
        
        if ([textView.text length] == 0) {
            [textView setText:REP_MESSAGE_PLACEHOLDER];
        }
    }
    
    [UIView animateWithDuration:KEYBOARD_ANIMATION_DURATION
                          delay:0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         
                        self.convoTableViewOutlet.frame = CGRectMake(self.convoTableViewOutlet.frame.origin.x, self.convoTableViewOutlet.frame.origin.y, self.convoTableViewOutlet.frame.size.width, self.view.frame.size.height - self.repButtonOutlet.frame.size.height - self.repMessageTextView.frame.size.height);
                         self.repMessageTextView.frame = CGRectMake(self.repMessageTextView.frame.origin.x, self.view.frame.size.height - self.repMessageTextView.frame.size.height - self.repButtonOutlet.frame.size.height, self.repMessageTextView.frame.size.width, self.repMessageTextView.frame.size.height);
                         self.repButtonOutlet.frame = CGRectMake(self.repButtonOutlet.frame.origin.x, self.view.frame.size.height - self.repButtonOutlet.frame.size.height, self.repButtonOutlet.frame.size.width, self.repButtonOutlet.frame.size.height);
                        self.cameraButtonOutlet.frame = CGRectMake(self.cameraButtonOutlet.frame.origin.x, self.view.frame.size.height - self.cameraButtonOutlet.frame.size.height - (self.repButtonOutlet.frame.size.height - self.cameraButtonOutlet.frame.size.height)/2, self.cameraButtonOutlet.frame.size.width, self.cameraButtonOutlet.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         
                         
                         
                     }];
    
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    
    if (textView == repMessageTextView) {
        
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


#pragma mark Alert View Methods

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

#pragma mark Table Cell Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if (tableView == convoTableViewOutlet) {
        
        if ([convoReps count]>0) {
            return [convoReps count];
        }
    }
    
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"OldMailboxCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    
    
    if (tableView == convoTableViewOutlet) {
        if ([convoReps count]>0) {
            
            if (indexPath.row == [convoReps count]){
                
                cell.textLabel.text = @"...";
                cell.detailTextLabel.text = nil;
                cell.textLabel.highlightedTextColor = [UIColor greenColor];
                UIView *backView = [[UIView alloc] initWithFrame:cell.frame];
                backView.backgroundColor = [UIColor blackColor];
                cell.selectedBackgroundView = backView;
                return cell;
                
            }
            
            static NSString *mailboxCellIdentifier = @"MailboxCell";
            ProfileFeedCell *mailboxCell = [tableView dequeueReusableCellWithIdentifier:mailboxCellIdentifier];
            //    ProfileFeedCell *mailboxCell;
            
            if (mailboxCell == nil) {
                mailboxCell = [[ProfileFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mailboxCellIdentifier];
                [mailboxCell initializeViewElementsForMailbox];
            }
            
            
            
            DateAndTimeHelper *dateHelper = [[DateAndTimeHelper alloc] init];
            NSDictionary *rowDictionary = [NSDictionary dictionaryWithDictionary:[convoReps objectAtIndex:indexPath.row]];
            NSDictionary *repSenderDictionary = [[rowDictionary objectForKey:@"parties"] objectForKey:[rowDictionary objectForKey:@"sender"]];
            
            NSString *repMessage = [NSString stringWithFormat:@"%@",[[convoReps objectAtIndex:indexPath.row]objectForKey:@"message"]];
            NSString *senderString = [NSString stringWithFormat:@"%@",[repSenderDictionary objectForKey:@"name"]];
            
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
            NSString *myDateString = [rowDictionary objectForKey:@"ts"];
            myDateString = [[myDateString componentsSeparatedByString:@"."]objectAtIndex:0];
            NSDate *postDate = [dateFormatter dateFromString:myDateString];
            NSString *dateString = [dateHelper timeIntervalWithStartDate:postDate withEndDate:[NSDate date]];
            
        
            
            //Configuration of Text Labels
            
            CGSize maximumLabelSize = CGSizeMake(300,9999);
            
            mailboxCell.repnameLabelOutlet.text = senderString;
            mailboxCell.reptimeLabelOutlet.text = dateString;
            mailboxCell.repfactLabelOutlet.text = repMessage;
            
            CGSize repFactExpectedLabelSize = [repMessage sizeWithFont:mailboxCell.repfactLabelOutlet.font
                                                     constrainedToSize:maximumLabelSize
                                                         lineBreakMode:mailboxCell.repfactLabelOutlet.lineBreakMode];
            mailboxCell.repfactLabelOutlet.frame = CGRectMake(mailboxCell.repfactLabelOutlet.frame.origin.x, mailboxCell.repfactLabelOutlet.frame.origin.y, repFactExpectedLabelSize.width, repFactExpectedLabelSize.height);
            

            
            
            //Configuration of Picture
            mailboxCell.pictureString = [repSenderDictionary objectForKey:@"pic"];
            NSURL *myURL = [NSURL URLWithString:mailboxCell.pictureString];
            AsyncImageView *asyncImageViewInstance = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, mailboxCell.frame.size.width, mailboxCell.frame.size.height) imageURL:myURL cache:imageCacheDictionary loadImmediately:YES];
            asyncImageViewInstance.tag = ASYC_IMAGE_TAG;
            asyncImageViewInstance.layer.masksToBounds = YES;
            [mailboxCell addSubview:asyncImageViewInstance];
            [mailboxCell sendSubviewToBack:asyncImageViewInstance];
            //            mailboxCell.backgroundView = asyncImageViewInstance;
            mailboxCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
            longPress.delegate = mailboxCell;
            [mailboxCell addGestureRecognizer:longPress];
            
            if ([rowDictionary objectForKey:@"pic_id"]) {
                
                mailboxCell.cameraButtonOutlet.hidden = NO;
                mailboxCell.pic_id = [rowDictionary objectForKey:@"pic_id"];
            }
            
            return mailboxCell;
            
            
            
        }
        
        
    }
        
    return cell;
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == convoTableViewOutlet) {
        
        
        if (indexPath.row == [convoReps count]) {
            
            [self findConvoRepsWithOffset:[NSString stringWithFormat:@"%i", [convoReps count]] andLimit:[NSString stringWithFormat:@"8"]];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
            
            
        }else{
            SelfViewController *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                                     instantiateViewControllerWithIdentifier:@"selfID"];
            
            NSString *theID = [NSString stringWithFormat:@"%@",[[convoReps objectAtIndex:indexPath.row] objectForKey:@"sender"]];

            [demoController initializeSelfWithID:theID];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self.navigationController pushViewController:demoController animated:YES];
        }

        
    }

    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (tableView == convoTableViewOutlet) {
        
        if ([convoReps count]>0) {
            if (indexPath.row == [convoReps count]) {
                return 50;
            }

            return 200;
        }
        
    }
    
    
    return 44;
    
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.backgroundColor = [UIColor clearColor];
    //    [[cell viewWithTag:ASYC_IMAGE_TAG]removeFromSuperview];
    
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [[cell viewWithTag:ASYC_IMAGE_TAG]removeFromSuperview];
    
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
    [self setConvoTableViewOutlet:nil];
    [self setRepMessageTextView:nil];
    [self setRepButtonOutlet:nil];
    [self setCameraButtonOutlet:nil];
    [super viewDidUnload];
}


@end
