//
//  StatisticsViewController.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 01.10.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import "StatisticsViewController.h"
#import "TeamResults.h"
#import "PlayerStats.h"
#import "ContentController.h"
#import "LoadingTableViewCell.h"
#import "MatchCenterTableViewCell.h"
#import "MatchScoreInfo.h"
#import "TeamResultsTableViewCell.h"
#import "PlayerGoalsStatsTableViewCell.h"

@interface StatisticsViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *contentSwitcher;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *tours;
@property (strong, nonatomic) NSMutableArray *teamsResults;
@property (strong, nonatomic) NSMutableArray *scorers;
@property (nonatomic) NSInteger contentType;
@property (nonatomic) NSInteger currentTour;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerPosition;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHieght;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableviewTopPosition;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *positionHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *teamHeaderLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivity;

@end

@implementation StatisticsViewController

#pragma mark - DataSource delegate TableView methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_contentType == 0){
        return [self createTeamResultsCellForIndexPath:indexPath];
    } else if(_contentType == 1){
        return [self createCalendarCellForIndexPath:indexPath];
    } else{
        return [self createPlayerGoalsCellForIndexPath:indexPath];
    }
}

-(TeamResultsTableViewCell *)createTeamResultsCellForIndexPath:(NSIndexPath *)indexPath{
    TeamResultsTableViewCell *cell;
//    if (indexPath.row == 0) {
//        cell = [_tableView dequeueReusableCellWithIdentifier:@"TeamResultsHead"];
//    } else {
        TeamResults *team;
        if ([_baseURL isEqualToString:@"/champions-league/"] || [_baseURL isEqualToString:@"/europa-league/"]) {
            team = _teamsResults[indexPath.section][indexPath.row];
        } else {
            team = _teamsResults[indexPath.row];
        }
        if (team.city) {
            cell = [_tableView dequeueReusableCellWithIdentifier:@"TeamResults"];
        } else {
            cell = [_tableView dequeueReusableCellWithIdentifier:@"TeamResultsWithoutCity"];
        }
        cell.position.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row + 1];
        cell.teamName.text = team.name;
        cell.teamCity.text = team.city;
        cell.gamesPlayed.text = [NSString stringWithFormat:@"%ld", (long)team.gamesPlayed];
        cell.gamesWon.text = [NSString stringWithFormat:@"%ld", (long)team.wins];
        cell.gamesLoosed.text = [NSString stringWithFormat:@"%ld", (long)team.defeats];
        cell.gamesTied.text = [NSString stringWithFormat:@"%ld", (long)team.draws];
        cell.goalsDifference.text = [NSString stringWithFormat:@"%ld - %ld", (long)team.goalsScored, (long)team.goalsAgainst];
        cell.points.text = [NSString stringWithFormat:@"%ld", (long)team.points];
//    }
    return cell;
}

-(MatchCenterTableViewCell *)createCalendarCellForIndexPath:(NSIndexPath *)indexPath{
    MatchCenterTableViewCell *cell;
    MatchScoreInfo *match = _tours[indexPath.section][indexPath.row];
    if (match.homeTeamScore == -1) {
        cell = [_tableView dequeueReusableCellWithIdentifier:@"NotPlayedMatch"];
    } else {
        if (match.homeTeamScore != match.guestTeamScore) {
            if (match.homeTeamScore < match.guestTeamScore) {
                cell = [_tableView dequeueReusableCellWithIdentifier:@"GuestTeamWon"];
            } else {
                cell = [_tableView dequeueReusableCellWithIdentifier:@"HomeTeamWon"];
            }
        } else {
            cell = [_tableView dequeueReusableCellWithIdentifier:@"EqualMatch"];
        }
        cell.score.text = [NSString stringWithFormat:@"%ld - %ld", (long)match.homeTeamScore, (long)match.guestTeamScore];
    }
    cell.leftTeam.text = match.homeTeam;
    cell.rightTeam.text = match.guestTeam;
    cell.date.text = match.date;
    return cell;
}

