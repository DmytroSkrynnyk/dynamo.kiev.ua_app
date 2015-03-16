//
//  MatchCenterTVC.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 28.09.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import "MatchCenterTVC.h"
#import "ParseDynamoKievUa.h"
#import "MatchScoreInfo.h"
#import "ContentController.h"
#import "MatchCenterTableViewCell.h"

@interface MatchCenterTVC ()
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *homeTeam;
@property (weak, nonatomic) IBOutlet UILabel *homeTeamCity;
@property (weak, nonatomic) IBOutlet UILabel *guestTeam;
@property (weak, nonatomic) IBOutlet UILabel *guestTeamCity;
@property (weak, nonatomic) IBOutlet UILabel *score;
@property (weak, nonatomic) IBOutlet UILabel *tournament;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic) NSInteger homeTeamGoalsScored;
@property (nonatomic) NSInteger guestTeamGoalsScored;
@property (weak, nonatomic) IBOutlet UIView *matchView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *matchesLoadingActivityIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *centralMatchLoadingActivity;

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSIndexPath *lastSelectedCell;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centralMatchHieght;
@property (weak, nonatomic) IBOutlet UILabel *noMatchesLabel;
@property (nonatomic) BOOL isCentralMatchLoaded;
@end

@implementation MatchCenterTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    _isCentralMatchLoaded = NO;
    [ContentController dowloadAndParseMatchCenterPageWithCompletionHandler:^(NSMutableArray *info) {
        self.content = info;
        [self updateMatchTable];
    } error:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
    [ContentController dowloadAndParseMainPageWithCompletionHandler:^(MatchScoreInfo *match) {
        _isCentralMatchLoaded = YES;
        [self updateCentralMatch:match];
    } error:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
    _refreshControl = [[UIRefreshControl alloc] init];
    [_tableView addSubview:_refreshControl];
    [_refreshControl addTarget:self action:@selector(reloadContent) forControlEvents:UIControlEventValueChanged];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMatchDetails:) name:@"MatchDetailsPrepared" object:nil];
}

-(NSMutableArray *)content{
    if (!_content) {
        _content = [[NSMutableArray alloc] init];
    }
    return _content;
}

-(void)updateMatchTable{
    if (_content.count != 0) {
        [_tableView reloadData];
        _tableView.hidden = NO;
    } else {
        _noMatchesLabel.hidden = NO;
    }
    [_matchesLoadingActivityIndicator stopAnimating];
    if (_isCentralMatchLoaded == NO) {
        _centralMatchHieght.constant = 22;
        _centralMatchLoadingActivity.hidden = NO;
        [_centralMatchLoadingActivity startAnimating];
    }

}

-(void)updateCentralMatch:(MatchScoreInfo *)match{
    if (match) {
        _homeTeamGoalsScored = match.homeTeamScore;
        _guestTeamGoalsScored = match.guestTeamScore;
        _tournament.text = match.tournament;
        _homeTeam.text = match.homeTeam;
        _homeTeamCity.text = match.homeTeamCity;
        _guestTeam.text = match.guestTeam;
        _guestTeamCity.text = match.guestTeamCity;
        _date.text = match.date;
        if (_homeTeamGoalsScored == -1) {
            _score.text = [NSString stringWithFormat:@"- : -"];
        } else {
            _score.text = [NSString stringWithFormat:@"%ld : %ld",(long)_homeTeamGoalsScored, (long)_guestTeamGoalsScored];
        }
        
        [self addHomeTeamScorersLabel:match.homeTeamScorers];
        [self addGuestTeamScorersLabel:match.guestTeamScorers];
        NSInteger multiplier;
        if (_homeTeamGoalsScored == -1) {
            multiplier = 0;
        } else {
            multiplier = _homeTeamGoalsScored > _guestTeamGoalsScored ? _homeTeamGoalsScored : _guestTeamGoalsScored;
        }
        [_centralMatchLoadingActivity stopAnimating];
        _centralMatchHieght.constant = 99 + 15 * multiplier;
        [self hideCentralMatchView:NO];
    }
}
-(void)hideCentralMatchView:(BOOL)hide{
    NSArray *matchSubviews =  self.matchView.subviews;
    for (UIView *view in matchSubviews) {
        if ([view isKindOfClass:[UIActivityIndicatorView class]]) {
            UIActivityIndicatorView *activity = (UIActivityIndicatorView *) view;
            activity.hidden = !hide;
        } else {
            view.hidden = hide;
        }
        
    }
}

-(void)addHomeTeamScorersLabel:(NSArray *)scorers{
    if (_homeTeamGoalsScored > 0) {
        NSInteger yPosition = 80;
        for (NSString *scorer in scorers) {
            CGRect scrorerLabelPosition = CGRectMake(0, yPosition, _tableView.bounds.size.width / 2 - 33, 15);
            UILabel *scorerLabel = [[UILabel alloc] initWithFrame:scrorerLabelPosition];
            scorerLabel.text = scorer;
            scorerLabel.textAlignment = NSTextAlignmentRight;
            scorerLabel.font = [UIFont systemFontOfSize:12.0];
            [_matchView addSubview:scorerLabel];
            yPosition += 15;
        }
    }
}

