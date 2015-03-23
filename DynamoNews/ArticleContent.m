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

-(NSString *)description{
    NSString *description = [NSString stringWithFormat:@"\n title: %@\n date: %@\n ID: %lu\n type: %lu\n loaded:%u\n userImageLink: %@\n userName: %@\n summary: %@\n mainImageLink: %@\n infoSource: %@\n infoSourceURL: %@\n content: %@",_title, _publishedDate.description, (unsigned long)_ID, (unsigned long)_articleType, _isLoaded, _userImageLink, _userName, _summary, _mainImageLink, _infoSource, _infoSourceURL, _content];
    return description;
}

-(CommentsForArticle *)commentsContainer{
    if (!_commentsContainer) {
        _commentsContainer = [[CommentsForArticle alloc] init];
    }
    return _commentsContainer;
}
@end
