//
//  InitialViewController.m
//  Rep
//
//  Created by Hudson on 5/17/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "InitialViewController.h"

@interface InitialViewController ()

@end

@implementation InitialViewController

@synthesize backgroundImageViewOutlet;


- (void)viewDidLoad
{
    [super viewDidLoad];
    

    [self.backgroundImageViewOutlet setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bck_GraphTexture60"]]];
    
    [self.navigationController.navigationBar setHidden:YES];
    
	// Do any additional setup after loading the view.
}

#pragma mark Apple

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:NO];
    [self.navigationController.navigationBar setHidden:NO];
    
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBackgroundImageViewOutlet:nil];
    [super viewDidUnload];
}
@end
