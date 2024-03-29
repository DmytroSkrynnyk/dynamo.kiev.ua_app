//
//  ContentController.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 05.08.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ArticleContent;
@class TeamResults;
@class MatchScoreInfo;

@interface ContentController : NSObject
@property (strong, nonatomic) NSMutableArray *articles;
@property (strong, nonatomic) NSMutableDictionary *matchCenter;
@property (nonatomic) NSUInteger nextPageToLoad;
@property (nonatomic) NSUInteger nextRefreshingPage;
@property (nonatomic) NSUInteger contentType;

-(instancetype)initWithType:(NSInteger)type;
-(BOOL)loadNextPageUsingType:(NSInteger)type;
-(void)loadSourceCodeOfArticle:(ArticleContent *)article;
-(BOOL)refreshContent;
+(void)downLoadImageForArticle:(ArticleContent *)article;
+(void)dowloadAndParseMatchCenterPageWithCompletionHandler:(void(^)(NSMutableArray *))completion
                                                     error:(void (^)(NSError *))error;
+(void)dowloadAndParseTableForLegue:(NSString *)legue
                  completionHandler:(void(^)(NSMutableArray *))completion
                              error:(void (^)(NSError *))error;

+(void)dowloadAndParseScheduleForLegue:(NSString *)legue
                     completionHandler:(void(^)(NSMutableArray *))completion
                                 error:(void (^)(NSError *))error;

+(void)dowloadAndParseScorersForLegue:(NSString *)legue
                    completionHandler:(void(^)(NSMutableArray *))completion
                                error:(void (^)(NSError *))error;

+(void)dowloadAndParseMainPageWithCompletionHandler:(void(^)(MatchScoreInfo *))completion
                                              error:(void (^)(NSError *))error;

+(void)dowloadAndParseTableAndCalendarForLeague:(NSString *)league
                              completionHandler:(void(^)(NSMutableDictionary *))completion
                                          error:(void (^)(NSError *))error;

+(void)downloadAndParsePlayoffsForTournament:(NSInteger)tournament
                           completionHandler:(void(^)(NSMutableArray *))completion
                                       error:(void (^)(NSError *))error;

+(void)dowloadAndParseTableAndCalendarForEuroWithcompletionHandler:(void(^)(NSMutableDictionary *))completion
                                                             error:(void (^)(NSError *))error;

+(void)downloadAndParseDetailsForMatch:(MatchScoreInfo *)match;

+(void)dowloadAndParseCommentsForArticle:(ArticleContent *)article;

@end
