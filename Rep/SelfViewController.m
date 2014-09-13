//
//  SelfViewController.m
//  Rep
//
//  Created by Hudson on 5/7/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "SelfViewController.h"
#import "ConvoFeedCell.h"
#import "MultipleConvoFeedCell.h"
#import "ProfileFeedCell.h"
#import "ProfileHeaderView.h"
#import "ProfileViewController.h"
#import "ConvoViewController.h"

@interface SelfViewController (){
    
    NSMutableArray *repBoxReps;
    NSMutableDictionary *imageCacheDictionary;
    BOOL selfRequestCompleted;
    BOOL userRequestCompleted;
    NSIndexPath *indexPathForQuote;
    BOOL scrolledAlready;


}

@end

@implementation SelfViewController
@synthesize repboxTableViewOutlet, repname, facebookID, currentUserProfile, _id;

static const CGFloat ASYC_IMAGE_TAG = 100;
static const CGFloat ALERT_VIEW_TAG = 200;

static NSString * const VIEW_CONVERSATION = @"View Conversation";
static NSString * const REMOVE_QUOTE = @"Remove Quote";
static NSString * const ADD_QUOTE = @"Add Quote";


-(void) initializeSelfWithID: (NSString *)theID{
    
    self._id = theID;

}
-(void) initializeSelfView{
    
    if (repBoxReps == nil) {
        repBoxReps = [[NSMutableArray alloc] init];
    }
    
    if(!imageCacheDictionary) {
        imageCacheDictionary = [[NSMutableDictionary alloc] init];
    }
    
    repboxTableViewOutlet.delegate = self;
    repboxTableViewOutlet.dataSource = self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeSelfView];

	// Do any additional setup after loading the view.
    
    self.repboxTableViewOutlet.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bck_GraphTexture_75opacity"]];
    
    [self getUser];
    [self refreshRepBox];

    if (self.repname) {
        [self setTitle:[NSString stringWithFormat:@"/%@", self.repname]];

    }else{
        [self setTitle:@"/self"];

    }

    
    [self.repboxTableViewOutlet addPullToRefreshWithActionHandler:^{
        [self refreshRepBox];
        [self getUser];
    }];
    
    [self.repboxTableViewOutlet addInfiniteScrollingWithActionHandler:^{
        [self findRepBoxRepsWithOffset:[NSString stringWithFormat:@"%i", [repBoxReps count]] andLimit:[NSString stringWithFormat:@"8"]];
    }];
    

}

-(void) getUser{
    
    if (repname || facebookID) {
        currentUserProfile = NO;
    }else{
        currentUserProfile = YES;
    }
    [self showLoadingOverlay];
    RadiusRequest *userQueryRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys: self._id, @"_id", nil] apiMethod:@"user/get" httpMethod:@"POST"];
    
    [userQueryRequest startWithCompletionHandler:^(id response, RadiusError *error){
        
        [self dismissLoadingOverlay];
        NSLog(@"%@", response);
        
        if([[response objectForKey:@"success"]integerValue] == 1){
            
            [self setupUserProfileWithDictionary:[response objectForKey:@"data"]];
            
            self.repname = [[response objectForKey:@"data"]objectForKey:@"repname"];
            [repboxTableViewOutlet reloadData];
            userRequestCompleted = YES;
        }
        
    }];

    
}

-(void) setupUserProfileWithDictionary: (NSDictionary *)userDictionary{
    
    ProfileHeaderView *tableHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"ProfileHeaderView" owner:self options:nil] objectAtIndex:0];
    tableHeaderView.frame = CGRectMake(0, 0, 320, 320);
    [tableHeaderView initializeProfileHeader];
    tableHeaderView._id = self._id;
    
    if (userDictionary !=nil) {
        
        
        if ([userDictionary count]>0) {
            
//            NSString *senderPictureString = [[[[NSString stringWithFormat:@"%@", [userDictionary objectForKey:@"pic"]]componentsSeparatedByString:@"?"]objectAtIndex:0]stringByAppendingFormat:@"?width=260&height=400"];
            
            NSString *senderPictureString = [NSString stringWithFormat:@"%@", [userDictionary objectForKey:@"pic"]];
            NSURL *myURL = [NSURL URLWithString:senderPictureString];
            AsyncImageView *newAsync = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 200) imageURL:myURL cache:nil loadImmediately:YES];
            newAsync.tag = ASYC_IMAGE_TAG;
            newAsync.contentMode = UIViewContentModeScaleAspectFit;
            [tableHeaderView addSubview:newAsync];
            [tableHeaderView sendSubviewToBack:[tableHeaderView viewWithTag:ASYC_IMAGE_TAG]];
            
            //Repname label
            if ([userDictionary objectForKey:@"repname"]) {
                self.repname = [NSString stringWithFormat:@"%@", [userDictionary objectForKey:@"repname"]];
                
                tableHeaderView.repnameLabelOutlet.text = [NSString stringWithFormat:@"%@",[userDictionary objectForKey:@"repname"]];

            }else{
                
                tableHeaderView.repnameLabelOutlet.text = [NSString stringWithFormat:@"++%@",[userDictionary objectForKey:@"_id"]];

                
            }
            //Score Label
            if ([userDictionary objectForKey:@"score"]) {
                NSString *myScore = [NSString stringWithFormat:@"%@",[userDictionary objectForKey:@"score"]] ;
                if ([myScore integerValue] == 0) {
                    tableHeaderView.repscoreLabelOutlet.text = [NSString stringWithFormat:@"{rep_score: ++%@,", myScore];
                }else{
                    tableHeaderView.repscoreLabelOutlet.text = [NSString stringWithFormat:@"{rep_score: ++%i,", [myScore integerValue]];
                    
                }
                
            }else{
                tableHeaderView.repscoreLabelOutlet.text = [NSString stringWithFormat:@"{rep_score: ++0,"];
            }
            
            //Date joined
            tableHeaderView.dateJoinedLabelOutlet.text =[NSString stringWithFormat:@"date_joined: %@}",[userDictionary objectForKey:@"ts"]];
            
            
            
        }
        
    }

    [self.repboxTableViewOutlet setTableHeaderView:tableHeaderView];
}


