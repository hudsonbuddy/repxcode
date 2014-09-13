//
//  SlidingConsoleView.m
//  Rep
//
//  Created by Hudson on 5/6/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "SlidingConsoleView.h"
#import "PersonViewController.h"

@implementation SlidingConsoleView{
    
    NSUserDefaults *myDefaults;
    int consoleIndex;
    NSMutableArray *consoleTextArray;
    RepViewController *myViewController;

    
}

@synthesize consoleTextView, animatedDistance;
static NSString * const REP_MESSAGE_PLACEHOLDER = @"hello  world";
static NSString * const CHECKOUT_REGEX = @"^checkout\\(\\+\\+[a-z0-9]+\\)$";


static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

static const CGFloat ASYC_IMAGE_TAG = 100;
static const CGFloat ALERT_VIEW_TAG = 200;

-(void) initializeConsoleView{
    
    myDefaults = [NSUserDefaults standardUserDefaults];
    if ([myDefaults objectForKey:@"consoleTextArray"] == nil) {
        consoleTextArray = [[NSMutableArray alloc] init];
    }else{
        consoleTextArray = [NSMutableArray arrayWithArray:[myDefaults arrayForKey:@"consoleTextArray"]];
    }
    
    consoleIndex = [consoleTextArray count];
    
    consoleTextView.delegate = self;
    [consoleTextView setReturnKeyType:UIReturnKeyDone];
    
    [consoleTextView setText:REP_MESSAGE_PLACEHOLDER];
    [self setupSwipeToSeeText];
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bck_GraphTexture_75opacity"]];
    myViewController = (RepViewController *)[self firstAvailableUIViewController];

}

