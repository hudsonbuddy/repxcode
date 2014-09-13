//
//  RepAppDelegate.h
//  Rep
//
//  Created by Hud on 2/2/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"
#import "RadiusRequest.h"
#import "RadiusError.h"

@class SideMenuViewController;


@interface RepAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SideMenuViewController *sideMenuController;
@property (strong, nonatomic) FBSession *facebookSession;
@property (strong, nonatomic) Facebook *facebook;






extern NSString *const FBSessionStateChangedNotification;


- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void) closeSession;
- (void) sendFacebookRequestWithID: (NSString *)friendID;
- (void) sendGeneralFacebookRequest;

-(void)showInboxView;
-(void)showLoginView;


//Core Data Stack
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;



@end
