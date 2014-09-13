//
//  ConvoFeedCell.m
//  Rep
//
//  Created by Hudson on 5/5/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "ConvoFeedCell.h"

@implementation ConvoFeedCell
@synthesize repMessageLabelOutlet, senderImageViewOutlet, senderNameLabelOutlet, recipientImageViewOutlet, recipientNameLabelOutlet;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self = [[[NSBundle mainBundle] loadNibNamed:@"ConvoFeedCell" owner:self options:nil] objectAtIndex:0];
        
        
    }
    
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


-(void)initializeViewElementsForFeed{
    
    senderNameLabelOutlet.numberOfLines = 1;
    repMessageLabelOutlet.numberOfLines = 10;
    recipientNameLabelOutlet.numberOfLines = 1;
    
}

@end
