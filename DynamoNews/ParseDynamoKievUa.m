//
//  ParseDynamoKievUa.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 30.07.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import "ParseDynamoKievUa.h"
#import "HTMLParser.h"
#import "HTMLNode.h"
#import "NSString+DeleteSpecialCharacters.h"
#import "ArticleContent.h"

#define NEWS_TYPE 0
#define ARTICLE_TYPE 1

@implementation ParseDynamoKievUa

+ (NSMutableArray *)parseDynamoNewslinePage:(NSString *)page{
    //local page
    if (!page) {
        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"dynamo_articles" ofType:@"html"];
        NSError *errorReading;
        page = [NSString stringWithContentsOfFile:filePath
                                                          encoding:NSUTF8StringEncoding
                                                             error:&errorReading];
    }
    //-local page
    
    NSError *error = nil;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
    }
    HTMLNode *bodyNode = [parser body];
    HTMLNode *divIdPosts = [bodyNode findChildWithAttribute:@"id" matchingName:@"posts" allowPartial:NO];
    NSMutableArray *postsBetweenLiTags = [NSMutableArray arrayWithArray:[divIdPosts findChildTags:@"li"]];
    NSMutableArray *articles = [[NSMutableArray alloc] init];
    NSString *childNodeContent = [[NSString alloc] init];
    for (HTMLNode *liNode in postsBetweenLiTags) {
        if ([liNode findChildWithAttribute:@"class" matchingName:@"post-head" allowPartial:NO]) {
            NSMutableArray *children = [NSMutableArray arrayWithArray:[liNode children]];
            ArticleContent *article = [[ArticleContent alloc] init];
            for (NSInteger i = children.count-1; i >= 0; i--){
                if ([[children[i] tagName] isEqualToString:@"text"]) {
                    [children removeObjectAtIndex:i];
                }
            }
            for (HTMLNode *node in children) {
                childNodeContent = [[node findChildTag:@"a"] getAttributeNamed:@"href"];
                if (childNodeContent) {
                    if ([childNodeContent rangeOfString:@"#"].location == NSNotFound) {
                        if ([childNodeContent rangeOfString:@"news"].location != NSNotFound) {
                            article.articleType = NEWS_TYPE;
                        } else{
                            article.articleType = ARTICLE_TYPE;
                        }
                        
                        NSRange idRange = NSMakeRange(childNodeContent.length - 11, 6);
                        article.ID = [[childNodeContent substringWithRange:idRange] integerValue];
                    }
                }
                childNodeContent = [[node findChildTag:@"i"] contents];
                if (childNodeContent) {
                    article.title = childNodeContent;
                }
                childNodeContent = [[node findChildTag:@"img"] getAttributeNamed:@"src"];
                if (childNodeContent) {
                    article.mainImageLink = childNodeContent;
                }
                childNodeContent = [[node findChildTag:@"small"] contents];
                if (childNodeContent) {
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    [dateFormat setDateFormat:@"dd.MM.yyyy, HH:mm"];
                    NSDate *pubDate = [dateFormat dateFromString:childNodeContent];
                    article.publishedDate = pubDate;
                }
                HTMLNode *divContent = [[node findChildWithAttribute:@"class" matchingName:@"nodeImg" allowPartial:NO] parent];
                if (divContent) {
                    NSArray *pNodes = [divContent findChildTags:@"p"];
                    NSMutableString *articleContent = [[NSMutableString alloc] init];
                    for (HTMLNode *pNode in pNodes) {
                        if (![[pNode allContents] hasPrefix:@"Читать"]) {
                            [articleContent appendString:[pNode allContents]];
                            [articleContent appendString:@"\n"];
                        }
                    }
                    article.content = articleContent;
                }
            }
            article.isLoaded = NO;
            [articles addObject:article];
        }
    }
    return articles;
}

