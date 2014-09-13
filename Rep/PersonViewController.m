//
//  PersonViewController.m
//  Rep
//
//  Created by Hudson on 4/24/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "PersonViewController.h"
#import "ProfileViewController.h"


@interface PersonViewController ()

@end

@implementation PersonViewController
@synthesize repname, facebookID;
@synthesize notCurrentUserProfile,relationshipArray, dataArrayCount, userDictionary;


static const CGFloat ASYC_IMAGE_TAG = 100;
static const CGFloat ALERT_VIEW_TAG = 200;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if(notCurrentUserProfile){
        
        
        
        [self findUserRelationship];
        
        UITapGestureRecognizer *tapToProfileRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToProfile:)];
        [self.view addGestureRecognizer:tapToProfileRecognizer];
        
        //Repname label
        if (self.repname) {
            self.repnameLabelOutlet.text = self.repname;
            
        }
        
        self.truescoreLabelOutlet.text = [NSString stringWithFormat:@"%@", [userDictionary objectForKey:@"score"]];
        self.datejoinedLabelOutlet.text =[NSString stringWithFormat:@"%@}",[userDictionary objectForKey:@"ts"]];
        
    }else {
        
        [self findUserRelationship];

        
        //Repname label
        if (self.repname) {
            self.repnameLabelOutlet.text = self.repname;
            
        }
        
        self.truescoreLabelOutlet.text = [NSString stringWithFormat:@"%@", [userDictionary objectForKey:@"score"]];
        self.datejoinedLabelOutlet.text =[NSString stringWithFormat:@"%@}",[userDictionary objectForKey:@"ts"]];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Be patient" message:@"We're planning some big changes to your profile, just sit tight!" delegate:nil cancelButtonTitle:@"Fine, fine" otherButtonTitles: nil];
        [alert show];
        
    }
    
    
	// Do any additional setup after loading the view.
}

-(void) initializeWithRepname: (NSString *)myRepname{
    
    self.repname = [NSString stringWithFormat:@"++%@", myRepname];
    
}

-(void)initializeWithFacebookID:(NSString *)fb_id{
    
    self.facebookID = fb_id;
    
}

-(void)initializeWithRelationshipArray:(NSArray *)myArray{
    
    self.relationshipArray = myArray;
    
}

-(void)tapToProfile: (UITapGestureRecognizer *)sender{
    
//    ProfileViewController *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
//                                             instantiateViewControllerWithIdentifier:@"profileID"];
//    
//        
//        demoController.facebookID = self.facebookID;
//        demoController.notCurrentUserProfile = YES;
//        [demoController initializeWithFacebookID:self.facebookID];
//        
//        [self.navigationController pushViewController:demoController animated:YES];
    
    
}

-(void)findUserRelationship{
    
    RadiusRequest *testRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:self.repname, @"repname", nil] apiMethod:@"relationship" httpMethod:@"POST"];
    [testRequest startWithCompletionHandler:^(id response, RadiusError *error){
        
        if([[response objectForKey:@"data"] count] > 1){
            
            if (![[[[[response objectForKey:@"data"] objectAtIndex:0] objectForKey:@"sender"] objectForKey:@"repname"] isEqualToString:self.repname]) {
                
                NSArray *reversedArray = [[[response objectForKey:@"data"] reverseObjectEnumerator] allObjects];
                self.relationshipArray = reversedArray;
                
            }else{
                
                
                self.relationshipArray = [response objectForKey:@"data"];
                
            }

            
        }else{
            
            
            self.relationshipArray = [response objectForKey:@"data"];
            
        }
        
        [self setupUserPerson];
        
        
        
    }];
    
}

