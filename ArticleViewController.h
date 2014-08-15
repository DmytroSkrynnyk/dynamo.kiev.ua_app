//
//  ArticleViewController.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 21.07.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *titlelabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@property (weak, nonatomic) IBOutlet UITextView *body;
@property (weak, nonatomic) IBOutlet UIWebView *testWebView;
@end
