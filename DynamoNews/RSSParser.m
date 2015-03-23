//
//  RSSParser.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 21.07.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import "RSSParser.h"

@interface RSSParser()
@property (nonatomic, strong, readwrite) NSMutableArray *articles;
@property (nonatomic, retain) NSString *currentElement;
@property (nonatomic, retain) NSMutableString *publishedDateString;
@property (nonatomic, retain) NSMutableString *title;
@property (nonatomic, retain) NSMutableDictionary *currentDic;
@end

@implementation RSSParser


- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"%@", parseError);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict  {
    _currentElement = elementName;
    if ([elementName isEqualToString:@"item"]) {
        _currentDic = [[NSMutableDictionary alloc] init];
    }
    if ([elementName isEqualToString:@"title"]) {
        _title = [NSMutableString string];
    }
    if ([elementName isEqualToString:@"pubDate"]) {
        _publishedDateString = [NSMutableString string];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([_currentElement isEqualToString:@"title"]) {
        [_title appendString:string];
    }
    if ([_currentElement isEqualToString:@"pubDate"]) {
        [_publishedDateString appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"description"]) {
        if (![_title isEqualToString:@"Динамо Киев от Шурика\n		"]) {
            [_articles addObject:_currentDic];
        }
        _currentDic = nil;
        _publishedDateString = nil;
        _title = nil;
    }
    if ([elementName isEqualToString:@"pubDate"]) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss ZZZ"];
        NSDate *pubDate = [dateFormat dateFromString:_publishedDateString];
        [_currentDic setObject:pubDate forKey:@"pubDate"];
    }
    if ([elementName isEqualToString:@"title"]) {
        [_title stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        [_title stringByReplacingOccurrencesOfString:@"  " withString:@" "];
        [_currentDic setObject:_title forKey:@"title"];
    }
}

-(NSMutableArray *)articles{
    if (!_articles) {
        _articles = [[NSMutableArray alloc] init];
    }
    return _articles;
}

-(void)startParsing{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"f1news" ofType:@"xml"];
    NSData *myData = [NSData dataWithContentsOfFile:filePath];
    NSXMLParser *rssParser = [[NSXMLParser alloc] initWithData:myData];
    rssParser.delegate = self;
    _articles = [[NSMutableArray alloc] init];
    [rssParser parse];
}
@end
