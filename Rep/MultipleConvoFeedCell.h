//
//  MultipleConvoFeedCell.h
//  Rep
//
//  Created by Hudson on 5/7/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "RepCell.h"

@interface MultipleConvoFeedCell : RepCell
-(void)initializeViewElements;
@property (weak, nonatomic) IBOutlet UIImageView *senderImageOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *singleRecipientImageOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *secondRecipientImageOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *thirdRecipientImageOutlet;
@property (weak, nonatomic) IBOutlet UILabel *repMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *repParticipantsLabel;
@property (weak, nonatomic) IBOutlet UILabel *repTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *cameraButtonOutlet;
- (IBAction)cameraButtonPressed:(id)sender;

@property (strong, nonatomic) NSString *pic_id;

@end
