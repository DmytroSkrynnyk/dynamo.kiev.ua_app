//
//  TeamResults.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 29.09.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TeamResults : NSObject
@property (nonatomic) NSInteger position;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *city;
@property (nonatomic) NSInteger gamesPlayed;
@property (nonatomic) NSInteger wins;
@property (nonatomic) NSInteger draws;
@property (nonatomic) NSInteger defeats;
@property (nonatomic) NSInteger goalsScored;
@property (nonatomic) NSInteger goalsAgainst;
@property (nonatomic) NSInteger points;
@property (strong, nonatomic) NSString *imageLink;
@property (strong, nonatomic) UIImage *image;

@end
