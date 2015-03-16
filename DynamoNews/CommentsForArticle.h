//
//  CommentsForArticle.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 17.02.15.
//  Copyright (c) 2015 AlPono.inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentsForArticle : NSObject

@property (strong, nonatomic) NSMutableArray *comments;
@property (nonatomic) BOOL isAllCommentsLoaded;
@property (strong, nonatomic) CommentsForArticle *bestComment;

-(NSString *)nextRequestParameter;

@end