-(PlayerGoalsStatsTableViewCell *)createPlayerGoalsCellForIndexPath:(NSIndexPath *)indexPath{
    PlayerGoalsStatsTableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [_tableView dequeueReusableCellWithIdentifier:@"PlayerGoalsStatHead"];
    } else {
        PlayerStats *player = _scorers[indexPath.row - 1];
        cell = [_tableView dequeueReusableCellWithIdentifier:@"PlayerGoalsStat"];
        cell.name.text = player.name;
        cell.team.text = player.team;
        cell.goalsScored.text = [NSString stringWithFormat:@"%ld", (long)player.goalsScored];
        cell.homeGoals.text = [NSString stringWithFormat:@"%ld", (long)player.homeGoals];
        cell.guestGoals.text = [NSString stringWithFormat:@"%ld", (long)player.guestGoals];
        cell.penaltyScored.text = [NSString stringWithFormat:@"%ld", (long)player.penaltyScored];
        cell.position.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    }
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *header;
    if (_contentType == 0) {
        if ([_baseURL isEqualToString:@"/champions-league/"] || [_baseURL isEqualToString:@"/europa-league/"]) {
            header = [NSString stringWithFormat:@"Группа %@", [self groupNameInSection:section]];
        }
    }
    if (_contentType == 1) {
        if ([_baseURL isEqualToString:@"/champions-league/"] || [_baseURL isEqualToString:@"/europa-league/"]) {
            header = [NSString stringWithFormat:@"Группа %@", [self groupNameInSection:section]];
        } else {
            header = [NSString stringWithFormat:@"%li-й тур",(long)section + 1];
        }
    }
    return header;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_contentType == 0) {
        if ([_baseURL isEqualToString:@"/champions-league/"] || [_baseURL isEqualToString:@"/europa-league/"]) {
            return !_teamsResults ? 0 : [[_teamsResults objectAtIndex:section] count];
        } else {
            return !_teamsResults ? 0 : _teamsResults.count;
        }
        
    } else if(_contentType == 1){
        return !_tours ? 0 : [[_tours objectAtIndex:section] count];
    } else {
        return !_scorers ? 0 : _scorers.count + 1;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_contentType == 0) {
        if ([_baseURL isEqualToString:@"/champions-league/"] || [_baseURL isEqualToString:@"/europa-league/"]) {
            return !_teamsResults ? 0 : [_teamsResults count];
        } else {
            return !_teamsResults ? 0 : 1;
        }
    }
    return _contentType == 1 ? _tours.count : 1;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    NSLog(@"%f", _tableView.contentOffset.y);
    if (scrollView.contentOffset.y < 0) {
        _headerPosition.constant = abs(scrollView.contentOffset.y);
    }
//    self.costraintHeigt.constant = 47 + MAX(0, -scrollView.contentOffset.y);
}

-(NSString *)groupNameInSection:(NSInteger)section{
    NSString *groupName;
    switch (section) {
        case 0:
            groupName = @"A";
            break;
        case 1:
            groupName = @"B";
            break;
        case 2:
            groupName = @"C";
            break;
        case 3:
            groupName = @"D";
            break;
        case 4:
            groupName = @"E";
            break;
        case 5:
            groupName = @"F";
            break;
        case 6:
            groupName = @"G";
            break;
        case 7:
            groupName = @"H";
        case 8:
            groupName = @"I";
            break;
        case 9:
            groupName = @"J";
            break;
        case 10:
            groupName = @"K";
            break;
        case 11:
            groupName = @"L";
            break;
        default:
            break;
    }
    return groupName;
}

#pragma mark - Others

- (void)viewDidLoad {
    [super viewDidLoad];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    if ([_baseURL isEqualToString:@"/champions-league/"] || [_baseURL isEqualToString:@"/europa-league/"]) {
        _tableviewTopPosition.constant = 0;
        _positionHeaderLabel.hidden = YES;
        _teamHeaderLabel.hidden = YES;
        _headerHieght.constant = 30;
    } else {
        _tableviewTopPosition.constant = 42;
        _headerHieght.constant = 42;
        _positionHeaderLabel.hidden = NO;
        _teamHeaderLabel.hidden = NO;
    }
    [self parseTable];
    
}