-(void) setupUserPerson{
    if (relationshipArray !=nil) {
        
        
        if ([relationshipArray count]>1) {
//            NSURL *myURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [[[relationshipArray objectAtIndex:1] objectForKey:@"recipient"] objectForKey:@"pic"]]];
            

            
            NSURL *myNewURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=1000&height=1000", self.facebookID]];
            AsyncImageView *newAsync = [[AsyncImageView alloc] initWithFrame:self.profilePictureImageView.frame imageURL:myNewURL cache:nil loadImmediately:YES];
            newAsync.tag = ASYC_IMAGE_TAG;
            [self.view addSubview:newAsync];
            [self.view sendSubviewToBack:[self.view viewWithTag:ASYC_IMAGE_TAG]];
            
 
            //RepX
            
            int repx = [[[relationshipArray objectAtIndex:0] objectForKey:@"rep_c"]integerValue] + [[[relationshipArray objectAtIndex:1] objectForKey:@"rep_c"]integerValue];

            self.repXLabel.text = [NSString stringWithFormat:@"%dx,",repx];
            self.repRecievedLabelOutlet.text = [NSString stringWithFormat:@"++%@,",[[relationshipArray objectAtIndex:0] objectForKey:@"score"]];
            self.repSentLabelOutlet.text = [NSString stringWithFormat:@"++%@,",[[relationshipArray objectAtIndex:1] objectForKey:@"score"]];

            
        }else if ([relationshipArray count] == 1) {
         
            if ([[[[relationshipArray objectAtIndex:0] objectForKey:@"sender"] objectForKey:@"repname"] isEqualToString:self.repname]) {

                NSURL *myNewURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=1000&height=1000", self.facebookID]];
                AsyncImageView *newAsync = [[AsyncImageView alloc] initWithFrame:self.profilePictureImageView.frame imageURL:myNewURL cache:nil loadImmediately:YES];
                newAsync.tag = ASYC_IMAGE_TAG;
                [self.view addSubview:newAsync];
                [self.view sendSubviewToBack:[self.view viewWithTag:ASYC_IMAGE_TAG]];
                
                

                //RepX
                
                self.repXLabel.text = [NSString stringWithFormat:@"%@x,",[[relationshipArray objectAtIndex:0] objectForKey:@"rep_c"]];
                self.repRecievedLabelOutlet.text = [NSString stringWithFormat:@"++%@,",[[relationshipArray objectAtIndex:0] objectForKey:@"score"]];
                self.repSentLabelOutlet.text = [NSString stringWithFormat:@"++0,"];

            }else if ([[[[relationshipArray objectAtIndex:0] objectForKey:@"recipient"] objectForKey:@"repname"] isEqualToString:self.repname]){
                

                NSURL *myNewURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=1000&height=1000", self.facebookID]];
                AsyncImageView *newAsync = [[AsyncImageView alloc] initWithFrame:self.profilePictureImageView.frame imageURL:myNewURL cache:nil loadImmediately:YES];
                newAsync.tag = ASYC_IMAGE_TAG;
                [self.view addSubview:newAsync];
                [self.view sendSubviewToBack:[self.view viewWithTag:ASYC_IMAGE_TAG]];
                

                //RepX
                
                self.repXLabel.text = [NSString stringWithFormat:@"%@x,",[[relationshipArray objectAtIndex:0] objectForKey:@"rep_c"]];
                self.repRecievedLabelOutlet.text = [NSString stringWithFormat:@"++0,"];
                self.repSentLabelOutlet.text = [NSString stringWithFormat:@"++%@,",[[relationshipArray objectAtIndex:0] objectForKey:@"score"]];
     

            }
        }else if ([relationshipArray count] == 0){
            
            NSURL *myNewURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=1000&height=1000", self.facebookID]];
            AsyncImageView *newAsync = [[AsyncImageView alloc] initWithFrame:self.profilePictureImageView.frame imageURL:myNewURL cache:nil loadImmediately:YES];
            newAsync.tag = ASYC_IMAGE_TAG;
            [self.view addSubview:newAsync];
            [self.view sendSubviewToBack:[self.view viewWithTag:ASYC_IMAGE_TAG]];
            
            
            //RepX
            
            self.repXLabel.text = [NSString stringWithFormat:@"0x,"];
            self.repRecievedLabelOutlet.text = [NSString stringWithFormat:@"++0,"];
            self.repSentLabelOutlet.text = [NSString stringWithFormat:@"++0,"];
        }

        
    }
    //Change Button depending on who the profile is
    
}



