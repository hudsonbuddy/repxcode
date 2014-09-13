//
//  RepCell.m
//  Rep
//
//  Created by Hud on 3/7/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "RepCell.h"

@implementation RepCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        longPressGR.minimumPressDuration = 2.0; 

        [self addGestureRecognizer:longPressGR];
        
    }
    return self;
}

- (void) handleLongPress: (UILongPressGestureRecognizer *) sender{
    
    NSLog(@"hello world");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
