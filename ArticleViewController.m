//
//  ArticleViewController.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 21.07.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import "ArticleViewController.h"
#import "ArticleContent.h"
#import "CommentsViewController.h"
#import "TextContentElement.h"
#import "ImageArticleElement.h"
#import "VideoArticleElement.h"

@implementation ArticleViewController

-(instancetype)initWithArticle:(id)article{
    self = [super init];
    if (self) {
        self.article = article;
    }
    return self;
}
- (IBAction)test:(id)sender {
    
}

-(void)viewDidLoad{
    [super viewDidLoad];
    if (_article.isLoaded == NO) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showContent) name:@"downloadingSynchronization" object:nil];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    if (_article.isLoaded) {
        [self showContent];
        if (_article.commentsCount > 0) {
            _commentsButton.titleLabel.text = [NSString stringWithFormat:@"Комментариев: %ld", (long)_article.commentsCount];
            _bottomBarView.hidden = NO;
        }
    }
}

-(void)showContent{
    [_downloadingIndicator stopAnimating];
    if (_article.commentsCount > 0) {
        _commentsButton.titleLabel.text = [NSString stringWithFormat:@"Комментариев: %ld", (long)_article.commentsCount];
        _bottomBarView.hidden = NO;
    }
    _contentTextView.text = [NSString stringWithFormat:@"%@\n",_article.title];
    for (id contentElement in _article.content) {
        if ([contentElement isMemberOfClass:[TextContentElement class]]) {
            TextContentElement *textElement = (TextContentElement *)contentElement;
            NSString *content = _contentTextView.text;
            content = [NSString stringWithFormat:@"%@\n%@", content, textElement.textContent];
            _contentTextView.text = content;
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"CommentsView"]) {
        if ([segue.destinationViewController isKindOfClass:[CommentsViewController class]]) {
            CommentsViewController *cvc = (CommentsViewController *)segue.destinationViewController;
            cvc.articleToShow = _article;
            if(!_article.commentsContainer.comments.count){
                [cvc prepareContent];
            }
        }
    }
}
@end
