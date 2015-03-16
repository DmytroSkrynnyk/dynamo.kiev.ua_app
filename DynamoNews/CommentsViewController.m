//
//  CommentsViewController.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 15.02.15.
//  Copyright (c) 2015 AlPono.inc. All rights reserved.
//

#import "CommentsViewController.h"
#import "CommentsTableViewCell.h"
#import "ContentController.h"
#import "UserComment.h"

@interface CommentsViewController ()

@end

@implementation CommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.tableView.estimatedRowHeight = 100;
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showContent) name:@"CommentsDownloaded" object:nil];
    self.navigationItem.title = [NSString stringWithFormat:@"%ld", (long)_articleToShow.ID];
    
    
    // Do any additional setup after loading the view.
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CommentsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CommentsCell"];
    UserComment *comment = _articleToShow.commentsContainer.comments[indexPath.row];
    cell.name.text = comment.username;
    if (comment.rating > 0) {
        cell.rating.text = [NSString stringWithFormat:@"+%li", (long)comment.rating];
    } else {
        cell.rating.text = [NSString stringWithFormat:@"%li", (long)comment.rating];
    }
    cell.rating.text = [NSString stringWithFormat:@"%li", (long)comment.rating];
    cell.status.text = comment.userStatus;
    cell.date.text = comment.date;
    cell.content.text = comment.content;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _articleToShow.commentsContainer.comments.count;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    UserComment *comment =  _articleToShow.commentsContainer.comments[indexPath.row];
//    NSString *commentString = comment.content;
//    
//    return UITableViewAutomaticDimension;
//}

-(void)prepareContent{
    [ContentController dowloadAndParseCommentsForArticle:_articleToShow];
}

-(void)showContent{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
