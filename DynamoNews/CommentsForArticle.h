//
//  CommentsForArticle.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 17.02.15.
//  Copyright (c) 2015 AlPono.inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UserComment;

@interface CommentsForArticle : NSObject
@property (strong, nonatomic) NSMutableArray *comments;
@property (strong, nonatomic) UserComment *bestComment;
@property (nonatomic) NSInteger nextRequestCounter;
@property (nonatomic) BOOL isAllCommentsLoaded;
-(NSString *)nextRequestParameter;

@end
