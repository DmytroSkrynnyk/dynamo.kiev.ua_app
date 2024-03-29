//
//  BlogsViewController.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 04.09.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import "BlogsViewController.h"
#import "BlogsTableViewCell.h"
#import "LoadingTableViewCell.h"
#import "NewsViewController.h"
#import "ContentController.h"
#import "ArticleContent.h"

@interface BlogsViewController ()

@end

@implementation BlogsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _footballBlogsContent = [[ContentController alloc] initWithType:BLOGS_TYPE];
    self.content = _footballBlogsContent;
    [_footballBlogsContent loadNextPageUsingType:DOWNLOAD_TO_BOTTOM];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI) name:@"infoPrepared" object:nil];
}

- (IBAction)changeContentType:(UISegmentedControl *)sender {
    if (_blogsTypeSwitcher.selectedSegmentIndex == 0) {
        self.content = _footballBlogsContent;
    } else {
        self.content = self.otherBlogsContent;
    }
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row + 1 == self.content.articles.count) {
        [self.content loadNextPageUsingType:DOWNLOAD_TO_BOTTOM];
    }
    if (indexPath.row == [self.content.articles count]) {
        LoadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
        cell.userInteractionEnabled = NO;
        [cell.activity startAnimating];
        return cell;
    } else{
        BlogsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BlogsCell"];
        ArticleContent *temp = [self.content.articles objectAtIndex:indexPath.row];
        if (temp) {
            cell.title.text = temp.title;
            NSDate *pubDate = temp.publishedDate;
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
            [dateFormat setDateFormat:@"dd.MM.yy HH:mm"];
            cell.date.text = [dateFormat stringFromDate:pubDate];
            cell.author.text = temp.userName;
            if (temp.commentsCount != 0) {
                cell.commentsCounterBackground.hidden = NO;
                cell.commentsCounter.hidden = NO;
                cell.commentsCounter.text = [NSString stringWithFormat:@"%ld", (long)temp.commentsCount];
                cell.commentsIconPosition.constant = 8;
            } else {
                cell.commentsCounterBackground.hidden = YES;
                cell.commentsCounter.hidden = YES;
                cell.commentsIconPosition.constant = -22;
            }
        }
        return cell;
    }
}

-(ContentController *)otherBlogsContent{
    if (!_otherBlogsContent) {
        _otherBlogsContent = [[ContentController alloc] initWithType:BLOGS_OTHER_TYPE];
        [_otherBlogsContent loadNextPageUsingType:DOWNLOAD_TO_BOTTOM];
    }
    return _otherBlogsContent;
}

@end