+ (ArticleContent *)fullParseDynamoArticlePage:(NSString *)page{
    //local page
    if (!page) {
        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"dynamo_article_page" ofType:@"html"];
        NSError *errorReading;
        page = [NSString stringWithContentsOfFile:filePath
                                                      encoding:NSUTF8StringEncoding
                                                         error:&errorReading];
    }
    //-local page
    
    NSError *error = nil;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
    }
    HTMLNode *bodyNode = [parser body];
    HTMLNode *divIdPosts = [bodyNode findChildWithAttribute:@"id" matchingName:@"posts" allowPartial:NO];
    NSArray *articleContent = [divIdPosts children];
    ArticleContent *article = [[ArticleContent alloc] init];
    NSString *childNodeContent = [[NSString alloc] init];
    for (HTMLNode *node in articleContent) {
        childNodeContent = [[node findChildTag:@"h1"] contents];
        if (childNodeContent) {
            article.title = childNodeContent;
        }
        HTMLNode *imgNode = [node findChildWithAttribute:@"itemprop" matchingName:@"image" allowPartial:NO];
        childNodeContent = [imgNode getAttributeNamed:@"src"];
        if (childNodeContent) {
            article.mainImageLink = childNodeContent;
        }
        childNodeContent = [imgNode getAttributeNamed:@"alt"];
        if (childNodeContent) {
            article.title = childNodeContent;
        }
        childNodeContent = [[node findChildWithAttribute:@"itemprop" matchingName:@"url" allowPartial:NO] contents];
        if (childNodeContent) {
            if ([childNodeContent rangeOfString:@"#"].location == NSNotFound) {
                if ([childNodeContent rangeOfString:@"news"].location != NSNotFound) {
                    article.articleType = NEWS_TYPE;
                } else{
                    article.articleType = ARTICLE_TYPE;
                }
                
                NSRange idRange = NSMakeRange(childNodeContent.length - 11, 6);
                article.ID = [[childNodeContent substringWithRange:idRange] integerValue];
            }
        }
        childNodeContent = [[node findChildWithAttribute:@"itemprop" matchingName:@"dateCreated" allowPartial:NO] contents];
        if (childNodeContent) {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
            NSDate *pubDate = [dateFormat dateFromString:childNodeContent];
            article.publishedDate = pubDate;
        }
        HTMLNode *sourceInfoNode = [node findChildOfClass:@"source"];
        HTMLNode *aNode = [sourceInfoNode findChildTag:@"a"];
        if (aNode) {
            NSString *sourceInfoURL = [aNode getAttributeNamed:@"href"];
            childNodeContent = [aNode contents];
            article.InfoSource = childNodeContent;
            article.InfoSourceURL = sourceInfoURL;
            HTMLNode *contentNode = [sourceInfoNode parent];
            NSArray *pNodes = [contentNode findChildTags:@"p"];
            NSMutableString *articleContent = [[NSMutableString alloc] init];
            for (HTMLNode *pNode in pNodes) {
                [articleContent appendString:[pNode allContents]];
                [articleContent appendString:@"\n"];
                article.content = articleContent;
            }
        }
    }
    return article;
}

+(void)parseDynamoArticlePage:(NSString *)page savingTo:(ArticleContent *)article{
    //local page
    if (!page) {
        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"dynamo_article_page" ofType:@"html"];
        NSError *errorReading;
        page = [NSString stringWithContentsOfFile:filePath
                                         encoding:NSUTF8StringEncoding
                                            error:&errorReading];
    }
    //-local page
    
    NSError *error = nil;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
    } else{
        HTMLNode *bodyNode = [parser body];
        HTMLNode *divIdPosts = [bodyNode findChildWithAttribute:@"id" matchingName:@"posts" allowPartial:NO];
        NSArray *articleContent = [divIdPosts children];
        NSString *childNodeContent = [[NSString alloc] init];
        for (HTMLNode *node in articleContent) {
            HTMLNode *sourceInfoNode = [node findChildOfClass:@"source"];
            HTMLNode *aNode = [sourceInfoNode findChildTag:@"a"];
            if (aNode) {
                NSString *sourceInfoURL = [aNode getAttributeNamed:@"href"];
                childNodeContent = [aNode contents];
                article.InfoSource = childNodeContent;
                article.InfoSourceURL = sourceInfoURL;
            }
            HTMLNode *contentNode = [[[node findChildWithAttribute:@"class" matchingName:@"nodeImg" allowPartial:NO] parent] parent];
            if (contentNode) {
                //temp
                article.rawContent = [NSString stringWithFormat:@"<html><head></head><body>%@</body></html>",[contentNode rawContents]];
                NSLog(@"%@", article.rawContent);
                //-temp
                NSArray *pNodes = [contentNode findChildTags:@"p"];
                NSMutableString *articleContent = [[NSMutableString alloc] init];
                for (NSUInteger i = 0; i < pNodes.count; i++) {
                    if (i == 0) {
                        article.summary = [pNodes[i] allContents];
                    }else{
                        [articleContent appendString:[pNodes[i] allContents]];
                        [articleContent appendString:@"\n"];
                    }
                }
                NSLog(@"");
            }

        }
        article.isLoaded = YES;
    }
}

@end
