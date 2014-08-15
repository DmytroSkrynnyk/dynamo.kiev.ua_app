//
//  ContentController.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 05.08.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArticleContent.h"

@interface ContentController : NSObject
@property (strong, nonatomic) NSMutableArray *articles;
@property (strong, nonatomic) NSMutableArray *news;
@property (strong, nonatomic) ArticleContent *article;
@property (nonatomic) NSUInteger nextNewsPageToLoad;
@property (nonatomic) NSUInteger nextArticlesPageToLoad;

- (void)prepareContent;
- (void)loadSourceCodeOfArticle:(ArticleContent *)article;
@end
