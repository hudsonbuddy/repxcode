//
//  AnimationLayerController.h
//  Foster
//
//  Created by Alex Browne on 7/18/11.
//  Copyright 2011 Marauder Group, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AnimationLayerController : NSObject {
    UINavigationController *navigationController;
    UIViewController *topViewController, *bottomViewController;
    UIView *topView, *bottomView;
}

@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) UIViewController *topViewController;
@property (nonatomic, retain) UIViewController *bottomViewController;
@property (nonatomic, retain) UIView *topView;
@property (nonatomic, retain) UIView *bottomView;

- (void) add:(UIViewController*) tVC onTopOf:(UIViewController*) bVC with:(UINavigationController*) navC;
- (void) remove:(UIViewController*) tVC from:(UIViewController*) bVC;

@end
