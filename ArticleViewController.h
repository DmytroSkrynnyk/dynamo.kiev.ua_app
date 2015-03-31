//
//  ArticleViewController.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 21.07.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ArticleContent;

@interface ArticleViewController : UIViewController
@property (strong, nonatomic) ArticleContent *article;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *downloadingIndicator;
@property (weak, nonatomic) IBOutlet UIView *bottomBarView;
@property (weak, nonatomic) IBOutlet UIButton *commentsButton;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;

-(instancetype)initWithArticle:(ArticleContent *)art;

@end
