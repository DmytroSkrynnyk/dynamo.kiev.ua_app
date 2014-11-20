//
//  ArticleViewController.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 21.07.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArticleContent.h"

@interface ArticleViewController : UIViewController
//general properties
@property (strong, nonatomic) ArticleContent *content;
@property (weak, nonatomic) IBOutlet UILabel *titlelabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextView *body;
@property (weak, nonatomic) IBOutlet UILabel *ID;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *downloadingIndicator;
//news properties
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
//blogs properties

-(instancetype)initWithArticle:(ArticleContent *)article;

@end
