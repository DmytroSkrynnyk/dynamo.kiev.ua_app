//
//  MatchCenterTVC.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 28.09.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import "MatchCenterTVC.h"
#import "MatchScoreInfo.h"
#import "ContentController.h"
#import "MatchCenterTableViewCell.h"
#import "CentralMatchView.h"

@interface MatchCenterTVC ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *matchesLoadingActivityIndicator;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *noMatchesLabel;
@property (weak, nonatomic) IBOutlet CentralMatchView *matchView;
@property (strong, nonatomic) NSIndexPath *lastSelectedCell;
@end

@implementation MatchCenterTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    _matchView.isCentralMatchLoaded = NO;
    [self prepareContent];
    _refreshControl = [[UIRefreshControl alloc] init];
    [_tableView addSubview:_refreshControl];
    [_refreshControl addTarget:self action:@selector(reloadContent) forControlEvents:UIControlEventValueChanged];
    [[NSNotificationCenter defaultCenter] addObserver:_tableView selector:@selector(reloadData) name:@"MatchDetailsPrepared" object:nil];
}

-(NSMutableArray *)content{
    if (!_content) {
        _content = [[NSMutableArray alloc] init];
    }
    return _content;
}

-(void)prepareContent{
    [ContentController dowloadAndParseMatchCenterPageWithCompletionHandler:^(NSMutableArray *info) {
        self.content = info;
        [self updateMatchTable];
    } error:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
    [ContentController dowloadAndParseMainPageWithCompletionHandler:^(MatchScoreInfo *match) {
        _matchView.isCentralMatchLoaded = YES;
        [_matchView updateCentralMatch:match];
    } error:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];

}

-(void)updateMatchTable{
    if (_content.count != 0) {
        [_tableView reloadData];
        _tableView.hidden = NO;
    } else {
        _noMatchesLabel.hidden = NO;
    }
    [_matchesLoadingActivityIndicator stopAnimating];
    if (_matchView.isCentralMatchLoaded == NO) {
        _matchView.centralMatchHieght.constant = 42;
        _matchView.centralMatchLoadingActivity.hidden = NO;
        [_matchView.centralMatchLoadingActivity startAnimating];
    }

}

-(void)reloadContent{
    _matchView.isCentralMatchLoaded = NO;
    [ContentController dowloadAndParseMatchCenterPageWithCompletionHandler:^(NSMutableArray *info) {
        _content = info;
        [_tableView reloadData];
        [_refreshControl endRefreshing];
        if (_matchView.isCentralMatchLoaded == NO) {
            [_matchView hideCentralMatchView:YES];  //Check it. May it is no need in it.
            _matchView.centralMatchLoadingActivity.hidden = NO;
            [_matchView.centralMatchLoadingActivity startAnimating];
        }
    } error:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
    [ContentController dowloadAndParseMainPageWithCompletionHandler:^(MatchScoreInfo *match) {
        _matchView.isCentralMatchLoaded = YES;
        [_matchView updateCentralMatch:match];
    } error:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

-(void)addGoalLabelsForMatch:(MatchScoreInfo *)match inCell:(MatchCenterTableViewCell *)cell{
    for (NSInteger i = 1; i <= match.homeTeamScorers.count; i++) {
        
        UILabel *goalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 16 + 15 * i, cell.leftTeam.frame.size.width, 14)];
        
        goalLabel.textAlignment = NSTextAlignmentRight;
        goalLabel.font = [UIFont systemFontOfSize:10];
        goalLabel.text = match.homeTeamScorers[i - 1];
        goalLabel.tag = 1;
        [cell.contentView addSubview:goalLabel];
    }
    for (NSInteger i = 1; i <= match.guestTeamScorers.count; i++) {
        
        UILabel *goalLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.rightTeam.frame.origin.x, 16 + 15 * i, cell.rightTeam.frame.size.width, 14)];
        
        goalLabel.textAlignment = NSTextAlignmentLeft;
        goalLabel.font = [UIFont systemFontOfSize:10];
        goalLabel.text = match.guestTeamScorers[i - 1];
        goalLabel.tag = 1;
        [cell.contentView addSubview:goalLabel];
    }
    cell.tag = 1;
    cell.userInteractionEnabled = NO;
    _tableView.allowsSelection = YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.content count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_content[section] count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    MatchScoreInfo *firstMatchInSection = [_content[section] firstObject];
    return firstMatchInSection.tournament;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    MatchScoreInfo *match = _content[indexPath.section][indexPath.row];
    if (match.homeTeamScorers.count != 0 || match.guestTeamScorers.count != 0) {
        NSInteger multiplier = match.homeTeamScorers.count > match.guestTeamScorers.count ? match.homeTeamScorers.count : match.guestTeamScorers.count;
        return 33 + 15 * multiplier;
    }
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MatchCenterTableViewCell *cell = (MatchCenterTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
    [cell setLoadingCellState:YES];
    MatchScoreInfo *match = _content[indexPath.section][indexPath.row];
    [ContentController downloadAndParseDetailsForMatch:match];
    _tableView.allowsSelection = NO;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MatchScoreInfo *match = _content[indexPath.section][indexPath.row];
    MatchCenterTableViewCell *cell;
    if (match.homeTeamScore == -1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"EqualMatch"];
        cell.score.text = @"- : -";
        cell.userInteractionEnabled = NO;
    } else {
        if (match.homeTeamScore != match.guestTeamScore) {
            if (match.homeTeamScore < match.guestTeamScore) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"GuestTeamWon"];
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:@"HomeTeamWon"];
            }
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"EqualMatch"];
            cell.userInteractionEnabled = !(match.homeTeamScore == 0);
        }
        cell.score.text = [NSString stringWithFormat:@"%ld - %ld", (long)match.homeTeamScore, (long)match.guestTeamScore];
    }
    cell.leftTeam.text = match.homeTeam;
    cell.rightTeam.text = match.guestTeam;
    cell.date.text = match.date;
    cell.scorePosition.constant = (self.view.bounds.size.width - (self.view.bounds.size.width - cell.date.frame.size.width)) / 2;
    if (match.homeTeamScorers || match.guestTeamScorers) {
        [self addGoalLabelsForMatch:match inCell:cell];
    }
    return cell;
}
@end
