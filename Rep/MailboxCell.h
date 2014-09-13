//
//  MailboxCell.h
//  Rep
//
//  Created by Hud on 3/12/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "RepCell.h"

@interface MailboxCell : RepCell
@property (strong, nonatomic) IBOutlet UILabel *repnameLabelOutlet;
@property (strong, nonatomic) IBOutlet UILabel *repMessageLabelOutlet;

@end
