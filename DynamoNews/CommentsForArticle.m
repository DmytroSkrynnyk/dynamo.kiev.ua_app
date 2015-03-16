//
//  CommentsForArticle.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 17.02.15.
//  Copyright (c) 2015 AlPono.inc. All rights reserved.
//

#import "CommentsForArticle.h"

@interface CommentsForArticle ()
@property (nonatomic) NSInteger nextRequestCounter;
@end

@implementation CommentsForArticle

-(NSString *)nextRequestParameter{
    if (_nextRequestCounter == 0) {
        return @"";
    } else {
        NSString *parameters = [NSString stringWithFormat:@"?offset=%ld", (long)_nextRequestCounter];
        _nextRequestCounter += 30;
        return parameters;
    }
}

@end
