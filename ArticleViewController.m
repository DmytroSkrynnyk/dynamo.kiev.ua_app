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

@implementation ArticleViewController

-(instancetype)initWithArticle:(id)article{
    self = [super init];
    if (self) {
        self.content = article;
    }
    return self;
}
- (IBAction)manualUpdateUI:(id)sender {
    [self updateUI];
}

-(void)updateUI{
    _titlelabel.text = _content.title;
    if (_content.articleType == BLOGS_TYPE || _content.articleType == BLOGS_OTHER_TYPE) {
        _summaryLabel.text = _content.userName;
    } else {
        _summaryLabel.text = _content.summary;
    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"dd.MM.yy hh:mm"];
    _dateLabel.text = [dateFormat stringFromDate:_content.publishedDate];
    _mainImage.image = _content.mainImage;
    _body.attributedText = _content.attributedContent;
    _ID.text = [NSString stringWithFormat:@"%lu", (unsigned long)_content.ID];
//    [self.view setNeedsDisplay];
}

-(void)setContent:(ArticleContent *)content{
    _content = content;
    [self updateUI];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self hideUI:YES];
    [_downloadingIndicator startAnimating];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showContent) name:@"downloadingSynchronization" object:nil];
}

-(void)showContent{
    [_downloadingIndicator stopAnimating];
    _downloadingIndicator.hidden = YES;
    [self updateUI];
    [self hideUI:NO];
}

-(void)hideUI:(BOOL)show{
    _titlelabel.hidden = show;
    _summaryLabel.hidden = show;
    _dateLabel.hidden = show;
    _mainImage.hidden = show;
    _body.hidden = show;
    _ID.hidden = show;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"CommentsView"]) {
        if ([segue.destinationViewController isKindOfClass:[CommentsViewController class]]) {
            CommentsViewController *cvc = (CommentsViewController *)segue.destinationViewController;
            
            cvc.articleToShow = _content;
            
            [cvc prepareContent];
            
        }
    }
}
@end
