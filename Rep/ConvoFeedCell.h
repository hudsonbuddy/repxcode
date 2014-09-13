//
//  ConvoFeedCell.h
//  Rep
//
//  Created by Hudson on 5/5/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "RepCell.h"

@interface ConvoFeedCell : RepCell

@property (weak, nonatomic) IBOutlet UIImageView *senderImageViewOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *recipientImageViewOutlet;
@property (weak, nonatomic) IBOutlet UILabel *repMessageLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *senderNameLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *recipientNameLabelOutlet;
-(void)initializeViewElementsForFeed;

@end