-(void) refreshRepBox {
    [repBoxReps removeAllObjects];
    [self findRepBoxRepsWithOffset:[NSString stringWithFormat:@"0"] andLimit:[NSString stringWithFormat:@"8"]];
    
}

-(void) findRepBoxRepsWithOffset: (NSString *)offset andLimit: (NSString *)limit {
    RadiusRequest *outboxRequest;
    
    if (_id == nil) {
        outboxRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys: limit, @"limit", offset, @"offset", nil] apiMethod:@"rep/box/get" httpMethod:@"POST"];
    }else{
        outboxRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys: _id, @"_id", limit, @"limit", offset, @"offset", nil] apiMethod:@"rep/box/get" httpMethod:@"POST"];
    }
    

    
    [outboxRequest startWithCompletionHandler:^(id response, RadiusError *error){
        
        NSLog(@"%@", response);
        [self dismissLoadingOverlay];
        selfRequestCompleted = YES;
        
        if([[response objectForKey:@"success"]integerValue] == 1){
            if([[response objectForKey:@"data"]count]>0){
                [repBoxReps addObjectsFromArray:[response objectForKey:@"data"]];
                [repboxTableViewOutlet reloadData];
                [self.repboxTableViewOutlet.pullToRefreshView stopAnimating];
                [self.repboxTableViewOutlet.infiniteScrollingView stopAnimating];
            }else if([repBoxReps count]>0){
                
                UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"No more results! :(" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                [successAlert show];
                [self.repboxTableViewOutlet.pullToRefreshView stopAnimating];
                [self.repboxTableViewOutlet.infiniteScrollingView stopAnimating];
                
                
            }else{
                [self.repboxTableViewOutlet.pullToRefreshView stopAnimating];
                [self.repboxTableViewOutlet.infiniteScrollingView stopAnimating];
                [repboxTableViewOutlet reloadData];

                
            }
        }
        
    }];

}

-(void) setupTapToRepBox{
    
//    NSLog(@"%@", repboxTableViewOutlet.tableHeaderView.frame);
//    
//    UIButton *tapToRepBox = [[UIButton alloc] initWithFrame:repboxTableViewOutlet.tableHeaderView.frame];
//    [tapToRepBox addTarget:self action:@selector(goToRepBox:) forControlEvents:UIControlEventTouchUpInside];
//    [self.repboxTableViewOutlet.tableHeaderView addSubview:tapToRepBox];
    
    
}

-(void) goToRepBox: (id)sender {
    
    ProfileViewController *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                          instantiateViewControllerWithIdentifier:@"profileID"];
    
    NSString *theID = _id;
    [demoController initializeWithID:theID];
    demoController.repname = self.repname;
    [self.navigationController pushViewController:demoController animated:YES];
    
}

