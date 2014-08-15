//
//  ParseDynamoKievUa.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 30.07.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArticleContent.h"

@interface ParseDynamoKievUa : NSObject
+(NSMutableArray *)parseDynamoNewslinePage:(NSString *)page;
+(void)parseDynamoArticlePage:(NSString *)page savingTo:(ArticleContent *)article;
@end
