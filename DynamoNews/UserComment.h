//
//  ArticleUserComment.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 15.02.15.
//  Copyright (c) 2015 AlPono.inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserComment : NSObject
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *userStatus;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *userLink;
@property (nonatomic) NSInteger rating;
@property (nonatomic) NSInteger level;
@end
