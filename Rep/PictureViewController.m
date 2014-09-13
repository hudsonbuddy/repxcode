//
//  PictureViewController.m
//  Rep
//
//  Created by Hudson on 5/17/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "PictureViewController.h"

@interface PictureViewController ()

@property BOOL privatePicture;

@end

@implementation PictureViewController
@synthesize myPictureManager, pictureImageViewOutlet, imageToUse, pic_id, cancelButtonOutlet, doneButtonOutlet, navBarOutlet, navItemOutlet, privatePicture, privateLabelOutlet;

int swipeCount;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pictureImageViewOutlet.contentMode = UIViewContentModeScaleAspectFit;
    swipeCount = 0;
    
    if (pic_id) {
        
        navItemOutlet.rightBarButtonItem = nil;
        AsyncImageView *myAsync = [[AsyncImageView alloc] initWithFrame:pictureImageViewOutlet.frame andPicID:pic_id];
        [self.view addSubview:myAsync];
        [self.view sendSubviewToBack:myAsync];
        
    }else{
        [pictureImageViewOutlet setImage:imageToUse];
        [self addGestureRecognizers];


    }
    
    UIView *tempView = [[UIView alloc]initWithFrame:self.view.frame];
    
    tempView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bck_GraphTexture60"]];
    [self.view addSubview:tempView];
    [self.view sendSubviewToBack:tempView];
	// Do any additional setup after loading the view.
}

-(void)addGestureRecognizers{
    
    
//    UISwipeGestureRecognizer *doubleSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleSwipe:)];
//    [self.view addGestureRecognizer:doubleSwipe];
//    doubleSwipe.numberOfTouchesRequired = 2;
//    doubleSwipe.enabled = YES;
    
    UISwipeGestureRecognizer *doubleSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleSwipe:)];
    [self.view addGestureRecognizer:doubleSwipe];
    doubleSwipe.direction = UISwipeGestureRecognizerDirectionDown;
    doubleSwipe.numberOfTouchesRequired = 1;
    doubleSwipe.enabled = YES;
    
    UISwipeGestureRecognizer *doubleSwipeLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleSwipe:)];
    [self.view addGestureRecognizer:doubleSwipeLeft];
    doubleSwipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    doubleSwipeLeft.numberOfTouchesRequired = 1;
    doubleSwipeLeft.enabled = YES;

    
}

-(void) handleDoubleSwipe: (UISwipeGestureRecognizer *) sender{
    
    swipeCount++;
    [self performSelector:@selector(testPrivatePicture) withObject:nil afterDelay:1.0];
    
    
}
                           
-(void) testPrivatePicture{
    
    if (swipeCount == 2) {
        
        if (privatePicture) {
            privatePicture = NO;
            [UIView animateWithDuration:0.2
                             animations:^{
                                 
                                 privateLabelOutlet.alpha = 0;

                             } completion:^(BOOL finished){
                                 privateLabelOutlet.hidden = YES;

                             }];
        }else{
            
            privatePicture = YES;
            
            privateLabelOutlet.hidden = NO;
            
            [UIView animateWithDuration:0.2
                             animations:^{
            
                                 privateLabelOutlet.alpha = .8;
            
                             } completion:^(BOOL finished){
        
                             }];
            
        }
    }

    swipeCount = 0;
    
    
}

- (IBAction)doneButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)useButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

    if (pic_id == nil) {
        if ([myPictureManager respondsToSelector:@selector(updateCameraIconWithImage:andPrivate:)]) {
            [myPictureManager updateCameraIconWithImage:imageToUse andPrivate:privatePicture];
        }
    }

    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPictureImageViewOutlet:nil];
    [self setCancelButtonOutlet:nil];
    [self setDoneButtonOutlet:nil];
    [self setNavBarOutlet:nil];
    [self setNavItemOutlet:nil];
    [self setPrivateLabelOutlet:nil];
    [super viewDidUnload];
}


@end
