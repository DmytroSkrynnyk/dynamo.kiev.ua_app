//
//  ViewController.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 19.07.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import "ViewController.h"
#import "RSSParser.h"
#import "CustomCell.h"
#import "ArticleViewController.h"
#import "ParseDynamoKievUa.h"
#import "InfoDownloader.h"
#import "ContentController.h"

@interface ViewController () {

}
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) NSMutableArray *content;
@property (strong, nonatomic) ContentController *con;

@end

@implementation ViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_content count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomizedCell"];
    ArticleContent *temp = [_content objectAtIndex:indexPath.row];
    if (temp) {
        cell.title.text = temp.title;
        NSDate *pubDate = temp.publishedDate;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
        [dateFormat setDateFormat:@"dd.MM.yy hh:mm"];
        cell.publishedDate.text = [dateFormat stringFromDate:pubDate];
        cell.articleImage.image = temp.mainImage;
    }
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ArticleView"]) {
        if ([segue.destinationViewController isKindOfClass:[ArticleViewController class]]) {
            ArticleViewController *avc = (ArticleViewController *)segue.destinationViewController;
            avc.view.hidden = NO;
            NSIndexPath *indexPath = [_table indexPathForCell:sender];
            ArticleContent *article = [_content objectAtIndex:indexPath.row];
            [_con loadSourceCodeOfArticle:article];
            avc.titlelabel.text = article.title;
            NSDate *publishedDate = article.publishedDate;
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
            [dateFormat setDateFormat:@"dd.MM.yy hh:mm"];
            avc.dateLabel.text = [dateFormat stringFromDate:publishedDate];
            avc.summaryLabel.text = article.summary;
            avc.mainImage.image = article.mainImage;
            avc.body.text = article.content;
            [avc.testWebView loadHTMLString:article.rawContent baseURL:nil];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}
- (IBAction)reloadImage:(id)sender {
    [self.content addObjectsFromArray:_con.news];
    [self.content addObjectsFromArray:_con.articles];
    [_table reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_table setDelegate:self];
    [_table setDataSource:self];
    _con = [[ContentController alloc] init];
    [_con prepareContent];
}

-(NSMutableArray *)content{
    if (!_content) {
        _content = [[NSMutableArray alloc] init];
    }
    return _content;
}
@end
