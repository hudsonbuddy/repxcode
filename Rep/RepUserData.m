//
//  RepUserData.m
//  Rep
//
//  Created by Hud on 2/2/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "RepUserData.h"

@implementation RepUserData

@synthesize friends;
@synthesize asyncImageCache;
@synthesize inbox, outbox;
@synthesize currentUserID, currentUserRepName;
@synthesize facebookPublishActions, alertViewShown;

static RepUserData *instance = nil;


- (id) init
{
    self = [super init];
    if ( self )
    {
        // custom initialization goes here
    }
    
    return self;
}

+ (RepUserData *) sharedRepUserData {
    
    if ( instance == nil )
    {
        instance = [[self alloc] init];
    }
    
    return instance;
}

+ (void) resetRepUserData {
    
    instance = nil;
    
}


@end
