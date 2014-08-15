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
#import "ArticleContent.h"

@implementation ContentController

#define NEWS 0
#define ARTICLES 1
#define SINGLE_ARTICLE 2

-(void)downloadAndParsePageWithURL:(NSString *)pageURL
                       usingParser:(NSUInteger)numberOfParser
                          savingTo:(ArticleContent *)articleToDownload{
    
    [[InfoDownloader createDownloaderWithBaseURL:[NSURL URLWithString:@"http://dynamo.kiev.ua"]] loadPageWithURL:pageURL gotResponce:^(id responseObject) {
        NSString *pageSourceCode = [[NSString alloc] initWithData:(NSData *)responseObject encoding:NSUTF8StringEncoding];
        switch (numberOfParser) {
            case NEWS:{
                [self.news addObjectsFromArray:[ParseDynamoKievUa parseDynamoNewslinePage:pageSourceCode]];
                for (NSInteger i = 0; i < _news.count; i++) {
                    ArticleContent *article = _news[i];
                    [self downLoadImageForArticle:article];
                }
            }
                break;
            case ARTICLES:
                [self.articles addObjectsFromArray:[ParseDynamoKievUa parseDynamoNewslinePage:pageSourceCode]];
                for (NSInteger i = 0; i < _articles.count; i++) {
                    ArticleContent *article = _articles[i];
                    [self downLoadImageForArticle:article];
                }
                break;
            case SINGLE_ARTICLE:
                [ParseDynamoKievUa parseDynamoArticlePage:pageSourceCode savingTo:articleToDownload];
                
                break;
                
            default:
                break;
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

- (void)downLoadImageForArticle:(ArticleContent *)article{
    NSURL *baseURL = [NSURL URLWithString:@"http://dynamo.kiev.ua"];
    NSString *concreteURL = [NSString stringWithFormat:@"http://dynamo.kiev.ua%@", article.mainImageLink];
    [[InfoDownloader createDownloaderWithBaseURL:baseURL] downloadImageByURL:concreteURL gotResponce:^(id responseObject) {
        article.mainImage = responseObject;
    } failure:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

- (void)loadNewslinePageWithNumber:(NSUInteger)number{
    NSString *path = [NSString stringWithFormat:@"/news/?page=%i", number];
    [self downloadAndParsePageWithURL:path usingParser:NEWS savingTo:nil];
    _nextNewsPageToLoad++;
}

- (void)loadArticlesPageWithNumber:(NSUInteger)number{
    NSString *path = [NSString stringWithFormat:@"/articles/?page=%i", number];
    [self downloadAndParsePageWithURL:path usingParser:ARTICLES savingTo:nil];
    _nextArticlesPageToLoad++;
}

- (void)loadSourceCodeOfArticle:(ArticleContent *)article{
    NSString *path;
    if (article.articleType == NEWS) {
        path = [NSString stringWithFormat:@"/news/%i.html", article.ID];
    } else if (article.articleType == ARTICLES){
        path = [NSString stringWithFormat:@"/articles/%i.html", article.ID];
    }
    [self downloadAndParsePageWithURL:path usingParser:SINGLE_ARTICLE savingTo:article];
}


- (void)prepareContent{
    [self loadArticlesPageWithNumber:self.nextArticlesPageToLoad];
    [self loadNewslinePageWithNumber:self.nextNewsPageToLoad];
}

-(NSUInteger)nextNewsPageToLoad{
    if (!_nextNewsPageToLoad) {
        _nextNewsPageToLoad = 1;
    }
    return _nextNewsPageToLoad;
}

-(NSUInteger)nextArticlesPageToLoad{
    if (!_nextArticlesPageToLoad) {
        _nextArticlesPageToLoad = 1;
    }
    return _nextArticlesPageToLoad;
}

-(ArticleContent *)article{
    if (!_article) {
        _article = [[ArticleContent alloc] init];
    }
    return _article;
}

-(NSMutableArray *)news{
    if (!_news) {
        _news = [[NSMutableArray alloc] init];
    }
    return _news;
}

-(NSMutableArray *)articles{
    if (!_articles) {
        _articles = [[NSMutableArray alloc] init];
    }
    return _articles;
}
@end
