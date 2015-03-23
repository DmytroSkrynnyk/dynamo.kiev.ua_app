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
#import "LoadingTableViewCell.h"
#import "ArticleContent.h"

@interface CommentsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation CommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showContent) name:@"CommentsDownloaded" object:nil];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row + 1 == _articleToShow.commentsContainer.comments.count && _articleToShow.commentsContainer.isAllCommentsLoaded == NO){
        [self prepareContent];
    }
    if(indexPath.row == _articleToShow.commentsContainer.comments.count){
        LoadingTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"LoadComments"];
        return cell;
    } else {
        UserComment *comment;
        CommentsTableViewCell *cell;
        if(indexPath.row == 0 && _articleToShow.commentsContainer.bestComment != nil){
            
            //create standalone view for best comment!!
            
            comment = _articleToShow.commentsContainer.bestComment;
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"BestCommentCell"];
            cell.name.text = comment.username;
            cell.rating.text = [NSString stringWithFormat:@"%li", (long)comment.rating];
            cell.status.text = comment.userStatus;
            cell.date.text = comment.date;
            cell.contentLabel.text = comment.content;
        } else {
            comment = _articleToShow.commentsContainer.comments[indexPath.row];
            if(comment.isDeleted == YES){
                cell = [self.tableView dequeueReusableCellWithIdentifier:@"DeletedCommentCell"];
            } else{
                if(comment.isHidden == YES){
                    cell = [self.tableView dequeueReusableCellWithIdentifier:@"HiddenCommentCell"];
                } else {
                    cell = [self.tableView dequeueReusableCellWithIdentifier:@"CommentsCell"];
                }
                cell.name.text = comment.username;
                if (comment.rating == 0) {
                    cell.rating.hidden = YES;
                } else {
                    cell.rating.text = [NSString stringWithFormat:@"%li", (long)comment.rating];
                }
                cell.status.text = comment.userStatus;
                cell.date.text = comment.date;
                cell.contentLabel.text = comment.content;
            }
        }
        cell.commentPosition.constant = 20 * comment.level;
        return cell;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(!_articleToShow.commentsContainer.comments){
        return 0;
    } else if(_articleToShow.commentsContainer.isAllCommentsLoaded){
        return _articleToShow.commentsContainer.comments.count;
    } else{
        return _articleToShow.commentsContainer.comments.count + 1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_articleToShow.commentsContainer.comments.count != indexPath.row){
        UserComment *comment = _articleToShow.commentsContainer.comments[indexPath.row];
        CGFloat contentLanelWidth = self.view.frame.size.width - 16 - (20 * comment.level);
        CGSize size = [comment.content sizeWithFont:[UIFont systemFontOfSize:15.0] constrainedToSize:CGSizeMake(contentLanelWidth, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        NSInteger nonContentLabelHieght = 57;
        if (indexPath.row == 0) {
            nonContentLabelHieght = 57 + 24;
        }
        return [comment.content isEqualToString:@"Комментарий удален"] ? 35 : size.height + nonContentLabelHieght;
    } else {
        return 75;
    }

}

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
