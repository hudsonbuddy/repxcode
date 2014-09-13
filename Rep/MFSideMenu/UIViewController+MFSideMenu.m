//
//  UIViewController+MFSideMenu.m
//
//  Created by Michael Frederick on 3/18/12.
//

#import "UIViewController+MFSideMenu.h"
#import "AnimationLayerController.h"
#import "MFSideMenuManager.h"
#import <objc/runtime.h>
//#import "NotificationsWindow.h"
//#import "RadiusRequest.h"
//#import "NotificationsFind.h"
//#import "Notification.h"


@class SideMenuViewController;

@interface UIViewController (MFSideMenuPrivate)
- (void)toggleSideMenu:(BOOL)hidden;
@end

@implementation UIViewController (MFSideMenu)

static char menuStateKey;

static const NSInteger TAP_BLOCKER_TAG = 6854;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void) toggleSideMenuPressed:(id)sender {
    if(self.navigationController.menuState == MFSideMenuStateVisible) {
        [self.navigationController setMenuState:MFSideMenuStateHidden];
    } else {
        [self.navigationController setMenuState:MFSideMenuStateVisible];
    }
}

- (void) backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
//    AnimationLayerController *animationController = [[AnimationLayerController alloc]init];
//
//    [animationController remove:self from:self.parentViewController];
    
//    [animationController remove:[[MFSideMenuManager sharedManager].navigationController.viewControllers lastObject] from:[[MFSideMenuManager sharedManager].navigationController.viewControllers objectAtIndex:0]];

}