-(void)addGuestTeamScorersLabel:(NSArray *)scorers{
    if (_guestTeamGoalsScored > 0) {
        NSInteger yPosition = 80;
        for (NSString *scorer in scorers) {
            CGRect scrorerLabelPosition = CGRectMake(_tableView.bounds.size.width / 2 + 33, yPosition, 111, 15);
            UILabel *scorerLabel = [[UILabel alloc] initWithFrame:scrorerLabelPosition];
            scorerLabel.text = scorer;
            scorerLabel.font = [UIFont systemFontOfSize:12.0];
            [_matchView addSubview:scorerLabel];
            yPosition += 15;
        }
    }
}

-(void)reloadContent{
    _isCentralMatchLoaded = NO;
    [ContentController dowloadAndParseMatchCenterPageWithCompletionHandler:^(NSMutableArray *info) {
        _content = info;
        [_tableView reloadData];
        [_refreshControl endRefreshing];
        if (_isCentralMatchLoaded == NO) {
            [self hideCentralMatchView:YES];
            _centralMatchLoadingActivity.hidden = NO;
            [_centralMatchLoadingActivity startAnimating];
        }
    } error:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
    [ContentController dowloadAndParseMainPageWithCompletionHandler:^(MatchScoreInfo *match) {
        _isCentralMatchLoaded = YES;
        [self updateCentralMatch:match];
    } error:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}
-(void)infoPrepared:(NSNotification *)info{
    _content = info.object;
    
    [_tableView reloadData];
    
}

-(void)loadDetailsForCellAtIndexPath:(NSIndexPath *)indexPath{
    MatchCenterTableViewCell *cell = (MatchCenterTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
    [self setLoadingCellState:YES forCell:cell];
    MatchScoreInfo *match = _content[indexPath.section][indexPath.row];
    [ContentController downloadAndParseDetailsForMatch:match];
}

-(void)setLoadingCellState:(BOOL)isLoading forCell:(MatchCenterTableViewCell *)cell{
    cell.leftTeam.hidden = isLoading;
    cell.rightTeam.hidden = isLoading;
    cell.score.hidden = isLoading;
    cell.date.hidden = isLoading;
    cell.loadingActivity.hidden = !isLoading;
    isLoading ? [cell.loadingActivity startAnimating] : [cell.loadingActivity stopAnimating];
}

-(void)showMatchDetails:(NSNotification *)notification{
    MatchScoreInfo *match = notification.object;
    MatchCenterTableViewCell *cell = (MatchCenterTableViewCell *)[_tableView cellForRowAtIndexPath:_lastSelectedCell];
    [self setLoadingCellState:NO forCell:cell];
    [cell.loadingActivity stopAnimating];
    for (NSInteger i = 1; i <= match.homeTeamScorers.count; i++) {
        UILabel *goalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 11 + 15 * i, 120, 14)];
        goalLabel.textAlignment = NSTextAlignmentRight;
        goalLabel.font = [UIFont systemFontOfSize:10];
        goalLabel.text = match.homeTeamScorers[i - 1];
        goalLabel.tag = 1;
        [cell addSubview:goalLabel];
    }
    for (NSInteger i = 1; i <= match.guestTeamScorers.count; i++) {
        UILabel *goalLabel = [[UILabel alloc] initWithFrame:CGRectMake(161, 11 + 15 * i, 159, 14)];
        goalLabel.textAlignment = NSTextAlignmentLeft;
        goalLabel.font = [UIFont systemFontOfSize:10];
        goalLabel.text = match.guestTeamScorers[i - 1];
        goalLabel.tag = 1;
        [cell addSubview:goalLabel];
    }
    cell.userInteractionEnabled = NO;
    _tableView.allowsSelection = YES;
    [_tableView reloadData];
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
    return 35;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _lastSelectedCell = indexPath;
    MatchScoreInfo *match = _content[indexPath.section][indexPath.row];
    if (match.homeTeamScorers || match.guestTeamScorers) {
        [self showMatchDetails:[[NSNotification alloc] initWithName:@"MatchDetailsPrepared" object:match userInfo:nil]];
    } else {
        [self loadDetailsForCellAtIndexPath:indexPath];
        _tableView.allowsSelection = NO;
    }
    
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
//    if (match.homeTeamScorers.count == 0 && match.guestTeamScorers.count == 0) {
//        for (UIView *subview in cell.subviews) {
//            if (subview.tag == 1) {
//                [subview removeFromSuperview];
//            }
//        }
//    } else {
//        NSNotification *notify = [[NSNotification alloc] initWithName:@"MatchDetailsPrepared" object:match userInfo:nil];
//        [self showMatchDetails:notify];
//    }
//    
    
    cell.loadingActivity.hidden = YES;
    return cell;
}
@end
