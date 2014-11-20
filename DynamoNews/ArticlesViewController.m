//
//  ArticlesViewController.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 31.08.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import "ArticlesViewController.h"
#import "ArticleViewController.h"
#import "ArticlesTableViewCell.h"
#import "LoadingTableViewCell.h"

@interface ArticlesViewController ()


@end

@implementation ArticlesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.content = [[ContentController alloc] initWithType:ARTICLE_TYPE];
    [self.content loadNextPageUsingType:DOWNLOAD_TO_BOTTOM];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI) name:@"infoPrepared" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVisibles) name:@"updateVisibles" object:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row + 1 == [self.content.articles count]) {
        [self.content loadNextPageUsingType:DOWNLOAD_TO_BOTTOM];
    }
    
    if (indexPath.row == [self.content.articles count]) {
        LoadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
        [cell.activity startAnimating];
        cell.userInteractionEnabled = NO;
        return cell;
    } else{
        ArticlesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArticlesCell"];
        ArticleContent *temp = [self.content.articles objectAtIndex:indexPath.row];
        if (temp) {
            cell.title.text = temp.title;
            cell.title.backgroundColor = [UIColor grayColor];
            cell.title.alpha = 0.5;
            NSDate *pubDate = temp.publishedDate;
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
            [dateFormat setDateFormat:@"dd.MM.yy HH:mm"];
            cell.publishedDate.backgroundColor = [UIColor grayColor];
            cell.publishedDate.alpha = 0.5;
            cell.publishedDate.text = [dateFormat stringFromDate:pubDate];
            cell.image.image = temp.mainImage;
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [self.content.articles count]) {
        return 75;
    }
    return 240;
}

@end