// We can customize the Menu and Back buttons here
- (void) setupSideMenuBarButtonItem {
//    // Stock code
//    if(self.navigationController.menuState == MFSideMenuStateVisible ||
//       [[self.navigationController.viewControllers objectAtIndex:0] isEqual:self]) {
//        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
//                                                  initWithImage:[UIImage imageNamed:@"btn_logo.png"] style:UIBarButtonItemStyleBordered
//                                                  target:self action:@selector(toggleSideMenuPressed:)] autorelease];
//    } else {
//        NSLog(@"in back section");
//        self.navigationItem.hidesBackButton = YES;
//        self.navigationItem.backBarButtonItem.tintColor = [UIColor greenColor];
//        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow"]
//                                                                                  style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonPressed:)] autorelease];
//    }
    //Custom code
    
    if(self.navigationController.menuState == MFSideMenuStateVisible ||
       [[self.navigationController.viewControllers objectAtIndex:0] isEqual:self]) {
        UIImage *normalBackImage = [UIImage imageNamed:@"btn_menu.png"];
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.bounds = CGRectMake(0, 0, normalBackImage.size.width, normalBackImage.size.height);
        //backButton.bounds = CGRectMake(0, 0, 1, 1);
        [backButton setImage:normalBackImage forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(toggleSideMenuPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        //new code for custom button
        UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
        myButton.frame= CGRectMake(0, 0, 44, 30);
        [myButton setTitle:@"~" forState:UIControlStateNormal];
        [myButton.titleLabel setFont:[UIFont fontWithName:@"Courier" size:24]];
        [myButton setBackgroundColor:[UIColor whiteColor]];
        [myButton.layer setCornerRadius:3];
        [myButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [myButton.titleLabel setHighlightedTextColor:[UIColor greenColor]];
        [myButton setTintColor:[UIColor blackColor]];
        [myButton addTarget:self action:@selector(toggleSideMenuPressed:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:myButton];
        self.navigationItem.leftBarButtonItem = backButtonItem;
        [backButtonItem release];
    } else {
        UIImage *normalBackImage = [UIImage imageNamed:@"back-arrow.png"];
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.bounds = CGRectMake(0, 0, normalBackImage.size.width, normalBackImage.size.height);
        
        [backButton setImage:normalBackImage forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        //new code for custom button
        UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
        myButton.frame= CGRectMake(0, 0, 44, 30);
        [myButton setTitle:@".." forState:UIControlStateNormal];
        [myButton.titleLabel setFont:[UIFont fontWithName:@"Courier" size:20]];
        [myButton setBackgroundColor:[UIColor whiteColor]];
        [myButton.layer setCornerRadius:3];
        [myButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [myButton.titleLabel setHighlightedTextColor:[UIColor greenColor]];
        [myButton setTintColor:[UIColor blackColor]];
        [myButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:myButton];
        self.navigationItem.leftBarButtonItem = backButtonItem;
    
        [backButtonItem release];
    }
    
    if(![self.navigationController.navigationBar viewWithTag:TAP_BLOCKER_TAG]) {
        UIView *tapBlocker = [[UIView alloc] initWithFrame:CGRectMake(50,0,self.navigationController.navigationBar.frame.size.width-100,self.navigationController.navigationBar.frame.size.height)];
        NSLog(@"tapBlocked called in class: %@",[self class]);
        tapBlocker.tag = TAP_BLOCKER_TAG;
        [self.navigationController.navigationBar addSubview:tapBlocker];
    }
    
    //setting title text attributes
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [self.navigationController.navigationBar setTitleTextAttributes:
    [NSDictionary dictionaryWithObjectsAndKeys:
     [UIColor whiteColor], UITextAttributeTextColor,
     [UIFont fontWithName:@"Courier" size:20.0], UITextAttributeFont,nil]];
}



- (void)setMenuState:(MFSideMenuState)menuState {
    if(![self isKindOfClass:[UINavigationController class]]) {
        self.navigationController.menuState = menuState;
        return;
    }
    
    MFSideMenuState currentState = self.menuState;
    
    objc_setAssociatedObject(self, &menuStateKey, [NSNumber numberWithInt:menuState], OBJC_ASSOCIATION_RETAIN);
    
    switch (currentState) {
        case MFSideMenuStateHidden:
            if (menuState == MFSideMenuStateVisible) {
                [self toggleSideMenu:NO];
                
            }
            break;
        case MFSideMenuStateVisible:
            if (menuState == MFSideMenuStateHidden) {
                [self toggleSideMenu:YES];
            }
            break;
        default:
            break;
    }
}

- (MFSideMenuState)menuState {
    if(![self isKindOfClass:[UINavigationController class]]) {
        return self.navigationController.menuState;
    }
    
    return (MFSideMenuState)[objc_getAssociatedObject(self, &menuStateKey) intValue];
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
    if ([animationID isEqualToString:@"toggleSideMenu"])
    {
        if([self isKindOfClass:[UINavigationController class]]) {
            UINavigationController *controller = (UINavigationController *)self;
            [controller.visibleViewController setupSideMenuBarButtonItem];
            
            // disable user interaction on the current view controller
            controller.visibleViewController.view.userInteractionEnabled = (self.menuState == MFSideMenuStateHidden);
        }
    }
}

@end


@implementation UIViewController (MFSideMenuPrivate)

// TODO: alter the duration based on the current position of the menu
// to provide a smoother animation
- (void) toggleSideMenu:(BOOL)hidden {
    if(![self isKindOfClass:[UINavigationController class]]) return;
    
    [UIView beginAnimations:@"toggleSideMenu" context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    [UIView setAnimationDuration:kMenuAnimationDuration];
    
    CGRect frame = self.view.frame;
    frame.origin = CGPointZero;
    if (!hidden) {
        switch (self.interfaceOrientation) 
        {
            case UIInterfaceOrientationPortrait:
                frame.origin.x = kSidebarWidth;
                break;
                
            case UIInterfaceOrientationPortraitUpsideDown:
                frame.origin.x = -1*kSidebarWidth;
                break;
                
            case UIInterfaceOrientationLandscapeLeft:
                frame.origin.y = -1*kSidebarWidth;
                break;
                
            case UIInterfaceOrientationLandscapeRight:
                frame.origin.y = kSidebarWidth;
                break;
        } 
    }
    self.view.frame = frame;
        
    [UIView commitAnimations];
}

@end 
