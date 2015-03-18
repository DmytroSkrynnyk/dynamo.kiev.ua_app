//
//  articleContentElement.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 22.02.15.
//  Copyright (c) 2015 AlPono.inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimpleContentElement : NSObject
@property (strong, nonatomic) NSString *elementContent;
@property (nonatomic) NSInteger type; // 0 - text, 1 - article source, 2 - image, 3 - video, 4 - quiz
@end