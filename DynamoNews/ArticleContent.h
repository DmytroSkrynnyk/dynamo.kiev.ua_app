//
//  ArticleContent.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 06.08.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NEWS_TYPE 0
#define ARTICLE_TYPE 1

@interface ArticleContent : NSObject
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSDate *publishedDate;
@property (strong, nonatomic) NSString *summary;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) UIImage *mainImage;
@property (strong, nonatomic) NSString *mainImageLink;
@property (strong, nonatomic) NSString *InfoSource;
@property (strong, nonatomic) NSString *InfoSourceURL;
@property (nonatomic) NSUInteger ID;
@property (nonatomic) NSUInteger articleType;
@property (nonatomic) BOOL isLoaded;

@property (strong, nonatomic) NSString *rawContent;

@end
