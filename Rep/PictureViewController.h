//
//  PictureViewController.h
//  Rep
//
//  Created by Hudson on 5/17/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PictureDelegate.h"

@interface PictureViewController : UIViewController

@property (nonatomic, strong) NSString *pic_id;
@property (nonatomic, assign) id <PictureManager> myPictureManager;
@property (strong, nonatomic) UIImage *imageToUse;
@property (weak, nonatomic) IBOutlet UIImageView *pictureImageViewOutlet;
@property (weak, nonatomic) IBOutlet UILabel *privateLabelOutlet;


@property (weak, nonatomic) IBOutlet UINavigationBar *navBarOutlet;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItemOutlet;

- (IBAction)doneButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButtonOutlet;

- (IBAction)useButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButtonOutlet;

@end
