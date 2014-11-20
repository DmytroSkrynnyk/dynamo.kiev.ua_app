//
//  ContentController.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 05.08.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import "ContentController.h"
#import "InfoDownloader.h"
#import "ParseDynamoKievUa.h"
#import "AppDelegate.h"
#import "MatchScoreInfo.h"
#import <AFNetworking.h>
@implementation ContentController

-(instancetype)initWithType:(NSInteger)type{
    self = [super init];
    if (self) {
        _contentType = type;
        _articles = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

+ (void)downLoadImageForArticle:(ArticleContent *)article{
    NSURL *baseURL = [NSURL URLWithString:@"http://dynamo.kiev.ua"];
    NSString *concreteURL = [NSString stringWithFormat:@"http://dynamo.kiev.ua%@", article.mainImageLink];
    [[InfoDownloader createDownloaderWithBaseURL:baseURL] downloadImageByURL:concreteURL gotResponce:^(id responseObject) {
        article.mainImage = responseObject;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateVisibles" object:nil];
    } failure:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

+ (void)downLoadImageForTeam:(TeamResults *)results{ //not ready
    NSURL *baseURL = [NSURL URLWithString:@"http://dynamo.kiev.ua"];
    NSString *concreteURL = [NSString stringWithFormat:@"http://dynamo.kiev.ua%@", results.imageLink];
    [[InfoDownloader createDownloaderWithBaseURL:baseURL] downloadImageByURL:concreteURL gotResponce:^(id responseObject) {
        results.image = responseObject;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateVisibles" object:nil];
    } failure:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

- (BOOL)loadNextPageUsingType:(NSInteger)type{
    BOOL succsess = YES;
    if ([self isInternetConnectionReachable]) {
        [self downloadAndParsePageWithURL:[self createPathUsingType:type] usingDownloadType:type];
    } else{
        succsess = NO;
    }
    return succsess;
}

-(NSString *)createPathUsingType:(NSInteger)downloadType{
    NSInteger pageToLoad;
    if (downloadType == DOWNLOAD_TO_TOP) {
        pageToLoad = self.nextRefreshingPage++;
    } else {
        pageToLoad = self.nextPageToLoad++;
    }
    NSString *path;
    if (_contentType == NEWS_TYPE) {
        path = [NSString stringWithFormat:@"/news/?page=%lu", (unsigned long)pageToLoad];
    } else if(_contentType == ARTICLE_TYPE){
        path = [NSString stringWithFormat:@"/articles/?page=%lu", (unsigned long)pageToLoad];
    } else if(_contentType == BLOGS_TYPE){
        path = [NSString stringWithFormat:@"/blog/?view=details&tab=football&page=%lu", (unsigned long)pageToLoad];
    } else {
        path = [NSString stringWithFormat:@"/blog/?view=details&tab=other&page=%lu", (unsigned long)pageToLoad];
    }
    return path;
}

-(void)downloadAndParsePageWithURL:(NSString *)pageURL
                          savingTo:(ArticleContent *)articleToDownload{
    
    [[InfoDownloader createDownloaderWithBaseURL:[NSURL URLWithString:@"http://dynamo.kiev.ua"]] loadPageWithURL:pageURL gotResponce:^(id responseObject) {
        NSString *pageSourceCode = [[NSString alloc] initWithData:(NSData *)responseObject encoding:NSUTF8StringEncoding];
        if (_contentType == NEWS_TYPE || _contentType == ARTICLE_TYPE) {
            [ParseDynamoKievUa parseDynamoArticlePage:pageSourceCode savingTo:articleToDownload];
        } else {
            [ParseDynamoKievUa parseBlogArticlePage:pageSourceCode savingTo:articleToDownload];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error.description);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadFailure" object:nil];
    }];
}

-(void)downloadAndParsePageWithURL:(NSString *)pageURL usingDownloadType:(NSInteger)type{
    [[InfoDownloader createDownloaderWithBaseURL:[NSURL URLWithString:@"http://dynamo.kiev.ua"]] loadPageWithURL:pageURL gotResponce:^(id responseObject) {
        NSString *pageSourceCode = [[NSString alloc] initWithData:(NSData *)responseObject encoding:NSUTF8StringEncoding];
        NSMutableArray *downloadedArticles;
        if (_contentType == NEWS_TYPE || _contentType == ARTICLE_TYPE) {
            downloadedArticles = [ParseDynamoKievUa parseDynamoNewslinePage:pageSourceCode];
        } else {
            downloadedArticles = [ParseDynamoKievUa parseBlogsPage:pageSourceCode];
        }
        BOOL refresh = YES;
        if (type == DOWNLOAD_TO_BOTTOM) {
            refresh = NO;
        }
        [self addDownloadedArticles:downloadedArticles withRefresh:refresh];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"infoPrepared" object:self];
    }  failure:^(NSError *error) {
        NSLog(@"%@", error.description);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadFailure" object:nil];
        NSLog(@"download failed");
    }];
}

+(void)dowloadAndParseMatchCenterPageWithCompletionHandler:(void(^)(NSMutableArray *))completion error:(void (^)(NSError *))error{
    [[InfoDownloader createDownloaderWithBaseURL:[NSURL URLWithString:@"http://dynamo.kiev.ua"]] loadPageWithURL:@"/comp/match-center.js" gotResponce:^(id responseObject) {
        NSString *pageSourceCode = [[NSString alloc] initWithData:(NSData *)responseObject encoding:NSUTF8StringEncoding];
        pageSourceCode = [NSString stringWithFormat:@"<html><body>%@</body></html>", pageSourceCode];
        NSMutableArray *tournaments = [ParseDynamoKievUa parseMatchCenterFile:pageSourceCode];
        completion(tournaments);
    }  failure:^(NSError *downloadError) {
        error(downloadError);
        NSLog(@"download failed");
    }];
}

+(void)dowloadAndParseTableForLegue:(NSString *)legue completionHandler:(void(^)(NSMutableArray *))completion error:(void (^)(NSError *))error{
    [[InfoDownloader createDownloaderWithBaseURL:[NSURL URLWithString:@"http://dynamo.kiev.ua"]] loadPageWithURL:[NSString stringWithFormat:@"comp/%@table/", legue] gotResponce:^(id responseObject) {
        
        NSString *pageSourceCode = [[NSString alloc] initWithData:(NSData *)responseObject encoding:NSUTF8StringEncoding];
        NSMutableArray *teamResults = [ParseDynamoKievUa parseLegueTablePage:pageSourceCode];
        completion(teamResults);
    }  failure:^(NSError *downloadError) {
        error(downloadError);
        NSLog(@"download failed");
    }];
}

+(void)dowloadAndParseScheduleForLegue:(NSString *)legue completionHandler:(void(^)(NSMutableArray *))completion error:(void (^)(NSError *))error{
    [[InfoDownloader createDownloaderWithBaseURL:[NSURL URLWithString:@"http://dynamo.kiev.ua"]] loadPageWithURL:[NSString stringWithFormat:@"comp/%@/matches/", legue] gotResponce:^(id responseObject) {
        NSString *pageSourceCode = [[NSString alloc] initWithData:(NSData *)responseObject encoding:NSUTF8StringEncoding];
        NSMutableArray *tours = [ParseDynamoKievUa parseLegueSchedulePage:pageSourceCode];
        completion(tours);
        
    }  failure:^(NSError *downloadError) {
        error(downloadError);
        NSLog(@"download failed");
    }];
    
}

+(void)dowloadAndParseScorersForLegue:(NSString *)legue completionHandler:(void(^)(NSMutableArray *))completion error:(void (^)(NSError *))error{ //not ready
    [[InfoDownloader createDownloaderWithBaseURL:[NSURL URLWithString:@"http://dynamo.kiev.ua"]] loadPageWithURL:[NSString stringWithFormat:@"comp/%@/bombardiers/", legue] gotResponce:^(id responseObject) {
        NSString *pageSourceCode = [[NSString alloc] initWithData:(NSData *)responseObject encoding:NSUTF8StringEncoding];
        NSMutableArray *tours = [ParseDynamoKievUa parseLegueScorersPage:pageSourceCode];
        completion(tours);
    }  failure:^(NSError *downloadError) {
        error(downloadError);
        NSLog(@"download failed");
    }];
}

+(void)dowloadAndParseTableAndCalendarForLeague:(NSString *)league completionHandler:(void(^)(NSMutableDictionary *))completion error:(void (^)(NSError *))error{
    [[InfoDownloader createDownloaderWithBaseURL:[NSURL URLWithString:@"http://dynamo.kiev.ua"]] loadPageWithURL:[NSString stringWithFormat:@"comp/%@/matches/", league] gotResponce:^(id responseObject) {
        NSString *pageSourceCode = [[NSString alloc] initWithData:(NSData *)responseObject encoding:NSUTF8StringEncoding];
        NSMutableDictionary *tableAndCalendar = [ParseDynamoKievUa parseTableAndCalendarPage:pageSourceCode];
        completion(tableAndCalendar);
    }  failure:^(NSError *downloadError) {
        error(downloadError);
        NSLog(@"download failed");
    }];
}

+(void)dowloadAndParseMainPageWithCompletionHandler:(void(^)(MatchScoreInfo *))completion error:(void (^)(NSError *))error{
    [[InfoDownloader createDownloaderWithBaseURL:[NSURL URLWithString:@"http://dynamo.kiev.ua"]] loadPageWithURL:@"" gotResponce:^(id responseObject) {
        NSString *pageSourceCode = [[NSString alloc] initWithData:(NSData *)responseObject encoding:NSUTF8StringEncoding];
        MatchScoreInfo *centralMatch = [ParseDynamoKievUa parseCentralMatchPage:pageSourceCode];
        completion(centralMatch);
    }  failure:^(NSError *downloadError) {
        error(downloadError);
        NSLog(@"download failed");
    }];
}


-(void)addDownloadedArticles:(NSMutableArray *)downloadedArticles withRefresh:(BOOL)refresh{
    if (self.articles.count < 10) {
        [_articles addObjectsFromArray:downloadedArticles];
    } else {
        NSInteger repeating = 0;
        for (NSInteger i = downloadedArticles.count-1; i >= 0; i--) {
            ArticleContent *article = downloadedArticles[i];
            for (ArticleContent *addedArticle in _articles) {
                if (article.ID == addedArticle.ID) {
                    [downloadedArticles removeObjectAtIndex:i];
                    repeating++;
                }
            }
        }
        [_articles addObjectsFromArray:downloadedArticles];
        if (refresh) {
            if (repeating == 0) {
                [self continueRefreshing:YES];
            } else{
                [self continueRefreshing:NO];
            }
        }
    }
    _articles = [NSMutableArray arrayWithArray:[ContentController sortArticlesByPublishedDate:_articles]];
}

-(void)continueRefreshing:(BOOL)refreshing{
    if (refreshing) {
        [self loadNextPageUsingType:DOWNLOAD_TO_TOP];
    } else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopRefresh" object:nil];
        _nextRefreshingPage = 1;
    }
}

-(BOOL)refreshContent{
    BOOL succsess = YES;
    if ([self isInternetConnectionReachable]) {
        [self downloadAndParsePageWithURL:[self createPathUsingType:DOWNLOAD_TO_TOP] usingDownloadType:DOWNLOAD_TO_TOP];
    } else{
        succsess = NO;
    }
    return succsess;
}


-(void)loadSourceCodeOfArticle:(ArticleContent *)article{
    NSString *path;
    if (article.articleType == NEWS_TYPE) {
        path = [NSString stringWithFormat:@"/news/%lu.html", (unsigned long)article.ID];
    } else if (article.articleType == ARTICLE_TYPE){
        path = [NSString stringWithFormat:@"/articles/%lu.html", (unsigned long)article.ID];
    } else if (article.articleType == BLOGS_TYPE){
        path = [NSString stringWithFormat:@"/blog/%lu.html", (unsigned long)article.ID];
    }
    [self downloadAndParsePageWithURL:path savingTo:article];
}

-(BOOL)isInternetConnectionReachable{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
    }];
//    AFStringFromNetworkReachabilityStatus(AFNetworkReachabilityStatus status)
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return appDelegate.netStatus != NotReachable;
}

+(NSArray *)sortArticlesByPublishedDate:(NSMutableArray *)articles{
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"publishedDate" ascending:NO];
    NSArray *sorted = [articles sortedArrayUsingDescriptors:@[sd]];
    return sorted;
}

-(NSMutableArray *)articles{
    if (!_articles) {
        _articles = [[NSMutableArray alloc] init];
    }
    return _articles;
}

-(NSUInteger)nextPageToLoad{
    if (!_nextPageToLoad) {
        _nextPageToLoad = 1;
    }
    return _nextPageToLoad;
}

-(NSUInteger)nextRefreshingPage{
    if (!_nextRefreshingPage) {
        _nextRefreshingPage = 1;
    }
    return _nextRefreshingPage;
}

@end
