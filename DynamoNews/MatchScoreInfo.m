//
//  MatchScoreInfo.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 28.09.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import "MatchScoreInfo.h"

@implementation MatchScoreInfo
-(NSString *)description{
    return [NSString stringWithFormat:@"%@ %ld - %ld %@ %@", _homeTeam, (long)_homeTeamScore, (long)_guestTeamScore, _guestTeam, _date];
}
@end
