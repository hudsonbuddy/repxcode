//
//  InboxViewController.m
//  Rep
//
//  Created by Hud on 2/2/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "InboxViewController.h"
#import "ProfileViewController.h"
#import "ConvoViewController.h"
#import "MailboxCell.h"
#import "ProfileFeedCell.h"
#import "MultipleConvoFeedCell.h"

@interface InboxViewController (){
    
    RepUserData *_repUserData;
    NSMutableArray *inboxReps;
    NSMutableArray *outboxReps;
    
    NSIndexPath *indexPathForQuote;

    AnimationLayerController *animationController;
    
    BOOL inboxRequestCompleted;

    
}

@end

@implementation InboxViewController
@synthesize inboxButtonOutlet, inboxTableViewOutlet, outboxButtonOutlet, outboxTableViewOutlet;

static NSString * const IGNORE_TEXT = @"Ignore";

static const CGFloat ASYC_IMAGE_TAG = 100;
static const CGFloat ALERT_VIEW_TAG = 200;
static const CGFloat ACTION_SHEET_TAG = 300;

NSMutableDictionary *imageCacheDictionary;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self showLoadingOverlay];
    _repUserData = [RepUserData sharedRepUserData];
    _repUserData.alertViewShown = NO;
    self.inboxTableViewOutlet.delegate = self;
    self.inboxTableViewOutlet.dataSource = self;

    [self refreshInbox];
    
    if (inboxReps == nil) {
        inboxReps = [[NSMutableArray alloc] init];
    }
    
    self.inboxTableViewOutlet.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bck_GraphTexture_75opacity"]];

    [self.inboxTableViewOutlet addPullToRefreshWithActionHandler:^{
        [inboxReps removeAllObjects];
        [self findInboxRepsWithOffset:[NSString stringWithFormat:@"0"] andLimit:[NSString stringWithFormat:@"8"]];
        
    }];
    
    [self.inboxTableViewOutlet addInfiniteScrollingWithActionHandler:^{
        [self findInboxRepsWithOffset:[NSString stringWithFormat:@"%i", [inboxReps count]] andLimit:[NSString stringWithFormat:@"8"]];
    }];
    
    

}

-(void) refreshInbox{
    [inboxReps removeAllObjects];
    [self findInboxRepsWithOffset:[NSString stringWithFormat:@"0"] andLimit:[NSString stringWithFormat:@"8"]];
}

-(void) findInboxRepsWithOffset: (NSString *)offset andLimit: (NSString *)limit {
    
    RadiusRequest *inboxRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys: offset, @"offset", limit, @"limit", nil] apiMethod:@"rep/activity" httpMethod:@"POST"];
    
    [inboxRequest startWithCompletionHandler:^(id response, RadiusError *error){
        
        NSLog(@"%@", response);
        inboxRequestCompleted = YES;
        [self dismissLoadingOverlay];
        
        if([[response objectForKey:@"success"]integerValue] == 1){
            if([[response objectForKey:@"data"]count]>0){
                

                
                [inboxReps addObjectsFromArray:[response objectForKey:@"data"]];
                [inboxTableViewOutlet reloadData];
                [self.inboxTableViewOutlet.pullToRefreshView stopAnimating];
                [self.inboxTableViewOutlet.infiniteScrollingView stopAnimating];
                [self zeroOutBadgeNumber];

                
            }else if([inboxReps count]>0){
                
                UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"No more results" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                [successAlert show];
                [self.inboxTableViewOutlet.pullToRefreshView stopAnimating];
                [self.inboxTableViewOutlet.infiniteScrollingView stopAnimating];
                
                
            }else{
                [inboxTableViewOutlet reloadData];
                [self.inboxTableViewOutlet.pullToRefreshView stopAnimating];
                [self.inboxTableViewOutlet.infiniteScrollingView stopAnimating];

            }
        }
    }];
    
}
-(void) zeroOutBadgeNumber{
    
    RadiusRequest *inboxRequestReal = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:nil] apiMethod:@"apn/zero" httpMethod:@"POST"];
    
    [inboxRequestReal startWithCompletionHandler:^(id response, RadiusError *error){
        
        NSLog(@"%@", response);
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        
        
        
    }];
    
}