- (void) handleLongPress: (UILongPressGestureRecognizer *) sender{
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"hello world");
        
        CGPoint longPressLocation = [sender locationInView:self.repboxTableViewOutlet];
        NSIndexPath *myPath = [self.repboxTableViewOutlet indexPathForRowAtPoint:longPressLocation];
        indexPathForQuote = myPath;
        NSLog(@"%i", indexPathForQuote.row);
        NSString *myID = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"_id"]];

        if([_id isEqualToString:myID] || _id == nil){
            
            UIActionSheet *repBoxActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:REMOVE_QUOTE otherButtonTitles:VIEW_CONVERSATION, nil];
            repBoxActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            repBoxActionSheet.tag = 100;
            [repBoxActionSheet showInView:self.view];
            
        }else{
            UIActionSheet *repBoxActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:ADD_QUOTE, VIEW_CONVERSATION, nil];
            repBoxActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            repBoxActionSheet.tag = 200;
            [repBoxActionSheet showInView:self.view];
        }
        

        
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
        
        if (actionSheet.tag == 100) {
            if ([buttonTitle isEqualToString:VIEW_CONVERSATION]) {
                [self viewConversation];
            }else if ([buttonTitle isEqualToString:REMOVE_QUOTE] ){
                [self removeQuote];

            }
        }else if (actionSheet.tag == 200){
            if ([buttonTitle isEqualToString:VIEW_CONVERSATION]) {
                [self viewConversation];
            }else if ([buttonTitle isEqualToString:ADD_QUOTE] ){
                [self addQuote];
                
            }
        }
    
}

-(void) viewConversation {
    
    NSDictionary *rowDictionary = [NSDictionary dictionaryWithDictionary:[repBoxReps objectAtIndex:indexPathForQuote.row]];
    
    ConvoViewController *convoVC = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                    instantiateViewControllerWithIdentifier:@"convoID"];
    NSString *refString = [NSString stringWithFormat:@"%@", [[rowDictionary objectForKey:@"repx"] objectForKey:@"ref"]];
    [convoVC initializeConvoViewWithRepRef:refString];
    [repboxTableViewOutlet deselectRowAtIndexPath:indexPathForQuote animated:YES];
//    NSArray *controllers = [NSArray arrayWithObject:convoVC];
//    [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
//    [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
    [self.navigationController pushViewController:convoVC animated:YES];

}

-(void) removeQuote{
    
    [self showLoadingOverlay];
    
    RadiusRequest *quoteRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@", [[[repBoxReps objectAtIndex:indexPathForQuote.row] objectForKey:@"repx"] objectForKey:@"_id"]], @"_id",nil] apiMethod:@"rep/box/remove" httpMethod:@"POST"];
    
    [quoteRequest startWithCompletionHandler:^(id response, RadiusError *error){
        
        [self dismissLoadingOverlay];
        NSLog(@"%@", response);
        
        if ([[response objectForKey:@"success"]integerValue]==1) {
            
                        if ([[response objectForKey:@"data"] objectForKey:@"_id"]) {
                            UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Removed!" message:[NSString stringWithFormat:@"noob"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                            successAlert.tag = ALERT_VIEW_TAG;
                            [successAlert show];
            
                            [self refreshRepBox];
                            
                        }
            
            
        }
    }];
    
}

