//
//  SlidingConsoleView.h
//  Rep
//
//  Created by Hudson on 5/6/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RadiusRequest.h"
#import "MFSlidingView.h"
#import "NotificationsFind.h"

@interface SlidingConsoleView : UIView <UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *consoleTextView;

@property (nonatomic) CGFloat animatedDistance;

-(void)initializeConsoleView;
@end
