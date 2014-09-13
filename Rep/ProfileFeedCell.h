//
//  ProfileFeedCell.h
//  Rep
//
//  Created by Hud on 3/7/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "RepCell.h"
#import "AsyncImageView.h"

@interface ProfileFeedCell : RepCell <UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *repnameLabelOutlet;
@property (strong, nonatomic) IBOutlet UILabel *repfactLabelOutlet;
@property (strong, nonatomic) IBOutlet UILabel *reptimeLabelOutlet;
@property (strong, nonatomic) NSString *pictureString;
@property (weak, nonatomic) IBOutlet UIButton *cameraButtonOutlet;
@property (strong, nonatomic) NSString *pic_id;

- (IBAction)cameraButtonPressed:(id)sender;
-(void)initializeViewElementsForMailbox;
-(void)initializeViewElementsForFeed;
@end
