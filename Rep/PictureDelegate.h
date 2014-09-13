//
//  PictureDelegate.h
//  Rep
//
//  Created by Hudson on 5/17/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RepViewController.h"

@protocol PictureManager;

@interface PictureDelegate : NSObject <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, assign) id <PictureManager> myPictureManager;

@end


@protocol PictureManager <NSObject>

@optional
-(void) updateCameraIconWithImage: (UIImage *)imageToUse andPrivate:(BOOL) privacySetting;

@end