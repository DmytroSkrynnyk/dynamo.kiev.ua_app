//
//  TeamResults.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 29.09.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import "TeamResults.h"
#import "ContentController.h"

@implementation TeamResults

-(NSArray *)teamResultsToArray{
    NSArray *teamResults = [NSArray arrayWithObjects:
                            [NSString stringWithFormat:@"%d", _position],
                            [NSString stringWithFormat:@"%@ %@", _name, _city],
                            [NSString stringWithFormat:@"%d", _gamesPlayed],
                            [NSString stringWithFormat:@"%d",_wins],
                            [NSString stringWithFormat:@"%d", _draws],
                            [NSString stringWithFormat:@"%d", _defeats],
                            [NSString stringWithFormat:@"%d - %d", _goalsScored, _goalsAgainst],
                            [NSString stringWithFormat:@"%d", _points],
                            nil];
    return teamResults;
}

@end
