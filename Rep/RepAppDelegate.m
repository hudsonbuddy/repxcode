//
//  RepAppDelegate.m
//  Rep
//
//  Created by Hud on 2/2/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "RepAppDelegate.h"
#import "SideMenuViewController.h"
#import "MFSideMenu.h"
#import "RepUserData.h"
#import <CoreData/CoreData.h>
#import "RegisterViewController.h"
#import "SelfViewController.h"

@implementation RepAppDelegate
@synthesize facebookSession;
@synthesize facebook = _facebook;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

NSHTTPCookieStorage *_myCookieStorage;

NSString *const FBSessionStateChangedNotification =
@"com.Hudson.Login:FBSessionStateChangedNotification";


#pragma mark Cookie Handling

-(void) createRepCookieWithRequest:(NSMutableURLRequest *) myRequest{
    
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"repmeback.com", NSHTTPCookieDomain,
                                @"/", NSHTTPCookiePath, 
                                @"RepCookieTest", NSHTTPCookieName,
                                @"1", NSHTTPCookieValue,
                                nil];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
    
    NSArray* cookies = [NSArray arrayWithObjects: cookie, nil];
    
    NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    
    [myRequest setAllHTTPHeaderFields:headers];
    
    _myCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
}

#pragma mark Facebook Authentication

/*
 * Callback for session changes.
 */
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    

    
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
                NSLog(@"User session found");
                
                // Initiate a Facebook instance
                self.facebook = [[Facebook alloc]
                                 initWithAppId:FBSession.activeSession.appID
                                 andDelegate:nil];
                
                // Store the Facebook session information
                self.facebook.accessToken = FBSession.activeSession.accessToken;
                self.facebook.expirationDate = FBSession.activeSession.expirationDate;
                
                NSString *accessToken = [NSString stringWithFormat:@"%@", FBSession.activeSession.accessToken];
                
                NSLog(@"%@", accessToken);
                
                [self loginTestWithAccessToken:accessToken];
                
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            self.facebook = nil;

            [self showLoginView];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:FBSessionStateChangedNotification
     object:session];
    
    if (error) {
        NSString *errorTitle = NSLocalizedString(@"Error", @"Facebook connect");
        NSString *errorMessage = [error localizedDescription];
        if (error.code == FBErrorLoginFailedOrCancelled) {
            errorTitle = NSLocalizedString(@"Facebook Failed", @"Facebook Connect");
            errorMessage = NSLocalizedString(@"Make sure you've allowed Rep to use Facebook your Settings.", @"Facebook connect");
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorTitle
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"Facebook Connect")
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    
//    if (error) {
//        UIAlertView *alertView = [[UIAlertView alloc]
//                                  initWithTitle:@"Error"
//                                  message:error.localizedDescription
//                                  delegate:nil
//                                  cancelButtonTitle:@"OK"
//                                  otherButtonTitles:nil];
//        [alertView show];
//    }
}

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"email",
                            nil];



    return [FBSession openActiveSessionWithReadPermissions:permissions
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
                                             
                                             
                                             [self sessionStateChanged:session
                                                                 state:state
                                                                 error:error];
                                             
                                             
                                             
                                         }];
}

    
            

- (void)sendFacebookRequestWithID: (NSString *)friendID {
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"I just repped you on this app, check out your rep!",  @"message", [NSString stringWithFormat:@"544155947"], @"to",
                                   nil];
    

    [self.facebook dialog:@"apprequests"
                andParams:params
              andDelegate:nil];
    
}

-(void) sendGeneralFacebookRequest{
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"Check out this awesome app.",  @"message",
                                   nil];
    
    [self.facebook setAccessToken:FBSession.activeSession.accessToken];
    
    [self.facebook dialog:@"apprequests"
                andParams:params
              andDelegate:nil];
    
    
}

-(void) loginTestWithAccessToken: (NSString *)accessToken{
    
    RadiusRequest *inboxRequestReal = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:accessToken, @"access_token", nil] apiMethod:@"register" httpMethod:@"POST"];
    
    [inboxRequestReal startWithCompletionHandler:^(id response, RadiusError *error){
        
        [self updateDeviceTokenWithToken];

        NSLog(@"%@", response);
        if ([[response objectForKey:@"data"]objectForKey:@"repname"]) {
            
            [self showInboxView];
            NSUserDefaults *myDefaults = [NSUserDefaults standardUserDefaults];
            
            NSString *repname = [[response objectForKey:@"data"]objectForKey:@"repname"];
            NSString *_id = [[response objectForKey:@"data"]objectForKey:@"_id"];
            
            [myDefaults setObject:_id forKey:@"_id"];
            [myDefaults setObject:repname forKey:@"repname"];

            
        }else if ([[response objectForKey:@"data"]objectForKey:@"repname"]==nil){
            
            [self showRegisterViewWithFacebookDictionary:[response objectForKey:@"data"]];
            
        }else{
            [self showLoginView];
        }
     
    }];
    
}

-(void) updateDeviceTokenWithToken{
    
    NSString *token = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"token"]];

    
    RadiusRequest *inboxRequestReal = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:token, @"device_token", nil] apiMethod:@"apn/set" httpMethod:@"POST"];
    inboxRequestReal.apiMethod = [NSString stringWithFormat:@"index"];
    [inboxRequestReal startWithCompletionHandler:^(id response, RadiusError *error){
        
        NSLog(@"%@", response);

        
    }];
    
}

