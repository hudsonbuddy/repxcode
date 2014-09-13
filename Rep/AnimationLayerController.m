//
//  AnimationLayerController.m
//  Foster
//
//  Created by Alex Browne on 7/18/11.
//  Copyright 2011 Marauder Group, LLC. All rights reserved.
//

#import "AnimationLayerController.h"
#import <UIKit/UIKit.h>

@implementation AnimationLayerController
@synthesize bottomView,bottomViewController, topView, topViewController;
@synthesize navigationController;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) add:(UIViewController*) tVC onTopOf:(UIViewController*) bVC with:(UINavigationController*) navC {
    self.navigationController = navC;
    self.topViewController = tVC;
    self.bottomViewController = bVC;
    self.topView = topViewController.view;
    self.bottomView = bottomViewController.view;
    
	[UIView beginAnimations: @"PushBottomDown"context: nil];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.3];
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0,0);
    transform = CGAffineTransformScale(transform, .5, .5);
    bottomView.transform = transform;
    //bottomView.alpha = 0;
    [UIView commitAnimations];
    
    [bottomView addSubview:topView];
    transform = CGAffineTransformMakeTranslation(0,0);
    transform = CGAffineTransformScale(transform,4,4);
    topView.transform = transform;
    topView.alpha = 0;
    
    [UIView  beginAnimations: @"PushTopOn"context: nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(addAnimationDidStop:finished:context:)];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelay:0.1];
    transform = CGAffineTransformMakeTranslation(0,0);
    transform = CGAffineTransformScale(transform, 2, 2);
    topView.transform = transform;
    topView.alpha = 1;

    [UIView commitAnimations];
}

- (void)addAnimationDidStop:(NSString*)animationID finished:(BOOL)finished context:(void*)context {
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0,0);
    transform = CGAffineTransformScale(transform, 1, 1);
    topView.transform = transform;
    bottomView.transform = transform;
    [self.navigationController pushViewController:self.topViewController animated:NO];
}

- (void) remove:(UIViewController*) tVC from:(UIViewController*) bVC {
    self.topViewController = tVC;
    self.bottomViewController = bVC;
    self.topView = topViewController.view;
    self.bottomView = bottomViewController.view;
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0,0);
    transform = CGAffineTransformScale(transform, .5, .5);
    bottomView.transform = transform;
    transform = CGAffineTransformScale(transform, 4, 4);
    topView.transform = transform;
    
    [bottomView addSubview:topView];
	[UIView beginAnimations: @"PushTopUp"context: nil];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:.5];
    transform = CGAffineTransformMakeTranslation(0,0);
    transform = CGAffineTransformScale(transform, 4, 4);
    topView.transform = transform;
    topView.alpha = 0;
    [UIView commitAnimations];
    
    [UIView  beginAnimations: @"PushBottomFromUnder"context: nil];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeAnimationDidStop:finished:context:)];
    [UIView setAnimationDuration:.5];
    [UIView setAnimationDelay:.2];
    transform = CGAffineTransformMakeTranslation(0,0);
    transform = CGAffineTransformScale(transform, 1, 1);
    bottomView.transform = transform;
    bottomView.alpha = 1;
    [UIView commitAnimations];
}

- (void)removeAnimationDidStop:(NSString*)animationID finished:(BOOL)finished context:(void*)context {
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0,0);
    transform = CGAffineTransformScale(transform, 1, 1);
    topView.transform = transform;
    bottomView.transform = transform;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
