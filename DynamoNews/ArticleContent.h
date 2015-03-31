//
//  ArticleContent.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 06.08.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommentsForArticle.h"

@interface ArticleContent : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSDate *publishedDate;
@property (strong, nonatomic) NSMutableArray *content;
@property (nonatomic) NSUInteger ID;
@property (nonatomic) NSUInteger articleType;
@property (nonatomic) BOOL isLoaded;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) UIImage *mainImage;
@property (strong, nonatomic) NSString *mainImageLink;
@property (strong, nonatomic) CommentsForArticle *commentsContainer;
@property (nonatomic) NSInteger commentsCount;

@end
