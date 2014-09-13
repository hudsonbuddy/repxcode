//
//  RepUserData.h
//  Rep
//
//  Created by Hud on 2/2/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RepUserData : NSObject


@property (strong, nonatomic) NSMutableArray *friends;
@property (strong, nonatomic) NSMutableDictionary *asyncImageCache;
@property (strong, nonatomic) NSMutableArray *inbox;
@property (strong, nonatomic) NSMutableArray *outbox;
@property (strong, nonatomic) NSString *currentUserRepName;
@property (strong, nonatomic) NSString *currentUserID;
@property (nonatomic) BOOL facebookPublishActions;
@property (nonatomic) BOOL alertViewShown;





+ (RepUserData *) sharedRepUserData;
+ (void) resetRepUserData;

@end
