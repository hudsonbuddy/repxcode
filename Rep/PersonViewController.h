//
//  PersonViewController.h
//  Rep
//
//  Created by Hudson on 4/24/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "RepViewController.h"

@interface PersonViewController : RepViewController

@property (strong, nonatomic) NSString *repname;
@property (strong, nonatomic) NSString *facebookID;
@property (strong, nonatomic) NSArray *relationshipArray;
@property (strong, nonatomic) NSDictionary *userDictionary;
@property (nonatomic) int *dataArrayCount;


@property (nonatomic) BOOL notCurrentUserProfile;


-(void) initializeWithRepname: (NSString *)myRepname;
-(void) initializeWithFacebookID:(NSString *)fb_id;
-(void) initializeWithRelationshipArray:(NSArray *)relationshipArray;

@property (weak, nonatomic) IBOutlet UILabel *repnameLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *truescoreLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *repRecievedLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *repSentLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *datejoinedLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *repXLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;

@end
