//
//  articleContentElement.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 22.02.15.
//  Copyright (c) 2015 AlPono.inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextContentElement : NSObject
@property (strong, nonatomic) NSString *textContent;
@property (nonatomic) BOOL isBold;
@property (nonatomic) BOOL isSource;
@end