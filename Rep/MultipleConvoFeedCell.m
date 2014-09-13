//
//  MultipleConvoFeedCell.m
//  Rep
//
//  Created by Hudson on 5/7/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "MultipleConvoFeedCell.h"
#import "PictureViewController.h"

@implementation MultipleConvoFeedCell

@synthesize repMessageLabel, repParticipantsLabel, repTimeLabel, pic_id;
@synthesize senderImageOutlet, singleRecipientImageOutlet, secondRecipientImageOutlet, thirdRecipientImageOutlet;

-(void)initializeViewElements{
    
    repParticipantsLabel.numberOfLines = 1;
    repMessageLabel.numberOfLines = 10;
    repTimeLabel.numberOfLines = 1;
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self = [[[NSBundle mainBundle] loadNibNamed:@"MultipleConvoFeedCell" owner:self options:nil] objectAtIndex:0];
        
        [self.cameraButtonOutlet setImage:[UIImage imageNamed:@"cameraicon"] forState:UIControlStateHighlighted];
        
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

- (IBAction)cameraButtonPressed:(id)sender {
    
    PictureViewController *myController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                           instantiateViewControllerWithIdentifier:@"pictureID"];
    myController.myPictureManager = nil;
    myController.imageToUse = nil;
    myController.pic_id = pic_id;
    [[MFSideMenuManager sharedManager].navigationController presentViewController:myController animated:YES completion:nil];
}
@end