#pragma mark Apple Methods

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidUnload {
    [self setRepnameLabelOutlet:nil];
    [self setTruescoreLabelOutlet:nil];
    [self setRepRecievedLabelOutlet:nil];
    [self setRepSentLabelOutlet:nil];
    [self setDatejoinedLabelOutlet:nil];
    [self setRepXLabel:nil];
    [self setProfilePictureImageView:nil];
    [super viewDidUnload];
}
@end


//RadiusRequest *testRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:finalRepNameString, @"repname", nil] apiMethod:@"relationship" httpMethod:@"POST"];
//[testRequest startWithCompletionHandler:^(id response, RadiusError *error){
//    
//    
//    
//    NSLog(@"%@", response);
//    
//    if([[response objectForKey:@"data"] count] > 1){
//
//        
//        if (![[[[[response objectForKey:@"data"] objectAtIndex:0] objectForKey:@"sender"] objectForKey:@"repname"] isEqualToString:finalRepNameString]) {
//            NSArray *reversedArray = [[[response objectForKey:@"data"] reverseObjectEnumerator] allObjects];
//            PersonViewController *newViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
//                                                       instantiateViewControllerWithIdentifier:@"personID"];;
//            [newViewController initializeWithRelationshipArray:reversedArray];
//            [newViewController initializeWithFacebookID:[[[reversedArray objectAtIndex:0] objectForKey:@"sender"] objectForKey:@"fb_id"]];
//            [newViewController initializeWithRepname:[[[reversedArray objectAtIndex:0] objectForKey:@"sender"] objectForKey:@"repname"]];
//            [self.navigationController pushViewController:newViewController animated:YES];
//        }else{
//            
//            PersonViewController *newViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
//                                                       instantiateViewControllerWithIdentifier:@"personID"];;
//            [newViewController initializeWithRelationshipArray:[response objectForKey:@"data"]];
//            [newViewController initializeWithFacebookID:[[[[response objectForKey:@"data"] objectAtIndex:0] objectForKey:@"sender"] objectForKey:@"fb_id"]];
//            [newViewController initializeWithRepname:[[[[response objectForKey:@"data"] objectAtIndex:0] objectForKey:@"sender"] objectForKey:@"repname"]];
//            [self.navigationController pushViewController:newViewController animated:YES];
//        }
//        
//        
//    }else if ([[response objectForKey:@"data"] count] == 1){
//        
//        if ([[[[[response objectForKey:@"data"] objectAtIndex:0] objectForKey:@"sender"] objectForKey:@"repname"] isEqualToString:finalRepNameString]) {
//            PersonViewController *newViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
//                                                       instantiateViewControllerWithIdentifier:@"personID"];;
//            [newViewController initializeWithRelationshipArray:[response objectForKey:@"data"]];
//            [newViewController initializeWithFacebookID:[[[[response objectForKey:@"data"] objectAtIndex:0] objectForKey:@"sender"] objectForKey:@"fb_id"]];
//            [newViewController initializeWithRepname:[[[[response objectForKey:@"data"] objectAtIndex:0] objectForKey:@"sender"] objectForKey:@"repname"]];
//            [self.navigationController pushViewController:newViewController animated:YES];
//            
//        }else if ([[[[[response objectForKey:@"data"] objectAtIndex:0] objectForKey:@"recipient"] objectForKey:@"repname"] isEqualToString:finalRepNameString]){
//            
//            PersonViewController *newViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
//                                                       instantiateViewControllerWithIdentifier:@"personID"];;
//            [newViewController initializeWithRelationshipArray:[response objectForKey:@"data"]];
//            [newViewController initializeWithFacebookID:[[[[response objectForKey:@"data"] objectAtIndex:0] objectForKey:@"recipient"] objectForKey:@"fb_id"]];
//            [newViewController initializeWithRepname:[[[[response objectForKey:@"data"] objectAtIndex:0] objectForKey:@"recipient"] objectForKey:@"repname"]];
//            [self.navigationController pushViewController:newViewController animated:YES];
//        }
//        
//        
//    }
//    
//}];

