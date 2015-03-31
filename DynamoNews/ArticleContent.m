//
//  ArticleContent.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 06.08.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import "ArticleContent.h"
#import "ContentController.h"
#import "CommentsForArticle.h"

@implementation ArticleContent
-(void)setMainImageLink:(NSString *)mainImageLink{
    _mainImageLink = mainImageLink;
    [ContentController downLoadImageForArticle:self];
}

-(CommentsForArticle *)commentsContainer{
    if (!_commentsContainer) {
        _commentsContainer = [[CommentsForArticle alloc] init];
    }
    return _commentsContainer;
}
@end