-(void) zeroOutBadgeNumber{
    
    RadiusRequest *inboxRequestReal = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:nil] apiMethod:@"apn/zero" httpMethod:@"POST"];
    
    [inboxRequestReal startWithCompletionHandler:^(id response, RadiusError *error){
        
        NSLog(@"%@", response);
        
        
    }];
    
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

-(void) showRegisterViewWithFacebookDictionary: (NSDictionary *)dictionary{
    
    RegisterViewController *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                        instantiateViewControllerWithIdentifier:@"registerID"];
    [demoController initializeRegisterViewWithFacebookDictionary:dictionary];
    NSArray *controllers = [NSArray arrayWithObject:demoController];
    [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
    [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
    
}

-(void) showProfileViewWithID: (NSString *)my_ID{
    
    SelfViewController *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                          instantiateViewControllerWithIdentifier:@"selfID"];
    
    
    [demoController initializeSelfWithID:my_ID];
    NSArray *controllers = [NSArray arrayWithObject:demoController];
    [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
    [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
}

- (void) closeSession {
    
    [FBSession.activeSession closeAndClearTokenInformation];
}

/*
 * If we have a valid session at the time of openURL call, we handle
 * Facebook transitions by passing the url argument to handleOpenURL
 */
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBSession.activeSession handleOpenURL:url];
}

#pragma mark Apple Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    

    
    self.sideMenuController = [[SideMenuViewController alloc] init];
    
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    [self.window makeKeyAndVisible];
    //SideMenuViewController *sideMenuViewController = [[SideMenuViewController alloc] init];
    
    [MFSideMenuManager configureWithNavigationController:navigationController sideMenuController:self.sideMenuController];
    
    // See if we have a valid token for the current state.
    [FBProfilePictureView class];
    
    // Let the device know we want to receive push notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    if (launchOptions != nil)
    {
        NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (dictionary != nil)
        {
            NSLog(@"Launched from push notification: %@", dictionary);
            
            NSString *type = [NSString stringWithFormat:@"%@", [dictionary objectForKey:@"type"]];
            NSString *source_id = [NSString stringWithFormat:@"%@", [dictionary objectForKey:@"source_id"]];
            
            
            if ([type isEqualToString:@"quote"]) {
                [self showProfileViewWithID:source_id];
            }else if ([type isEqualToString:@"inbox"]){
                [self showInboxView];
                
            }
            
        }
    }
    
    RadiusRequest *inboxRequestReal = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:nil] apiMethod:@"index" httpMethod:@"POST"];
    inboxRequestReal.apiMethod = [NSString stringWithFormat:@"index"];
    [inboxRequestReal startWithCompletionHandler:^(id response, RadiusError *error){
        
        
        
        NSLog(@"%@", response);
        
        
        
        if ([[response objectForKey:@"auth"]integerValue] == 1) {
            
            
            if ([[[response objectForKey:@"data"]objectForKey:@"data"]objectForKey:@"repname"]==nil) {
                [self showRegisterViewWithFacebookDictionary:[[response objectForKey:@"data"]objectForKey:@"data"]];
            }else{
                [self showInboxView];
                
                NSUserDefaults *myDefaults = [NSUserDefaults standardUserDefaults];
                
                NSString *repname = [[[response objectForKey:@"data"] objectForKey:@"data"]objectForKey:@"repname"];
                NSString *_id = [[[response objectForKey:@"data"]objectForKey:@"data"]objectForKey:@"_id"];
                
                [myDefaults setObject:_id forKey:@"_id"];
                [myDefaults setObject:repname forKey:@"repname"];
                
//                NSString *test = [NSString stringWithFormat:@"%@", [myDefaults objectForKey:@"_id"]];
//                NSString *testagain = [NSString stringWithFormat:@"%@", [myDefaults objectForKey:@"repname"]];


            }
            


        }else if ([[response objectForKey:@"auth"]integerValue] == 0) {
            [self showLoginView];

        }
        
    }];
    


//    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
//        // To-do, show logged in view
//        [self openSessionWithAllowLoginUI:YES];
//        
//    } else {
//        // No, display the login page.
//        
//        [self showLoginView];
//        
//    }

    // Override point for customization after application launch.
    

    

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // We need to properly handle activation of the application with regards to Facebook Login
    // (e.g., returning from iOS 6.0 Login Dialog or from fast app switching).
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);
    
    NSString* newToken = [deviceToken description];
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
	NSLog(@"My token is: %@", newToken);
//    if (![[[NSUserDefaults standardUserDefaults]objectForKey:@"token"]isEqualToString:newToken]) {
    
        [[NSUserDefaults standardUserDefaults] setObject:newToken forKey:@"token"];
        [self updateDeviceTokenWithToken];

//    }

}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
	NSLog(@"Received notification: %@", userInfo);
    if([application applicationState] == UIApplicationStateInactive)
    {
        
        NSString *type = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"type"]];
        NSString *source_id = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"source_id"]];
        
        
        if ([type isEqualToString:@"quote"]) {
            [self showProfileViewWithID:source_id];
        }else if ([type isEqualToString:@"inbox"]){
            [self showInboxView];
            
        }
        
        //If the application state was inactive, this means the user pressed an action button
        // from a notification.
    
//        [self showInboxView];
    
    }

}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Rep" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Rep.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}



@end
