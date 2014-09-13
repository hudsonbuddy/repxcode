//
//  FeedViewController.m
//  Rep
//
//  Created by Hud on 2/26/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "FeedViewController.h"
#import "ProfileViewController.h"
#import "ProfileFeedCell.h"
#import "ConvoFeedCell.h"
#import "MultipleConvoFeedCell.h"
#import "ConvoViewController.h"

@interface FeedViewController ()<UIGestureRecognizerDelegate, UIActionSheetDelegate>{
    
    NSMutableArray *newsFeedResultsArray;
}
@end

@implementation FeedViewController

@synthesize feedTableViewOutlet;

static const CGFloat ASYC_IMAGE_TAG = 100;

NSMutableDictionary *imageCacheDictionary;



- (void)viewDidLoad
{
    [super viewDidLoad];
    

    [self showLoadingOverlay];
    self.feedTableViewOutlet.delegate = self;
    self.feedTableViewOutlet.dataSource = self;
    
    if (newsFeedResultsArray == nil) {
        newsFeedResultsArray = [[NSMutableArray alloc] init];
    }
    
    [self findNewsFeedItemsWithLimit:[NSString stringWithFormat:@"8"] andOffset:[NSString stringWithFormat:@"0"]];
    
    self.feedTableViewOutlet.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bck_GraphTexture_75opacity"]];
	// Do any additional setup after loading the view.
    
    if(!imageCacheDictionary) {
        imageCacheDictionary = [[NSMutableDictionary alloc] init];
    }
    
    //Adding Pull to Refresh
    [self.feedTableViewOutlet addPullToRefreshWithActionHandler:^{
        [newsFeedResultsArray removeAllObjects];
        [self findNewsFeedItemsWithLimit:[NSString stringWithFormat:@"8"] andOffset:[NSString stringWithFormat:@"0"]];

    }];
    
    [self.feedTableViewOutlet addInfiniteScrollingWithActionHandler:^{
        [self findNewsFeedItemsWithLimit:[NSString stringWithFormat:@"8"] andOffset:[NSString stringWithFormat:@"%i", [newsFeedResultsArray count]]];
    }];
    
    

}

-(void) findNewsFeedItemsWithLimit: (NSString *)limit andOffset: (NSString *)offset{
    
    RadiusRequest *outboxRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys: limit, @"limit", offset, @"offset", nil] apiMethod:@"feed" httpMethod:@"POST"];
    
    [outboxRequest startWithCompletionHandler:^(id response, RadiusError *error){
        
        NSLog(@"%@", response);
        [self dismissLoadingOverlay];
        
        
        if([[response objectForKey:@"success"]integerValue] == 1){
            if([[response objectForKey:@"data"]count]>0){
                [newsFeedResultsArray addObjectsFromArray:[response objectForKey:@"data"]];
                [feedTableViewOutlet reloadData];
                [self.feedTableViewOutlet.pullToRefreshView stopAnimating];
                [self.feedTableViewOutlet.infiniteScrollingView stopAnimating];
            }else if([newsFeedResultsArray count]>0){
                
                UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"No more results! :(" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                [successAlert show];
                [self.feedTableViewOutlet.pullToRefreshView stopAnimating];
                [self.feedTableViewOutlet.infiniteScrollingView stopAnimating];
                
                
            }else{
                [self.feedTableViewOutlet.pullToRefreshView stopAnimating];
                [self.feedTableViewOutlet.infiniteScrollingView stopAnimating];
            }
        }
        
    }];
    
}

- (void) handleLongPress: (UILongPressGestureRecognizer *) sender{
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"hello world");
        
        CGPoint longPressLocation = [sender locationInView:self.feedTableViewOutlet];
        NSIndexPath *myPath = [self.feedTableViewOutlet indexPathForRowAtPoint:longPressLocation];
        
        NSLog(@"%i", myPath.row);
        
        UIActionSheet *repBoxActionSheet = [[UIActionSheet alloc] initWithTitle:@"> mv current.rep /self/" delegate:self cancelButtonTitle:@"N" destructiveButtonTitle:nil otherButtonTitles:@"Y", nil];
        repBoxActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [repBoxActionSheet showInView:self.view];

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
    if ([newsFeedResultsArray count]>0)
        return [newsFeedResultsArray count];
    else
        return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([newsFeedResultsArray count]>0 && tableView == feedTableViewOutlet) {
        
        static NSString *CellIdentifier = @"MoreCell";
        UITableViewCell *moreCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (moreCell == nil) {
            moreCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        if (indexPath.row == [newsFeedResultsArray count]){
            
            moreCell.textLabel.text = @"...";
            moreCell.detailTextLabel.text = nil;
            moreCell.textLabel.highlightedTextColor = [UIColor greenColor];
            UIView *backView = [[UIView alloc] initWithFrame:moreCell.frame];
            backView.backgroundColor = [UIColor blackColor];
            moreCell.selectedBackgroundView = backView;
            return moreCell;
            
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
        
        NSDictionary *rowDictionary = [NSDictionary dictionaryWithDictionary:[newsFeedResultsArray objectAtIndex:indexPath.row]];
        NSArray *keys = [[rowDictionary objectForKey:@"parties"] allKeys];
        
        
        NSString *repMessage = [NSString stringWithFormat:@"%@",[rowDictionary objectForKey:@"message"]];
        NSString *convoParticipants = [NSString stringWithFormat:@""];
        for (int a = 0; a < [[[newsFeedResultsArray objectAtIndex:indexPath.row]objectForKey:@"parties"] count]; a++) {
            
            if (a == [[[newsFeedResultsArray objectAtIndex:indexPath.row]objectForKey:@"parties"] count]-1) {
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
        
        if ([rowDictionary objectForKey:@"pic_id"]) {
            
            mailboxCell.cameraButtonOutlet.hidden = NO;
            mailboxCell.pic_id = [rowDictionary objectForKey:@"pic_id"];
        }
        
        return mailboxCell;

        
    }else{
        static NSString *CellIdentifier = @"TestCell";
        UITableViewCell *moreCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (moreCell == nil) {
            moreCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        [moreCell.textLabel setText:@""];
        
        return moreCell;
    }
    
    
    
}

-(void) tableView: (UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == feedTableViewOutlet) {
        
        if ([newsFeedResultsArray count]>0) {
            
            if (indexPath.row == [newsFeedResultsArray count]) {
                
                [self findNewsFeedItemsWithLimit:[NSString stringWithFormat:@"8"] andOffset:[NSString stringWithFormat:@"%i", [newsFeedResultsArray count]]];
                return;
            }
            
            NSDictionary *rowDictionary = [NSDictionary dictionaryWithDictionary:[newsFeedResultsArray objectAtIndex:indexPath.row]];
            
            ConvoViewController *convoVC = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                            instantiateViewControllerWithIdentifier:@"convoID"];
            NSString *refString = [NSString stringWithFormat:@"%@", [rowDictionary objectForKey:@"ref"]];
            [convoVC initializeConvoViewWithRepRef:refString];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self.navigationController pushViewController:convoVC animated:YES];
        }
        
    }
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == feedTableViewOutlet){
        
        
        if ([newsFeedResultsArray count]>0) {
            if (indexPath.row == [newsFeedResultsArray count]) {
                return 44;
            }else{
                return 200;
                
            }
        }

    }
    
    return 0;

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    cell.backgroundColor = [UIColor clearColor];
    
}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    [[cell viewWithTag:ASYC_IMAGE_TAG]removeFromSuperview];

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

@end
