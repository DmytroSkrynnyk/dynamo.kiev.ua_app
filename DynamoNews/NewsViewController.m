//
//  ViewController.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 19.07.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import "NewsViewController.h"
#import "NewsCell.h"
#import "LoadingTableViewCell.h"
#import "ArticleViewController.h"

@interface NewsViewController ()
@end

@implementation NewsViewController

-(void)updateUI{
//    NSMutableArray *temp = [[NSMutableArray alloc] init];
//    for (int i = 0; i < 10; i ++) {
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_content.articles.count - i - 1 inSection:0];
//        [temp addObject:indexPath];
//    }
//    [_table insertRowsAtIndexPaths:temp withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row + 1 == [self.content.articles count]) {
        [_content loadNextPageUsingType:DOWNLOAD_TO_BOTTOM];
    }
    if (indexPath.row == [self.content.articles count]) {
        LoadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
        [cell.activity startAnimating];
        cell.userInteractionEnabled = NO;
        return cell;
    } else{
        NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsCell"];
        ArticleContent *temp = [_content.articles objectAtIndex:indexPath.row];
        if (temp) {
            cell.title.text = temp.title;
            NSDate *pubDate = temp.publishedDate;
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
            [dateFormat setDateFormat:@"dd.MM.yy HH:mm"];
            cell.publishedDate.text = [dateFormat stringFromDate:pubDate];
            cell.articleImage.image = temp.mainImage;
        }
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.content.articles count] + 1;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ArticleView"]) {
        if ([segue.destinationViewController isKindOfClass:[ArticleViewController class]]) {
            ArticleViewController *avc = (ArticleViewController *)segue.destinationViewController;
            NSIndexPath *indexPath = (NSIndexPath *)sender;
            avc.view.hidden = NO;
            [avc setContent:[_content.articles objectAtIndex:indexPath.row]];
            if (avc.content.isLoaded == NO) {
                [_content loadSourceCodeOfArticle:avc.content];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadingSynchronization" object:nil];
            }
        }
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI) name:@"infoPrepared" object:nil];
    [self.refreshControl addTarget:self action:@selector(reloadContent) forControlEvents:UIControlEventValueChanged];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noConnection) name:@"noConnection" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noConnection) name:@"downloadFailure" object:nil];
    if ([self isMemberOfClass:[NewsViewController class]]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVisibles) name:@"updateVisibles" object:nil];
    }
}

- (void)updateVisibles{
    __block NewsCell *cell;
    for (NSIndexPath *path in self.tableView.indexPathsForVisibleRows) {
        if (path.row < _content.articles.count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ArticleContent *art = [_content.articles objectAtIndex:path.row];
                cell = (NewsCell *)[self.tableView cellForRowAtIndexPath:path];
                for (UIView *cellView in cell.contentView.subviews) {
                    if ([cellView isMemberOfClass:[UIImageView class]]) {
                        UIImageView *image = (UIImageView *)cellView;
                        image.image = art.mainImage;
                    }
                }
            });
        }
    }
}

- (void)stopRefresh {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"stopRefresh" object:nil];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)reloadContent {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopRefresh) name:@"stopRefresh" object:nil];
    [self.content refreshContent];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"ArticleView" sender:indexPath];
}

-(void)noConnection{
    
}
@end
