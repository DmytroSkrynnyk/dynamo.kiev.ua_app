//
//  PlayerStats.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 30.09.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlayerStats : NSObject
@property (strong, nonatomic) NSString *name;
@property (nonatomic) NSInteger goalsScored;
@property (nonatomic) NSInteger homeGoals;
@property (nonatomic) NSInteger guestGoals;
@property (nonatomic) NSInteger penaltyScored;
@property (strong, nonatomic) NSString *team;
@end
