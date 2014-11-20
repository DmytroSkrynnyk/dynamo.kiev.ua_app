//
//  MatchScoreInfo.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 28.09.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MatchScoreInfo : NSObject
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *homeTeam;
@property (strong, nonatomic) NSString *guestTeam;
@property (nonatomic) NSInteger homeTeamScore;
@property (nonatomic) NSInteger guestTeamScore;
@property (strong, nonatomic) NSString *homeTeamCity;
@property (strong, nonatomic) NSString *guestTeamCity;
@property (strong, nonatomic) NSString *tournament;
@property (strong, nonatomic) NSArray *homeTeamScorers;
@property (strong, nonatomic) NSArray *guestTeamScorers;

-(NSString *)description;

@end
