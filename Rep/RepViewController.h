//
//  RepViewController.h
//  Rep
//
//  Created by Hud on 2/2/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"
#import "AsyncImageView.h"
#import "RepUserData.h"
#import "DateAndTimeHelper.h"
#import "RadiusRequest.h"
#import "MFSlidingView.h"
#import "SlidingRepView.h"
#import "SlidingConsoleView.h"
#import "MFSideMenu.h"
#import "RepAppDelegate.h"
#import "AnimationLayerController.h"
#import "RepCell.h"
#import "ISO8601DateFormatter.h"
#import "SVPullToRefresh.h"
#import "PictureDelegate.h"

@interface RepViewController : UIViewController


-(void)handleWakeUpFromBackground;
-(void)showLoadingOverlay;
-(void)dismissLoadingOverlay;
-(void)showLoginView;
-(void)showInboxView;
-(void)performOnAppear:(void(^)(void))block;
- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller usingDelegate: (id <UIImagePickerControllerDelegate,UINavigationControllerDelegate>) delegate;
- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller usingDelegate: (id <UIImagePickerControllerDelegate,
                                                                                                 UINavigationControllerDelegate>) delegate;
@property (readonly) BOOL hasAppeared;


@end
