//
//  RepView.m
//  Rep
//
//  Created by Hudson on 5/7/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "RepView.h"

@implementation RepView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    
    return YES;
    
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
