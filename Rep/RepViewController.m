//
//  RepViewController.m
//  Rep
//
//  Created by Hud on 2/2/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "RepViewController.h"
#import "MFSideMenu.h"

@interface RepViewController ()  {
    
    UIView *loadingOverlay;

}

@property (strong,nonatomic) void(^onAppear)(void);


@end

@implementation RepViewController
@synthesize hasAppeared = _hasAppeared;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSideMenuBarButtonItem];
    [self setupBarButtonItem];
    [self tapToDismissNavBar];
    [MFSlidingView slideOut];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWakeUpFromBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bck_GraphTexture_75opacity"]];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void) setupBarButtonItem {
    
//    UIBarButtonItem *repButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(displaySlidingRepView)];
    

    
    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    myButton.frame= CGRectMake(0, 0, 44, 30);
    [myButton setTitle:@"++" forState:UIControlStateNormal];
    [myButton.titleLabel setFont:[UIFont fontWithName:@"Courier" size:18]];
    [myButton setBackgroundColor:[UIColor whiteColor]];
    [myButton.layer setCornerRadius:3];
    [myButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [myButton addTarget:self action:@selector(displaySlidingRepView:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *notificationButtonItem = [[UIBarButtonItem alloc] initWithCustomView:myButton];
    self.navigationItem.rightBarButtonItem = notificationButtonItem;
    

    
}



-(void) displaySlidingRepView:(id) sender {
    
    [self.view endEditing:YES];
    
//    SlidingConsoleView *slidingConsoleViewInstance = [[[NSBundle mainBundle]loadNibNamed:@"SlidingConsoleView" owner:self options:nil]objectAtIndex:0];
//    [slidingConsoleViewInstance initializeConsoleView];
//    SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
//    void (^cancelOrDoneBlock)() = ^{
//        // we must manually slide out the view out if we specify this block
//        [MFSlidingView slideOut];
//    };
//    [MFSlidingView slideView:slidingConsoleViewInstance intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
    
    SlidingRepView *slidingRepViewInstance = [[[NSBundle mainBundle]loadNibNamed:@"SlidingRepView" owner:self options:nil]objectAtIndex:0];
    [slidingRepViewInstance initializeSlidingRepView];
    SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
    void (^cancelOrDoneBlock)() = ^{
        // we must manually slide out the view out if we specify this block
        [MFSlidingView slideOut];
    };
    [MFSlidingView slideOut];
    [MFSlidingView slideView:slidingRepViewInstance intoView:self.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
    
}

-(void) displaySlidingConsoleView:(id) sender {
    
    [self.view endEditing:YES];
    
        SlidingConsoleView *slidingConsoleViewInstance = [[[NSBundle mainBundle]loadNibNamed:@"SlidingConsoleView" owner:self options:nil]objectAtIndex:0];
        [slidingConsoleViewInstance initializeConsoleView];
        SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
        void (^cancelOrDoneBlock)() = ^{
            // we must manually slide out the view out if we specify this block
            [MFSlidingView slideOut];
        };
        [MFSlidingView slideView:slidingConsoleViewInstance intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
}

-(void)tapToDismissNavBar{
    
    UITapGestureRecognizer *navBarGR = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    navBarGR.cancelsTouchesInView = NO;
//    [self.navigationController.navigationBar addGestureRecognizer:navBarGR];
    
}

-(void)handleWakeUpFromBackground{
    
    [self.view endEditing:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view will appear");

}

-(void)viewWillDisappear:(BOOL)animated {
    
    [self.view endEditing:YES];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _hasAppeared = YES;
    if(self.onAppear) {
        self.onAppear();
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self dismissLoadingOverlay];
    _hasAppeared = NO;
}

-(void)performOnAppear:(void (^)(void))block
{
    if(self.hasAppeared) {
        block();
    } else {
        self.onAppear = block;
    }
}

-(void)showLoadingOverlay
{
    if(loadingOverlay) return;
    
    loadingOverlay = [[UIView alloc] initWithFrame:self.view.bounds];
    loadingOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    UIActivityIndicatorView *myIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    myIndicator.frame = CGRectMake(loadingOverlay.center.x - 20,
                                   loadingOverlay.center.y - 20,
                                   40,
                                   40);
    [loadingOverlay addSubview:myIndicator];
    [myIndicator startAnimating];
    [self.view addSubview:loadingOverlay];
    
}

-(void)dismissLoadingOverlay
{
    if(!loadingOverlay) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [loadingOverlay removeFromSuperview];
        loadingOverlay = nil;
    });
}

-(void)refresh
{
    [self viewDidLoad];
}

-(void)showInboxView{
    
    UIViewController *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                        instantiateViewControllerWithIdentifier:@"inboxID"];
    
    NSArray *controllers = [NSArray arrayWithObject:demoController];
    [demoController setTitle:@"/messages"];
    [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
    [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
    
    
}

- (void)showLoginView
{
    
    UIViewController *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                        instantiateViewControllerWithIdentifier:@"loginID"];
    
    NSArray *controllers = [NSArray arrayWithObject:demoController];
    [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
    [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
}

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypePhotoLibrary] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    mediaUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypePhotoLibrary];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = delegate;
    
    [controller presentViewController:mediaUI animated:YES completion:nil];
    return YES;
}

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil)){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hey!" message:@"No Camera Detected..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
        return NO;

    }
    
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = delegate;
    
    [controller presentModalViewController: cameraUI animated: YES];
    return YES;
}




#pragma mark Documentation

//How to use RadiusRequest

//RadiusRequest *myRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"892", @"beacons", @"VX1p5Jlum5LgJ7PfawWBLxJ4uVR3Fj5o1Qgm21rYZNgPwCTkHC", @"token",nil] apiMethod:@"beacon_info" httpMethod:@"GET"];
//
//[myRequest startWithCompletionHandler:^(id response, RadiusError *error){
//    
//    NSLog(@"%@", response);
//    
//}failureHandler:^(NSError *error) {
//    NSLog(@"%@", error);
//}];

//How to use DateAndTimeHelper

//DateAndTimeHelper *dateHelper = [[DateAndTimeHelper alloc] init];
//NSDate *postDate = [NSDate dateWithTimeIntervalSince1970:[[thread objectForKey:@"timestamp"] doubleValue]];
//NSString *dateString = [dateHelper timeIntervalWithStartDate:postDate withEndDate:[NSDate date]];

//How to use AsyncImageView

//NSURL *myURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://images2.fanpop.com/image/photos/13500000/Susan-Coffey-susan-coffey-E2-99-A5-13587707-900-600.jpg"]];
//AsyncImageView *newAsync = [[AsyncImageView alloc] initWithFrame:self.view.frame imageURL:myURL cache:nil loadImmediately:YES];
//[self.view addSubview:newAsync];

//How to use MFSlidingView

//SlidingRepView *slidingRepViewInstance = [[[NSBundle mainBundle]loadNibNamed:@"SlidingRepView" owner:self options:nil]objectAtIndex:0];
//[slidingRepViewInstance initializeSlidingRepView];
//SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
//void (^cancelOrDoneBlock)() = ^{
//    // we must manually slide out the view out if we specify this block
//    [MFSlidingView slideOut];
//};
//[MFSlidingView slideView:slidingRepViewInstance intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];

@end
