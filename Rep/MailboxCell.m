//
//  MailboxCell.m
//  Rep
//
//  Created by Hud on 3/12/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "MailboxCell.h"

@implementation MailboxCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self = [[[NSBundle mainBundle] loadNibNamed:@"MailboxCell" owner:self options:nil]objectAtIndex:0];

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

@end