-(void) sendToConsoleWithText: (NSString *) consoleText{
    [myDefaults setObject:consoleTextArray forKey:@"consoleTextArray"];
    
    NSError *myError = NULL;
    
    NSRegularExpression *myRegex = [NSRegularExpression regularExpressionWithPattern:CHECKOUT_REGEX options:nil error:&myError];
    
    NSUInteger numberOfMatches = [myRegex numberOfMatchesInString:consoleText options:0 range:NSMakeRange(0, [consoleText length])];
    
    NSLog(@"%lu", (unsigned long)numberOfMatches);
    
    if (numberOfMatches){
        
//        NSArray *tempArrayForPlusPlus = [[NSArray alloc] initWithArray:[consoleText componentsSeparatedByString:@"++"]];
//        
//        if ([tempArrayForPlusPlus count]>1) {
//            
//            
//            NSArray *finalRepNameArray = [[NSArray alloc] initWithArray:[[tempArrayForPlusPlus objectAtIndex:1] componentsSeparatedByString:@")"]];
//            NSLog(@"%@", [finalRepNameArray objectAtIndex:0]);
//            
//            NSString *finalRepNameString = [NSString stringWithFormat:@"++%@", [finalRepNameArray objectAtIndex:0]];
//            
//            
//            RadiusRequest *userQueryRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys: finalRepNameString, @"repname", nil] apiMethod:@"user/get" httpMethod:@"POST"];
//            
//            [userQueryRequest startWithCompletionHandler:^(id response, RadiusError *error){
//                
//                NSLog(@"%@", response);
//                
//                NSString *plusplusresponseRepname = [NSString stringWithFormat:@"++%@", [[response objectForKey:@"data"]objectForKey:@"repname"]];
////                NSString *responseRepname = [NSString stringWithFormat:@"%@", [[response objectForKey:@"data"]objectForKey:@"repname"]];
//                
//                
//                if([plusplusresponseRepname isEqualToString:finalRepNameString]){
//                    
//                    PersonViewController *newViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
//                                                               instantiateViewControllerWithIdentifier:@"personID"];
//                    [newViewController initializeWithFacebookID:[[response objectForKey:@"data"] objectForKey:@"fb_id"]];
//                    [newViewController initializeWithRepname:[[response objectForKey:@"data"] objectForKey:@"repname"]];
//                    [newViewController setUserDictionary:[response objectForKey:@"data"]];
//                    [newViewController setNotCurrentUserProfile:YES];
//                    NSArray *controllers = [NSArray arrayWithObject:newViewController];
//                    [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
//                    [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
//                }
//                
//            }];
//            
//        }
        
    }else{
        
        if ([consoleText isEqualToString:@"cd reps"]) {
            
            [self.consoleTextView setText:@""];
            
            UIViewController *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                                instantiateViewControllerWithIdentifier:@"inboxID"];
            demoController.title = [NSString stringWithFormat:@"/messages"];
            
            NSArray *controllers = [NSArray arrayWithObject:demoController];
            [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
            [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
            return;
        }else if ([consoleText isEqualToString:@"cd feed"]) {
            
            [self.consoleTextView setText:@""];
            
            UIViewController *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                                instantiateViewControllerWithIdentifier:@"feedID"];
            demoController.title = [NSString stringWithFormat:@"/feed"];
            
            NSArray *controllers = [NSArray arrayWithObject:demoController];
            [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
            [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
            return;
        }else if ([consoleText isEqualToString:@"cd search"]) {
            
            [self.consoleTextView setText:@""];
            
            UIViewController *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                                instantiateViewControllerWithIdentifier:@"searchID"];
            demoController.title = [NSString stringWithFormat:@"/search"];
            
            NSArray *controllers = [NSArray arrayWithObject:demoController];
            [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
            [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
            return;
        }else if ([consoleText isEqualToString:@"cd help"]) {
            
            [self.consoleTextView setText:@""];
            
            UIViewController *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                                instantiateViewControllerWithIdentifier:@"settingsID"];
            demoController.title = [NSString stringWithFormat:@"/help"];
            
            NSArray *controllers = [NSArray arrayWithObject:demoController];
            [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
            [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
            return;
        }else if ([consoleText isEqualToString:@"cd self"]) {
            
            [self.consoleTextView setText:@""];
            
            UIViewController *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                                instantiateViewControllerWithIdentifier:@"selfID"];
            demoController.title = [NSString stringWithFormat:@"/self"];
            
            NSArray *controllers = [NSArray arrayWithObject:demoController];
            [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
            [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
            return;
        }else{
            
            [myViewController showLoadingOverlay];
            
            RadiusRequest *consoleRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys: self.consoleTextView.text, @"message", nil] apiMethod:@"console" httpMethod:@"POST"];
            
            [consoleRequest startWithCompletionHandler:^(id response, RadiusError *error){
                [myViewController dismissLoadingOverlay];
                
                
                if (![[[response objectForKey:@"data"] objectForKey:@"message"]isKindOfClass:[NSNull class]]) {
                    self.consoleTextView.text = [[response objectForKey:@"data"] objectForKey:@"message"];
                    
                }
                
                
                
                
            }];
            
        }
        
    }
    

    
}

-(void) setupSwipeToSeeText{
    
    UISwipeGestureRecognizer *swipeUpToChangeText = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(showPreviousConsoleText:)];
    swipeUpToChangeText.delegate = self;
    swipeUpToChangeText.direction = UISwipeGestureRecognizerDirectionUp;
    
    [self.consoleTextView addGestureRecognizer:swipeUpToChangeText];
    
    UISwipeGestureRecognizer *swipeDownToChangeText = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(showNextConsoleText:)];
    swipeDownToChangeText.delegate = self;
    swipeDownToChangeText.direction = UISwipeGestureRecognizerDirectionDown;
    
    [self.consoleTextView addGestureRecognizer:swipeDownToChangeText];
    
}

-(void) showPreviousConsoleText: (UISwipeGestureRecognizer *) sender{
    if (consoleIndex > 0) {
        consoleIndex--;
        if (consoleIndex >=0) {
            [consoleTextView setText:[consoleTextArray objectAtIndex:consoleIndex]];
            return;
        }
    }else if (consoleIndex == 0){
        consoleIndex--;
        
        [consoleTextView setText:@""];
        
        
    }
    
    
    
    
    
}

-(void) showNextConsoleText: (UISwipeGestureRecognizer *) sender{
    
    int arrayIndex = [consoleTextArray count] -1;
    
    if (consoleIndex < arrayIndex) {
        consoleIndex++;
        if (consoleIndex <= [consoleTextArray count]-1) {
            
            [consoleTextView setText:[consoleTextArray objectAtIndex:consoleIndex]];
            return;
        }
    }else if (consoleIndex == [consoleTextArray count] -1){
        consoleIndex++;
        
        [consoleTextView setText:@""];
        
    }

    
}

#pragma mark Delegate Methods

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    if (textView == consoleTextView) {
        
        if ([textView.text length] > 50 || [textView.text isEqualToString:REP_MESSAGE_PLACEHOLDER]) {
            [textView setText:@""];

        }
    
    }

}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    
    if (textView == consoleTextView) {
        
        if ([text isEqualToString:@"\n"]) {
            if ([textView.text length]>0) {
                
                [consoleTextArray addObject:textView.text];
                consoleIndex = [consoleTextArray count];
                
            }
            [self sendToConsoleWithText:textView.text];

            [textView endEditing:YES];
            return NO;
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
