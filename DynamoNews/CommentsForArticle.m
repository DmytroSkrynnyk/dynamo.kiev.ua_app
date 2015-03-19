//
//  CommentsForArticle.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 17.02.15.
//  Copyright (c) 2015 AlPono.inc. All rights reserved.
//

#import "CommentsForArticle.h"

@interface CommentsForArticle ()

@end

@implementation CommentsForArticle

-(NSString *)nextRequestParameter{//after downloading failure doesn't work
    NSString *parameters;
    if (self.nextRequestCounter == 0) {
        parameters = @"";
    } else {
        parameters = [NSString stringWithFormat:@"?offset=%ld", (long)self.nextRequestCounter * 30];
    }
    _nextRequestCounter++;
    return parameters;
}

@end
