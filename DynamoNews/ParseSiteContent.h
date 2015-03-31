//
//  ParseDynamoKievUa.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 30.07.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ArticleContent;
@class HTMLNode;
@class MatchScoreInfo;

@interface ParseSiteContent : NSObject
+(NSMutableArray *)parseNewslinePage:(NSString *)page;
+(void)parseArticlePage:(NSString *)page savingTo:(ArticleContent *)article;
+(NSMutableArray *)parseBlogsPage:(NSString *)page;
+(NSMutableArray *)parseMatchCenterFile:(NSString *)page;
+(NSMutableArray *)parseLegueTablePage:(NSString *)page;
+(NSMutableArray *)parseLegueSchedulePage:(NSString *)page;
+(NSMutableArray *)parseLegueScorersPage:(NSString *)page;
+(MatchScoreInfo *)parseCentralMatchPage:(NSString *)page;
+(NSMutableDictionary *)parseTableAndCalendarPage:(NSString *)page;
+(void)parseMatchDetailInfoPage:(NSString *)page savingTo:(MatchScoreInfo *)match;
+(void)parseCommentsPage:(NSString *)page savingTo:(ArticleContent *)article;
+(NSMutableArray *)parsePlayoffsPage:(NSString *)page;
@end
