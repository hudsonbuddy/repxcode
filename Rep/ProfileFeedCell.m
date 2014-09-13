//
//  ProfileFeedCell.m
//  Rep
//
//  Created by Hud on 3/7/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "ProfileFeedCell.h"
#import "PictureViewController.h"

@implementation ProfileFeedCell
@synthesize repnameLabelOutlet, repfactLabelOutlet, reptimeLabelOutlet, pictureString, pic_id, cameraButtonOutlet;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self = [[[NSBundle mainBundle] loadNibNamed:@"ProfileFeedCell" owner:self options:nil]objectAtIndex:0];


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

- (IBAction)cameraButtonPressed:(id)sender {
    
    PictureViewController *myController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                           instantiateViewControllerWithIdentifier:@"pictureID"];
    myController.myPictureManager = nil;
    myController.imageToUse = nil;
    myController.pic_id = pic_id;
    [[MFSideMenuManager sharedManager].navigationController presentViewController:myController animated:YES completion:nil];
}

-(void)initializeViewElementsForMailbox{
    
    repnameLabelOutlet.textColor = [UIColor whiteColor];
    repfactLabelOutlet.textColor = [UIColor whiteColor];
    reptimeLabelOutlet.textColor = [UIColor whiteColor];

//    repnameLabelOutlet.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4];
//    repfactLabelOutlet.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4];
    
    repnameLabelOutlet.numberOfLines = 1;
    repfactLabelOutlet.numberOfLines = 10;
    reptimeLabelOutlet.numberOfLines = 1;

    repnameLabelOutlet.font = [UIFont fontWithName:@"Courier-Bold" size:15.0];
    repfactLabelOutlet.font = [UIFont fontWithName:@"Courier-Oblique" size:15.0];
    reptimeLabelOutlet.font = [UIFont fontWithName:@"Courier" size:12.0];
    
    [self.cameraButtonOutlet setImage:[UIImage imageNamed:@"cameraicon"] forState:UIControlStateHighlighted];
//    [repnameLabelOutlet setFrame:CGRectMake(10, 169, 300, 21)];
//    [reptimeLabelOutlet setFrame:CGRectMake(10, 174, 300, 21)];


//    repfactLabelOutlet.layer.shadowColor = [UIColor blackColor].CGColor;
//    repfactLabelOutlet.layer.shadowOffset = CGSizeMake(0, 1);
//    repfactLabelOutlet.layer.shadowOpacity = .5;
//    repfactLabelOutlet.layer.shadowRadius = 1.0;
//    repfactLabelOutlet.layer.shadowPath = [UIBezierPath bezierPathWithRect:repfactLabelOutlet.bounds].CGPath;

}

-(void)initializeViewElementsForFeed{

    repnameLabelOutlet.textColor = [UIColor whiteColor];
    repfactLabelOutlet.textColor = [UIColor whiteColor];
    reptimeLabelOutlet.textColor = [UIColor whiteColor];
    
    repnameLabelOutlet.numberOfLines = 1;
    repfactLabelOutlet.numberOfLines = 10;
    reptimeLabelOutlet.numberOfLines = 1;
    
    repnameLabelOutlet.font = [UIFont fontWithName:@"Courier-Bold" size:15.0];
    repfactLabelOutlet.font = [UIFont fontWithName:@"Courier-Oblique" size:15.0];
    reptimeLabelOutlet.font = [UIFont fontWithName:@"Courier" size:12.0];

}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self];
    
    NSLog(@"x = %.0f, y = %.0f", point.x, point.y);
    if (CGRectContainsPoint(self.cameraButtonOutlet.layer.frame, point))
        return NO;
    
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
