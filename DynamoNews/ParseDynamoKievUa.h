//
//  ParseDynamoKievUa.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 30.07.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArticleContent.h"
#import "HTMLNode.h"
#import "MatchScoreInfo.h"

@interface ParseDynamoKievUa : NSObject
+(NSMutableArray *)parseDynamoNewslinePage:(NSString *)page;
+(void)parseDynamoArticlePage:(NSString *)page savingTo:(ArticleContent *)article;
+(NSMutableArray *)parseBlogsPage:(NSString *)page;
+(void)parseBlogArticlePage:(NSString *)page savingTo:(ArticleContent *)article;
+(NSMutableArray *)parseMatchCenterFile:(NSString *)page;
+(NSMutableArray *)parseLegueTablePage:(NSString *)page;
+(NSMutableArray *)parseLegueSchedulePage:(NSString *)page;
+(NSMutableArray *)parseLegueScorersPage:(NSString *)page;
+(MatchScoreInfo *)parseCentralMatchPage:(NSString *)page;
+(NSMutableDictionary *)parseTableAndCalendarPage:(NSString *)page;
@end
