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
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivity;
@property (weak, nonatomic) IBOutlet UISegmentedControl *eurocupsContentSwitcher;

@end

@implementation StatisticsViewController

#pragma mark - DataSource delegate TableView methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.contentType == 0){
        return [self createTeamResultsCellForIndexPath:indexPath];
    } else if(self.contentType == 1){
        return [self createCalendarCellForIndexPath:indexPath];
    } else{
        return [self createPlayerGoalsCellForIndexPath:indexPath];
    }
}

-(TeamResultsTableViewCell *)createTeamResultsCellForIndexPath:(NSIndexPath *)indexPath{
    TeamResultsTableViewCell *cell;
    TeamResults *team;
    if (_isEurocups) {
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

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    TeamResultsTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"TeamResultsHead"];
    if (self.contentType == 0) {
        if (_isEurocups) {
            [cell.position setFont:[UIFont boldSystemFontOfSize:13.0]];
            cell.position.text = [NSString stringWithFormat:@"Группа %@", [StatisticsViewController groupNameInSection:section]];
            cell.teamName.hidden = YES;
            cell.backgroundColor =  [[UIColor alloc] initWithRed:0.89 green:0.89 blue:0.9 alpha:1.0];
            
        } else {
            [cell.position setFont:[UIFont systemFontOfSize:11.0]];
            cell.position.text = @"Поз.";
            cell.backgroundColor = [UIColor whiteColor];
        }
        cell.position.hidden = NO;
        
    }
    if (self.contentType == 1) {
        if (_isEurocups) {
            [cell.position setFont:[UIFont systemFontOfSize:13.0]];
            cell.position.text = [NSString stringWithFormat:@"Группа %@", [StatisticsViewController groupNameInSection:section]];
        } else {
            [cell.position setFont:[UIFont systemFontOfSize:11.0]];
            cell.position.text = [NSString stringWithFormat:@"%li-й тур",(long)section + 1];
        }
        [self hideRawsHeaders:YES inCell:cell];
        [cell.position setFont:[UIFont boldSystemFontOfSize:14.0]];
        cell.backgroundColor =  [[UIColor alloc] initWithRed:0.89 green:0.89 blue:0.9 alpha:1.0];
        
    }
    return cell;
}

-(void)hideRawsHeaders:(BOOL)hide inCell:(TeamResultsTableViewCell *)cell{
    cell.position.hidden = !hide;
    cell.teamName.hidden = hide;
    cell.gamesPlayed.hidden = hide;
    cell.gamesWon.hidden = hide;
    cell.gamesTied.hidden = hide;
    cell.gamesLoosed.hidden = hide;
    cell.goalsDifference.hidden = hide;
    cell.points.hidden = hide;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGFloat hieght = 1;
    if (self.contentType == 0) {
        if (_isEurocups) {
            hieght = 30;
        } else {
            hieght = 44;
        }
    }
    if (self.contentType == 1) {
        hieght = 30;
    }
    return hieght;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat hieght = 44;
    if (self.contentType == 1) {
        MatchScoreInfo *match = _tours[indexPath.section][indexPath.row];
        if (match.homeTeamScorers.count != 0 || match.guestTeamScorers.count != 0) {
            NSInteger multiplier = match.homeTeamScorers.count > match.guestTeamScorers.count ? match.homeTeamScorers.count : match.guestTeamScorers.count;
            hieght = 33 + 15 * multiplier;
        }
    }
    return hieght;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.contentType == 0) {
        if (_isEurocups) {
            return !_teamsResults ? 0 : [[_teamsResults objectAtIndex:section] count];
        } else {
            return !_teamsResults ? 0 : _teamsResults.count;
        }
    } else if(self.contentType == 1){
        return !_tours ? 0 : [[_tours objectAtIndex:section] count];
    } else {
        return !_scorers ? 0 : _scorers.count + 1;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.contentType == 0) {
        if (_isEurocups) {
            return !_teamsResults ? 0 : [_teamsResults count];
        } else {
            return !_teamsResults ? 0 : 1;
        }
    }
    return self.contentType == 1 ? _tours.count : 1;
}

+(NSString *)groupNameInSection:(NSInteger)section{
    NSArray *groupNames = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L"];
    return groupNames[section];
}

#pragma mark - Others

- (void)viewDidLoad {
    [super viewDidLoad];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    if (_isEurocups) {
        UISegmentedControl *eurocupsStageSwithcer = [[UISegmentedControl alloc] initWithItems:@[@"Группа", @"Плей-офф"]];
        eurocupsStageSwithcer.selectedSegmentIndex = 0;
        [eurocupsStageSwithcer addTarget:self action:@selector(switchEurocupsContent:) forControlEvents:UIControlEventValueChanged];
        _eurocupsContentSwitcher = eurocupsStageSwithcer;
        self.navigationItem.titleView = eurocupsStageSwithcer;
    }
    [self parseTable];
    
}

-(void)switchEurocupsContent:(id)sender{
    UISegmentedControl *switcher = (UISegmentedControl *)sender;
    if (switcher.selectedSegmentIndex == 0) {
        [_contentSwitcher insertSegmentWithTitle:@"Таблица" atIndex:0 animated:YES];
        [_contentSwitcher setSelectedSegmentIndex:0];
    } else {
        [_contentSwitcher removeSegmentAtIndex:0 animated:YES];
        [_contentSwitcher setSelectedSegmentIndex:0];
        _tableView.hidden = YES;
        [_loadingActivity startAnimating];
        
        //add downloading content
        
        
    }
        [_tableView reloadData];
}

- (IBAction)switchContent:(id)sender {
    UISegmentedControl *controller = (UISegmentedControl *)sender;
    _contentType = controller.selectedSegmentIndex;
    if (self.contentType == 0) {
        if (!_teamsResults) {
            [self parseTable];
        }
        _tableView.scrollEnabled = YES;
        _tableView.allowsSelection = NO;
        [_tableView scrollsToTop];
        [_tableView reloadData];
        
    } else if(self.contentType == 1){
        if (!_tours) {
            [self parseCalendar];
        }
        _tableView.scrollEnabled = YES;
        _tableView.allowsSelection = YES;
        [_tableView reloadData];
        if (_tours.count > _currentTour) {
            NSIndexPath *nearestTourToPlay = [NSIndexPath indexPathForRow:0 inSection:_currentTour];
            [_tableView scrollToRowAtIndexPath:nearestTourToPlay atScrollPosition:(UITableViewScrollPositionTop) animated:NO];
        }
    } else if(self.contentType == 2){
        if (!_scorers) {
            [self parseScorers];
        }
        _tableView.scrollEnabled = NO;
        _tableView.allowsSelection = NO;
        [_tableView reloadData];
    }
}

-(void)parseTable{
    if (_isEurocups) {
        [ContentController dowloadAndParseTableAndCalendarForLeague:_baseURL completionHandler:^(NSMutableDictionary *info) {
            _teamsResults = [info objectForKey:@"groupsTable"];
            _tours = [info objectForKey:@"calendar"];
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
    if (_isEurocups) {
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

-(NSInteger)contentType{
    if (_eurocupsContentSwitcher.selectedSegmentIndex == 1) {
        return _contentType + 1;
    }
    return _contentType;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

@end