- (IBAction)switchContent:(id)sender {
    UISegmentedControl *controller = (UISegmentedControl *)sender;
    _contentType = controller.selectedSegmentIndex;
    if (_contentType == 0) {
        if (!_teamsResults) {
            [self parseTable];
        }
        _headerView.hidden = NO;
        _tableView.scrollEnabled = YES;
        _tableView.allowsSelection = NO;
        
        [self setHeaderPosition];
        
    } else if(_contentType == 1){
        if (!_tours) {
            [self parseCalendar];
        }
        _tableView.scrollEnabled = YES;
        _tableView.allowsSelection = YES;
        _headerView.hidden = YES;
        _tableviewTopPosition.constant = 0;
    } else if(_contentType == 2){
        if (!_scorers) {
            [self parseScorers];
        }
        _tableView.scrollEnabled = NO;
        _tableView.allowsSelection = NO;
        _headerView.hidden = YES;
        _tableviewTopPosition.constant = 0;
    }
    [_tableView reloadData];
}

-(void)setHeaderPosition{
    if ([_baseURL isEqualToString:@"/champions-league/"] || [_baseURL isEqualToString:@"/europa-league/"]) {
        _tableviewTopPosition.constant = 0;
        _positionHeaderLabel.hidden = YES;
        _teamHeaderLabel.hidden = YES;
        _headerHieght.constant = 30;
    } else {
        _tableviewTopPosition.constant = 42;
        _headerHieght.constant = 42;
        _positionHeaderLabel.hidden = NO;
        _teamHeaderLabel.hidden = NO;
    }
}

-(void)parseTable{
    if ([_baseURL isEqualToString:@"/champions-league/"] || [_baseURL isEqualToString:@"/europa-league/"]) {
        [ContentController dowloadAndParseTableAndCalendarForLeague:_baseURL completionHandler:^(NSMutableDictionary *info) {
            _teamsResults = [info objectForKey:@"groupsTable"];
            _tours = [info objectForKey:@"calendar"];
            _headerView.hidden = NO;
            [_tableView reloadData];
            [_loadingActivity stopAnimating];
            _tableView.hidden = NO;
        } error:^(NSError *error) {
            
        }];
    } else {
        [ContentController dowloadAndParseTableForLegue:_baseURL completionHandler:^(NSMutableArray *info) {
            _currentTour = [[info lastObject] integerValue];
            [info removeLastObject];
            _teamsResults = info;
            _headerView.hidden = NO;
            [_tableView reloadData];
            [_loadingActivity stopAnimating];
            _tableView.hidden = NO;
        } error:^(NSError *error) {
            NSLog(@"%@", error.description);
        }];
    }
}


-(void)parseScorers{
    _tableView.hidden = YES;
    [_loadingActivity startAnimating];
    [ContentController dowloadAndParseScorersForLegue:_baseURL completionHandler:^(NSMutableArray *scorers) {
        _scorers = scorers;
        _contentType = _contentSwitcher.selectedSegmentIndex;
        [_tableView reloadData];
        [_loadingActivity stopAnimating];
        _tableView.hidden = NO;
    } error:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

-(void)parseCalendar{
    _tableView.hidden = YES;
    [_loadingActivity startAnimating];
    if ([_baseURL isEqualToString:@"/champions-league/"] || [_baseURL isEqualToString:@"/europa-league/"]) {
        [ContentController dowloadAndParseTableAndCalendarForLeague:_baseURL completionHandler:^(NSMutableDictionary *info) {
            _teamsResults = [info objectForKey:@"groupsTable"];
            _tours = [info objectForKey:@"calendar"];
            [_tableView reloadData];
            [_loadingActivity stopAnimating];
            _tableView.hidden = NO;
            NSIndexPath *nearestTourToPlay = [NSIndexPath indexPathForRow:0 inSection:_currentTour];
            [_tableView scrollToRowAtIndexPath:nearestTourToPlay atScrollPosition:(UITableViewScrollPositionTop) animated:NO];
        } error:^(NSError *error) {
           
        }];
    } else {
        [ContentController dowloadAndParseScheduleForLegue:_baseURL completionHandler:^(NSMutableArray *info) {
            _tours = info;
            [_tableView reloadData];
            [_loadingActivity stopAnimating];
            _tableView.hidden = NO;
            NSIndexPath *nearestTourToPlay = [NSIndexPath indexPathForRow:0 inSection:_currentTour];
            [_tableView scrollToRowAtIndexPath:nearestTourToPlay atScrollPosition:(UITableViewScrollPositionTop) animated:NO];
        } error:^(NSError *error) {
            NSLog(@"%@", error.description);
        }];
    }
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    self.costraintHeigt.constant = 47 + MAX(0, -scrollView.contentOffset.y);;
//}

@end
