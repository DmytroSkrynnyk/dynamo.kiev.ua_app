//
//  RSSParser.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 21.07.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSSParser : NSObject <NSXMLParserDelegate>
@property (strong, nonatomic, readonly) NSMutableArray *articles;

-(void)startParsing;

@end