-(void) addQuote{
    
    [self showLoadingOverlay];
    
    RadiusRequest *quoteRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@", [[[repBoxReps objectAtIndex:indexPathForQuote.row] objectForKey:@"repx"] objectForKey:@"_id"]], @"_id",nil] apiMethod:@"rep/box/add" httpMethod:@"POST"];
    
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

#pragma mark Table Cell Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if (tableView == repboxTableViewOutlet) {
        
        if ([repBoxReps count]>0) {
            return [repBoxReps count];
        }else if (selfRequestCompleted){
            return 1;
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

    
    
    
    // Configure the cell...
    
    
    if (tableView == repboxTableViewOutlet) {
        if ([repBoxReps count]>0) {
            
            if (indexPath.row == [repBoxReps count]){
                
                cell.textLabel.text = @"...";
                cell.textLabel.numberOfLines = 10;
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
            
            NSString *senderString = [NSString stringWithFormat:@"%@",[[[repBoxReps objectAtIndex:indexPath.row]objectForKey:@"repx"] objectForKey:@"sender"]];
            NSDictionary *myUserDic = [[[[repBoxReps objectAtIndex:indexPath.row]objectForKey:@"repx"]objectForKey:@"parties"]objectForKey:senderString];
            
            
            NSString *repMessage = [NSString stringWithFormat:@"%@",[[[repBoxReps objectAtIndex:indexPath.row]objectForKey:@"repx"] objectForKey:@"message"]];
            NSString *repSender = [myUserDic objectForKey:@"name"];
            
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
            NSString *myDateString = [[[repBoxReps objectAtIndex:indexPath.row]objectForKey:@"repx"] objectForKey:@"ts"];
            myDateString = [[myDateString componentsSeparatedByString:@"."]objectAtIndex:0];
            NSDate *postDate = [dateFormatter dateFromString:myDateString];
            NSString *dateString = [dateHelper timeIntervalWithStartDate:postDate withEndDate:[NSDate date]];
            
            
            
            //Configuration of Text Labels
            
            CGSize maximumLabelSize = CGSizeMake(300,9999);
            
            mailboxCell.repnameLabelOutlet.text = repSender;
            mailboxCell.reptimeLabelOutlet.text = dateString;
            mailboxCell.repfactLabelOutlet.text = repMessage;
            
            CGSize repFactExpectedLabelSize = [repMessage sizeWithFont:mailboxCell.repfactLabelOutlet.font
                                                     constrainedToSize:maximumLabelSize
                                                         lineBreakMode:mailboxCell.repfactLabelOutlet.lineBreakMode];
            mailboxCell.repfactLabelOutlet.frame = CGRectMake(mailboxCell.repfactLabelOutlet.frame.origin.x, mailboxCell.repfactLabelOutlet.frame.origin.y, repFactExpectedLabelSize.width, repFactExpectedLabelSize.height);
            
            
            
            
            //Configuration of Picture
            mailboxCell.pictureString = [myUserDic objectForKey:@"pic"];
            NSURL *myURL = [NSURL URLWithString:mailboxCell.pictureString];
            AsyncImageView *asyncImageViewInstance = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, mailboxCell.frame.size.width, mailboxCell.frame.size.height) imageURL:myURL cache:imageCacheDictionary loadImmediately:YES];
            asyncImageViewInstance.tag = ASYC_IMAGE_TAG;
            asyncImageViewInstance.layer.masksToBounds = YES;
            [mailboxCell addSubview:asyncImageViewInstance];
            [mailboxCell sendSubviewToBack:asyncImageViewInstance];
            //            mailboxCell.backgroundView = asyncImageViewInstance;
            mailboxCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
            [mailboxCell addGestureRecognizer:longPress];
            longPress.delegate = mailboxCell;
            
            if ([[[repBoxReps objectAtIndex:indexPath.row]objectForKey:@"repx"] objectForKey:@"pic_id"]) {
                
                mailboxCell.cameraButtonOutlet.hidden = NO;
                mailboxCell.pic_id = [[[repBoxReps objectAtIndex:indexPath.row]objectForKey:@"repx"] objectForKey:@"pic_id"];
            }
            return mailboxCell;

            
            
            
        }
        
        if (selfRequestCompleted && userRequestCompleted) {
            if (self.repname) {
                cell.textLabel.text = @"Quoted reps show up here!";
                cell.detailTextLabel.text = nil;
                cell.textLabel.numberOfLines = 3;
                cell.textLabel.font = [UIFont fontWithName:@"Courier" size:15.0];
                cell.textLabel.highlightedTextColor = [UIColor greenColor];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                UIView *backView = [[UIView alloc] initWithFrame:cell.frame];
                backView.backgroundColor = [UIColor blackColor];
                cell.selectedBackgroundView = backView;

                cell.userInteractionEnabled = NO;
                
                return cell;
            }else{
                cell.textLabel.text = @"This person still doesn't have Rep yet :(";
                cell.detailTextLabel.text = nil;
                cell.textLabel.numberOfLines = 3;
                cell.textLabel.font = [UIFont fontWithName:@"Courier" size:15.0];
                cell.textLabel.highlightedTextColor = [UIColor greenColor];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                UIView *backView = [[UIView alloc] initWithFrame:cell.frame];
                backView.backgroundColor = [UIColor blackColor];
                cell.selectedBackgroundView = backView;
                
                cell.userInteractionEnabled = NO;
                
                return cell;
                
            }

        }
        
        
    }
    
    return cell;
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == repboxTableViewOutlet) {
        
        if ([repBoxReps count]> 0) {
            
            if (indexPath.row == [repBoxReps count]) {
                [self findRepBoxRepsWithOffset:[NSString stringWithFormat:@"%i", [repBoxReps count]] andLimit:[NSString stringWithFormat:@"8"]];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                return;
            }else{
                
//                NSDictionary *rowDictionary = [NSDictionary dictionaryWithDictionary:[repBoxReps objectAtIndex:indexPath.row]];
//                
//                ConvoViewController *convoVC = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
//                                                instantiateViewControllerWithIdentifier:@"convoID"];
//                NSString *refString = [NSString stringWithFormat:@"%@", [[rowDictionary objectForKey:@"repx"] objectForKey:@"ref"]];
//                [convoVC initializeConvoViewWithRepRef:refString];
//                [tableView deselectRowAtIndexPath:indexPath animated:YES];
//                [self.navigationController pushViewController:convoVC animated:YES];
                
                
            }
        }   
        
    }
    
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (tableView == repboxTableViewOutlet) {
        
        if ([repBoxReps count]>0) {
            if (indexPath.row == [repBoxReps count]) {
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
    
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        
        if ([repBoxReps count] > 1 && scrolledAlready == NO) {

//            [repboxTableViewOutlet scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            scrolledAlready = YES;
            
        }
        


    }
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
    [self setRepboxTableViewOutlet:nil];
    [super viewDidUnload];
}
@end
