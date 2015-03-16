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
@property (weak, nonatomic) IBOutlet UISegmentedControl *groupsSwitcher;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *tours;
@property (strong, nonatomic) NSMutableArray *teamsResults;
@property (strong, nonatomic) NSMutableArray *scorers;
@property (weak, nonatomic) IBOutlet UIScrollView *tableNavigator;
@property (nonatomic) NSInteger contentType;
@property (nonatomic) NSInteger currentTour;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *costraintHeigt;

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
    if (indexPath.row == 0) {
        cell = [_tableView dequeueReusableCellWithIdentifier:@"TeamResultsHead"];
    } else {
        TeamResults *team;
        if ([_baseURL isEqualToString:@"/champions-league/"] || [_baseURL isEqualToString:@"/europa-league/"]) {
            team = _teamsResults[indexPath.section][indexPath.row - 1];
        } else {
            team = _teamsResults[indexPath.row - 1];
        }
        if (team.city) {
            cell = [_tableView dequeueReusableCellWithIdentifier:@"TeamResults"];
        } else {
            cell = [_tableView dequeueReusableCellWithIdentifier:@"TeamResultsWithoutCity"];
        }
        cell.position.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
        cell.teamName.text = team.name;
        cell.teamCity.text = team.city;
        cell.gamesPlayed.text = [NSString stringWithFormat:@"%ld", (long)team.gamesPlayed];
        cell.gamesWon.text = [NSString stringWithFormat:@"%ld", (long)team.wins];
        cell.gamesLoosed.text = [NSString stringWithFormat:@"%ld", (long)team.defeats];
        cell.gamesTied.text = [NSString stringWithFormat:@"%ld", (long)team.draws];
        cell.goalsDifference.text = [NSString stringWithFormat:@"%ld - %ld", (long)team.goalsScored, (long)team.goalsAgainst];
        cell.points.text = [NSString stringWithFormat:@"%ld", (long)team.points];
        
    }
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
            return !_teamsResults ? 0 : [[_teamsResults objectAtIndex:section] count] + 1;
        } else {
            return !_teamsResults ? 0 : _teamsResults.count + 1;
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
    [self parseTable];
}

- (IBAction)scrollToGroup:(id)sender {
    NSIndexPath *indexPathToScroll = [NSIndexPath indexPathForRow:0 inSection:_groupsSwitcher.selectedSegmentIndex];
    [_tableView scrollToRowAtIndexPath:indexPathToScroll atScrollPosition:(UITableViewScrollPositionTop) animated:YES];
}

- (IBAction)switchContent:(id)sender {
    UISegmentedControl *controller = (UISegmentedControl *)sender;
    _contentType = controller.selectedSegmentIndex;
    if (_contentType == 0) {
        if (!_teamsResults) {
            [self parseTable];
            _tableView.scrollEnabled = YES;
        }
    } else if(_contentType == 1){
        if (!_tours) {
            [self parseCalendar];
            _tableView.scrollEnabled = YES;
        }
    } else if(_contentType == 2){
        if (!_scorers) {
            [self parseScorers];
            _tableView.scrollEnabled = NO;
        }
    }
    [_tableView reloadData];
}

-(void)parseTable{
    if ([_baseURL isEqualToString:@"/champions-league/"] || [_baseURL isEqualToString:@"/europa-league/"]) {
        [ContentController dowloadAndParseTableAndCalendarForLeague:_baseURL completionHandler:^(NSMutableDictionary *info) {
            _teamsResults = [info objectForKey:@"groupsTable"];
            _tours = [info objectForKey:@"calendar"];
            [_tableView reloadData];
        } error:^(NSError *error) {
            
        }];
    } else {
        [ContentController dowloadAndParseTableForLegue:_baseURL completionHandler:^(NSMutableArray *info) {
            _currentTour = [[info lastObject] integerValue];
            [info removeLastObject];
            _teamsResults = info;
            [_tableView reloadData];
        } error:^(NSError *error) {
            NSLog(@"%@", error.description);
        }];
    }
}


-(void)parseScorers{
    [ContentController dowloadAndParseScorersForLegue:_baseURL completionHandler:^(NSMutableArray *scorers) {
        _scorers = scorers;
        _contentType = _contentSwitcher.selectedSegmentIndex;
        [_tableView reloadData];
    } error:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

-(void)parseCalendar{
    if ([_baseURL isEqualToString:@"/champions-league/"] || [_baseURL isEqualToString:@"/europa-league/"]) {
        [ContentController dowloadAndParseTableAndCalendarForLeague:_baseURL completionHandler:^(NSMutableDictionary *info) {
//            NSMutableDictionary *tableAndCalendar = info;
            _teamsResults = [info objectForKey:@"groupsTable"];
            _tours = [info objectForKey:@"calendar"];
            [self setGroupsSwitcherView];
        } error:^(NSError *error) {
           
        }];
    } else {
        [ContentController dowloadAndParseScheduleForLegue:_baseURL completionHandler:^(NSMutableArray *info) {
            _tours = info;
            [self setGroupsSwitcherView];
        } error:^(NSError *error) {
            NSLog(@"%@", error.description);
        }];
    }
}

-(void)setGroupsSwitcherView{
    _tableNavigator.contentSize = CGSizeMake(_tours.count * 34 + 20, 45);
    if([_baseURL isEqualToString:@"/europa-league/"]){
        for(NSInteger i = 8; i < _tours.count; i++){
            [_groupsSwitcher insertSegmentWithTitle:[self groupNameInSection:i] atIndex:i animated:NO];
        }
    } else {
        for(NSInteger i = 0; i < _tours.count; i++){
            if (i < 8) {
                [_groupsSwitcher setTitle:[NSString stringWithFormat:@"%ld", (long)i + 1] forSegmentAtIndex:i];
            } else{
                [_groupsSwitcher insertSegmentWithTitle:[NSString stringWithFormat:@"%ld", (long)i + 1] atIndex:i animated:NO];
            }
        }
    }
    _groupsSwitcher.hidden = NO;
    [_tableView reloadData];
    NSIndexPath *nearestTourToPlay = [NSIndexPath indexPathForRow:0 inSection:_currentTour];
    [_tableView scrollToRowAtIndexPath:nearestTourToPlay atScrollPosition:(UITableViewScrollPositionTop) animated:NO];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.costraintHeigt.constant = 47 + MAX(0, -scrollView.contentOffset.y);;
}

@end