- (void) handleLongPress: (UILongPressGestureRecognizer *) sender{
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"hello world");
        
        CGPoint longPressLocation = [sender locationInView:self.inboxTableViewOutlet];
        NSIndexPath *myPath = [self.inboxTableViewOutlet indexPathForRowAtPoint:longPressLocation];
        indexPathForQuote = myPath;
        NSLog(@"%i", indexPathForQuote.row);
        
            
            UIActionSheet *repBoxActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:IGNORE_TEXT otherButtonTitles:nil];
            repBoxActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            repBoxActionSheet.tag = ACTION_SHEET_TAG;
            [repBoxActionSheet showInView:self.view];
        
        
        
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    
    if (actionSheet.tag == ACTION_SHEET_TAG) {
        if ([buttonTitle isEqualToString:IGNORE_TEXT]) {
            [self ignoreConvo];
        }
    }
    
}

-(void) ignoreConvo{
    
    [self showLoadingOverlay];
    
    RadiusRequest *quoteRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@", [[inboxReps objectAtIndex:indexPathForQuote.row]  objectForKey:@"ref"]], @"ref_id",nil] apiMethod:@"rep/ignore" httpMethod:@"POST"];
    
    [quoteRequest startWithCompletionHandler:^(id response, RadiusError *error){
        
        [self dismissLoadingOverlay];
        NSLog(@"%@", response);
        
        if ([[response objectForKey:@"success"]integerValue]==1) {
            
            if ([response objectForKey:@"data"]) {
                
                
                UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"It's gone" message:[NSString stringWithFormat:@"blah blah blah"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                successAlert.tag = ALERT_VIEW_TAG;
                [successAlert show];
                [self refreshInbox];
                
            }
            
            
        }
    }];
}


#pragma mark Table Cell Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    if (tableView == inboxTableViewOutlet) {
        
        return 1;

    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if (tableView == inboxTableViewOutlet) {

        if ([inboxReps count]>0) {
            return [inboxReps count];
        }else
            return 1;
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
    
    if (tableView == inboxTableViewOutlet) {
        if ([inboxReps count]>0) {
            
            if (indexPath.row == [inboxReps count] && [inboxReps count] > 6){
                
                cell.textLabel.text = @"...";
                cell.detailTextLabel.text = nil;
                cell.textLabel.highlightedTextColor = [UIColor greenColor];
                UIView *backView = [[UIView alloc] initWithFrame:cell.frame];
                backView.backgroundColor = [UIColor blackColor];
                cell.selectedBackgroundView = backView;
                return cell;
            }
            
            static NSString *mailboxCellIdentifier = @"MailboxCell";
            MultipleConvoFeedCell *mailboxCell = [tableView dequeueReusableCellWithIdentifier:mailboxCellIdentifier];
            
            if (mailboxCell == nil) {
                mailboxCell = [[MultipleConvoFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mailboxCellIdentifier];
                [mailboxCell initializeViewElements];
                mailboxCell.selectionStyle = UITableViewCellSelectionStyleNone;

            }
            
            if(!imageCacheDictionary) {
                imageCacheDictionary = [[NSMutableDictionary alloc] init];
            }
            
            DateAndTimeHelper *dateHelper = [[DateAndTimeHelper alloc] init];
            
            NSDictionary *rowDictionary = [NSDictionary dictionaryWithDictionary:[inboxReps objectAtIndex:indexPath.row]];

            NSArray *keys = [[rowDictionary objectForKey:@"parties"] allKeys];

            NSString *repMessage = [NSString stringWithFormat:@"%@",[rowDictionary objectForKey:@"message"]];
            NSString *convoParticipants = [NSString stringWithFormat:@""];
            for (int a = 0; a < [[[inboxReps objectAtIndex:indexPath.row]objectForKey:@"parties"] count]; a++) {
                
                if (a == [[[inboxReps objectAtIndex:indexPath.row]objectForKey:@"parties"] count]-1) {
                    NSDictionary *tempID = [keys objectAtIndex:a];
                    NSString *participantName = [[[rowDictionary objectForKey:@"parties"]objectForKey:tempID] objectForKey:@"name"];
                    convoParticipants = [convoParticipants stringByAppendingFormat:@"%@", [[participantName componentsSeparatedByString:@" "] objectAtIndex:0]];
                }else{
                    NSDictionary *tempID = [keys objectAtIndex:a];
                    NSString *participantName = [[[rowDictionary objectForKey:@"parties"]objectForKey:tempID] objectForKey:@"name"];
                    convoParticipants = [convoParticipants stringByAppendingFormat:@"%@, ", [[participantName componentsSeparatedByString:@" "] objectAtIndex:0]];
                }

            }
            
            NSDictionary *repSenderDictionary = [[rowDictionary objectForKey:@"parties"] objectForKey:[rowDictionary objectForKey:@"sender"]];

            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
            NSString *myDateString = [rowDictionary objectForKey:@"ts"];
            myDateString = [[myDateString componentsSeparatedByString:@"."]objectAtIndex:0];
            NSDate *postDate = [dateFormatter dateFromString:myDateString];
            NSString *dateString = [dateHelper timeIntervalWithStartDate:postDate withEndDate:[NSDate date]];
                        
            //Configuration of Text Labels
            
            CGSize maximumLabelSize = CGSizeMake(300,9999);

            mailboxCell.repParticipantsLabel.text = convoParticipants;
            mailboxCell.repTimeLabel.text = dateString;

            mailboxCell.repMessageLabel.text = repMessage;
            CGSize repFactExpectedLabelSize = [repMessage sizeWithFont:mailboxCell.repMessageLabel.font
                                                     constrainedToSize:maximumLabelSize
                                                         lineBreakMode:mailboxCell.repMessageLabel.lineBreakMode];
            mailboxCell.repMessageLabel.frame = CGRectMake(mailboxCell.repMessageLabel.frame.origin.x, mailboxCell.repMessageLabel.frame.origin.y, repFactExpectedLabelSize.width, repFactExpectedLabelSize.height);
            

            
            
            //Configuration of Picture
            
            if ([[rowDictionary objectForKey:@"parties"] count] == 1) {
                NSString *senderPictureString = [[[[NSString stringWithFormat:@"%@", [repSenderDictionary objectForKey:@"pic"]]componentsSeparatedByString:@"?"]objectAtIndex:0]stringByAppendingFormat:@"?width=320&height=200"];
                NSURL *myURL = [NSURL URLWithString:senderPictureString];
                AsyncImageView *asyncImageViewInstance = [[AsyncImageView alloc] initWithFrame:mailboxCell.frame imageURL:myURL cache:imageCacheDictionary loadImmediately:YES];
                asyncImageViewInstance.tag = ASYC_IMAGE_TAG;
                asyncImageViewInstance.layer.masksToBounds = YES;
                [mailboxCell addSubview:asyncImageViewInstance];
                [mailboxCell sendSubviewToBack:asyncImageViewInstance];
                
                NSString *iterativeString;
                NSString *senderString = [NSString stringWithFormat:@"%@", [rowDictionary objectForKey:@"sender"]];
                for (int i = 0; i< [[rowDictionary objectForKey:@"parties"]count]; i++) {
                    
                    iterativeString = [NSString stringWithFormat:@"%@", [keys objectAtIndex:i]];
                    if (![iterativeString isEqualToString:senderString]) {
                        
                        NSString *recipientPictureString = [[[[NSString stringWithFormat:@"%@", [[[rowDictionary objectForKey:@"parties"] objectForKey:iterativeString] objectForKey:@"pic"]]componentsSeparatedByString:@"?"]objectAtIndex:0]stringByAppendingFormat:@"?width=160&height=200"];
                        NSURL *newURL = [NSURL URLWithString:recipientPictureString];
                        AsyncImageView *recipientAIV = [[AsyncImageView alloc] initWithFrame:mailboxCell.singleRecipientImageOutlet.frame imageURL:newURL cache:imageCacheDictionary loadImmediately:YES];
                        recipientAIV.tag = ASYC_IMAGE_TAG;
                        recipientAIV.layer.masksToBounds = YES;
                        [mailboxCell addSubview:recipientAIV];
                        [mailboxCell sendSubviewToBack:recipientAIV];
                        
                    }
                }
                
            }else if ([[rowDictionary objectForKey:@"parties"] count] == 2) {
                NSString *senderPictureString = [[[[NSString stringWithFormat:@"%@", [repSenderDictionary objectForKey:@"pic"]]componentsSeparatedByString:@"?"]objectAtIndex:0]stringByAppendingFormat:@"?width=160&height=200"];
                NSURL *myURL = [NSURL URLWithString:senderPictureString];
                AsyncImageView *asyncImageViewInstance = [[AsyncImageView alloc] initWithFrame:mailboxCell.senderImageOutlet.frame imageURL:myURL cache:imageCacheDictionary loadImmediately:YES];
                asyncImageViewInstance.tag = ASYC_IMAGE_TAG;
                asyncImageViewInstance.layer.masksToBounds = YES;
                [mailboxCell addSubview:asyncImageViewInstance];
                [mailboxCell sendSubviewToBack:asyncImageViewInstance];
                
                NSString *iterativeString;
                NSString *senderString = [NSString stringWithFormat:@"%@", [rowDictionary objectForKey:@"sender"]];
                for (int i = 0; i< [[rowDictionary objectForKey:@"parties"]count]; i++) {
                    
                    iterativeString = [NSString stringWithFormat:@"%@", [keys objectAtIndex:i]];
                    if (![iterativeString isEqualToString:senderString]) {
                        
                        NSString *recipientPictureString = [[[[NSString stringWithFormat:@"%@", [[[rowDictionary objectForKey:@"parties"] objectForKey:iterativeString] objectForKey:@"pic"]]componentsSeparatedByString:@"?"]objectAtIndex:0]stringByAppendingFormat:@"?width=160&height=200"];
                        NSURL *newURL = [NSURL URLWithString:recipientPictureString];
                        AsyncImageView *recipientAIV = [[AsyncImageView alloc] initWithFrame:mailboxCell.singleRecipientImageOutlet.frame imageURL:newURL cache:imageCacheDictionary loadImmediately:YES];
                        recipientAIV.tag = ASYC_IMAGE_TAG;
                        recipientAIV.layer.masksToBounds = YES;
                        [mailboxCell addSubview:recipientAIV];
                        [mailboxCell sendSubviewToBack:recipientAIV];
                        
                    }
                }
                
            }else if ([[rowDictionary objectForKey:@"parties"] count] > 2){
                
                NSString *senderPictureString = [[[[NSString stringWithFormat:@"%@", [repSenderDictionary objectForKey:@"pic"]]componentsSeparatedByString:@"?"]objectAtIndex:0]stringByAppendingFormat:@"?width=160&height=200"];
                NSURL *myURL = [NSURL URLWithString:senderPictureString];
                AsyncImageView *asyncImageViewInstance = [[AsyncImageView alloc] initWithFrame:mailboxCell.senderImageOutlet.frame imageURL:myURL cache:imageCacheDictionary loadImmediately:YES];
                asyncImageViewInstance.tag = ASYC_IMAGE_TAG;
                asyncImageViewInstance.layer.masksToBounds = YES;
                [mailboxCell addSubview:asyncImageViewInstance];
                [mailboxCell sendSubviewToBack:asyncImageViewInstance];
                
                NSString *iterativeString;
                NSString *senderString = [NSString stringWithFormat:@"%@", [rowDictionary objectForKey:@"sender"]];
                int matches = 0;

                for (int i = 0; i< [[rowDictionary objectForKey:@"parties"]count]; i++) {
                    
                    
                    iterativeString = [NSString stringWithFormat:@"%@", [keys objectAtIndex:i]];
                    if (![iterativeString isEqualToString:senderString]) {
                        matches = matches + 1;
                        NSString *recipientPictureString = [[[[NSString stringWithFormat:@"%@", [[[rowDictionary objectForKey:@"parties"] objectForKey:iterativeString] objectForKey:@"pic"]]componentsSeparatedByString:@"?"]objectAtIndex:0]stringByAppendingFormat:@"?width=160&height=100"];
                        NSURL *newURL = [NSURL URLWithString:recipientPictureString];
                        
                        if (matches == 1) {
                            AsyncImageView *recipientAIV = [[AsyncImageView alloc] initWithFrame:mailboxCell.secondRecipientImageOutlet.frame imageURL:newURL cache:imageCacheDictionary loadImmediately:YES];
                            recipientAIV.tag = ASYC_IMAGE_TAG;
                            recipientAIV.layer.masksToBounds = YES;
                            [mailboxCell addSubview:recipientAIV];
                            [mailboxCell sendSubviewToBack:recipientAIV];
                        }else{
                            AsyncImageView *recipientAIV = [[AsyncImageView alloc] initWithFrame:mailboxCell.thirdRecipientImageOutlet.frame imageURL:newURL cache:imageCacheDictionary loadImmediately:YES];
                            recipientAIV.tag = ASYC_IMAGE_TAG;
                            recipientAIV.layer.masksToBounds = YES;
                            [mailboxCell addSubview:recipientAIV];
                            [mailboxCell sendSubviewToBack:recipientAIV];
                        }

                        
                    }
                }
            }
            
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
    
    if (inboxRequestCompleted) {
        cell.textLabel.text = @"Conversations you have show up here! Check out the feed to see what's happening";
        cell.detailTextLabel.text = nil;
        cell.textLabel.numberOfLines = 3;
        cell.textLabel.font = [UIFont fontWithName:@"Courier" size:15.0];
        cell.textLabel.highlightedTextColor = [UIColor greenColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        UIView *backView = [[UIView alloc] initWithFrame:cell.frame];
        backView.backgroundColor = [UIColor blackColor];
        cell.selectedBackgroundView = backView;
        
        cell.userInteractionEnabled = NO;
    }

    return cell;


}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == inboxTableViewOutlet) {
        
        if ([inboxReps count]>0) {
            
            if (indexPath.row == [inboxReps count] && [inboxReps count] > 6) {
                [self findInboxRepsWithOffset:[NSString stringWithFormat:@"%i", [inboxReps count]] andLimit:[NSString stringWithFormat:@"8"]];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                return;
            }else{
                
                NSDictionary *rowDictionary = [NSDictionary dictionaryWithDictionary:[inboxReps objectAtIndex:indexPath.row]];

                ConvoViewController *convoVC = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                                instantiateViewControllerWithIdentifier:@"convoID"];
                NSString *refString = [NSString stringWithFormat:@"%@", [rowDictionary objectForKey:@"ref"]];
                [convoVC initializeConvoViewWithRepRef:refString];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [self.navigationController pushViewController:convoVC animated:YES];
                
            }
            


        }

    }
    
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (tableView == inboxTableViewOutlet) {
        
        if ([inboxReps count]>0) {
            if (indexPath.row == [inboxReps count]) {
                return 50;
            }
//            NSString *cellText = [[inboxReps objectAtIndex:indexPath.row] objectForKey:@"message"];
//            UIFont *cellFont = [UIFont fontWithName:@"Quicksand" size:15.0];
//            CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
//            CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByCharWrapping];
//            
//            return labelSize.height +50;
            return 200;
        }

    }
    
    if (tableView == outboxTableViewOutlet) {
        
        if ([outboxReps count]>0) {
            if (indexPath.row == [outboxReps count]) {
                return 50;
            }
            return 200;
        }
        
    }

    return 200;

    
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

-(void) viewWillAppear:(BOOL)animated   {
    
    [self.navigationController.navigationBar setHidden:NO];


//    [self refreshInboxAndOutbox];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
