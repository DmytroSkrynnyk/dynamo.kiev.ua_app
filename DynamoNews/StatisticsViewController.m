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
#import "PlayoffsMatchScoreInfo.h"
#import "PlayoffsTableViewCell.h"

@interface StatisticsViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *contentSwitcher;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *tours;
@property (strong, nonatomic) NSMutableArray *teamsResults;
@property (strong, nonatomic) NSMutableArray *scorers;
@property (strong, nonatomic) NSMutableArray *playoffs;
@property (nonatomic) NSInteger contentType;
@property (nonatomic) NSInteger currentTour;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivity;
@property (weak, nonatomic) UISegmentedControl *eurocupsContentSwitcher;
@property (strong, nonatomic) NSMutableArray *goalsAreShowedAtIndexPathes;

@end

@implementation StatisticsViewController

#pragma mark - DataSource delegate TableView methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.contentType == 0){
        return [self createTeamResultsCellForIndexPath:indexPath];
    } else if(self.contentType == 1){
        if (_eurocupsContentSwitcher && _eurocupsContentSwitcher.selectedSegmentIndex == 1) {
            return [self createPlayoffsCellForIndexPath:indexPath];
        } else {
            return [self createCalendarCellForIndexPath:indexPath];
        }
    } else {
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

-(PlayoffsTableViewCell *)createPlayoffsCellForIndexPath:(NSIndexPath *)indexPath{
    PlayoffsTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"PlayoffCell"];
    NSMutableArray *pair = _playoffs[indexPath.section][indexPath.row];
    PlayoffsMatchScoreInfo *firstMatch =  [pair firstObject];
    if (firstMatch.homeTeamScore < firstMatch.guestTeamScore) {
        cell.firstMatchHomeTeam.textColor = [UIColor lightGrayColor];
    } else if(firstMatch.homeTeamScore > firstMatch.guestTeamScore) {
        cell.firstMatchGuestTeam.textColor = [UIColor lightGrayColor];
    }
    cell.firstMatchHomeTeam.text = firstMatch.homeTeam;
    cell.firstMatchGuestTeam.text = firstMatch.guestTeam;
    if (firstMatch.homeTeamScore != -1) {
        [cell.firstMatchScoreOrDate setFont:[UIFont systemFontOfSize:16.0]];
        cell.firstMatchScoreOrDate.text = [NSString stringWithFormat:@"%ld : %ld", (long)firstMatch.homeTeamScore, (long)firstMatch.guestTeamScore];
    } else {
        [cell.firstMatchScoreOrDate setFont:[UIFont systemFontOfSize:12.0]];
        cell.firstMatchScoreOrDate.text = firstMatch.date;
    }
    PlayoffsMatchScoreInfo *secondMatch = [pair lastObject];
    if (secondMatch.homeTeamScore < secondMatch.guestTeamScore) {
        cell.secondMatchHomeTeam.textColor = [UIColor lightGrayColor];
    } else if(secondMatch.homeTeamScore > secondMatch.guestTeamScore) {
        cell.secondMatchGuestTeam.textColor = [UIColor lightGrayColor];
    }
    cell.secondMatchHomeTeam.text = secondMatch.homeTeam;
    cell.secondMatchGuestTeam.text = secondMatch.guestTeam;
    if (secondMatch.homeTeamScore != -1) {
        [cell.secondMatchScoreOrDate setFont:[UIFont systemFontOfSize:16.0]];
        cell.secondMatchScoreOrDate.text = [NSString stringWithFormat:@"%ld : %ld", (long)secondMatch.homeTeamScore, (long)secondMatch.guestTeamScore];
    } else {
        [cell.secondMatchScoreOrDate setFont:[UIFont systemFontOfSize:12.0]];
        cell.secondMatchScoreOrDate.text = secondMatch.date;
    }
    if(firstMatch.homeTeamScore > 0 || firstMatch.guestTeamScore > 0 || secondMatch.homeTeamScore > 0 || secondMatch.guestTeamScore > 0){
        cell.userInteractionEnabled = YES;
    } else {
        cell.userInteractionEnabled = NO;
    }
    if([self showGoalsAtIndexPath:indexPath] == YES){
        [self addScorerLabelsForPair:pair onCell:cell];
    }
    return cell;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    TeamResultsTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"TeamResultsHead"];
    if (self.contentType == 0) {
        if (_isEurocups) {
            cell.position.text = [NSString stringWithFormat:@"Группа %@", [StatisticsViewController groupNameInSection:section]];
            [cell.position setFont:[UIFont boldSystemFontOfSize:13.0]];
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
            if (_eurocupsContentSwitcher.selectedSegmentIndex == 1) {
                PlayoffsMatchScoreInfo *match = [[_playoffs[section] firstObject] firstObject];
                cell.position.text = match.tournament;
            } else {
                cell.position.text = [NSString stringWithFormat:@"Группа %@", [StatisticsViewController groupNameInSection:section]];
            }
            [cell.position setFont:[UIFont systemFontOfSize:13.0]];
            
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

-(void)addScorerLabelsForPair:(NSMutableArray *)pair onCell:(PlayoffsTableViewCell *)cell{
    PlayoffsMatchScoreInfo *firstMatch = [pair firstObject];
    if(firstMatch.homeTeamScore > 0){
        for(NSInteger i = 1; i <= firstMatch.homeTeamScorers.count; i++){
            UILabel *goalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 16 + 15 * i, cell.firstMatchHomeTeam.frame.size.width, 14)];
            goalLabel.textAlignment = NSTextAlignmentRight;
            goalLabel.font = [UIFont systemFontOfSize:10];
            goalLabel.text = firstMatch.homeTeamScorers[i - 1];
            goalLabel.tag = 1;
            [cell.contentView addSubview:goalLabel];
        }
    }
    
    if(firstMatch.guestTeamScore > 0){
        for(NSInteger i = 1; i <= firstMatch.guestTeamScorers.count; i++){
            UILabel *goalLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.firstMatchGuestTeam.frame.origin.x, 16 + 15 * i, cell.firstMatchGuestTeam.frame.size.width, 14)];
            goalLabel.textAlignment = NSTextAlignmentLeft;
            goalLabel.font = [UIFont systemFontOfSize:10];
            goalLabel.text = firstMatch.guestTeamScorers[i - 1];
            goalLabel.tag = 1;
            [cell.contentView addSubview:goalLabel];
        }
    }
    NSInteger multiplier = firstMatch.homeTeamScore > firstMatch.guestTeamScore ? firstMatch.homeTeamScorers.count : firstMatch.guestTeamScorers.count;
    cell.spacingBetweenMatches.constant = 14 * multiplier;
    
    PlayoffsMatchScoreInfo *secondMatch = [pair lastObject];
    if(secondMatch.homeTeamScore > 0){
        for(NSInteger i = 1; i <= secondMatch.homeTeamScorers.count; i++){
            UILabel *goalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 47 + 15 * i + cell.spacingBetweenMatches.constant, cell.secondMatchHomeTeam.frame.size.width, 14)];
            goalLabel.textAlignment = NSTextAlignmentRight;
            goalLabel.font = [UIFont systemFontOfSize:10];
            goalLabel.text = secondMatch.homeTeamScorers[i - 1];
            goalLabel.tag = 1;
            [cell.contentView addSubview:goalLabel];
        }
    }
    
    if(secondMatch.guestTeamScore > 0){
        for(NSInteger i = 1; i <= secondMatch.guestTeamScorers.count; i++){
            UILabel *goalLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.secondMatchGuestTeam.frame.origin.x, 47 + 15 * i + cell.spacingBetweenMatches.constant, cell.secondMatchGuestTeam.frame.size.width, 14)];
            goalLabel.textAlignment = NSTextAlignmentLeft;
            goalLabel.font = [UIFont systemFontOfSize:10];
            goalLabel.text = secondMatch.guestTeamScorers[i - 1];
            goalLabel.tag = 1;
            [cell.contentView addSubview:goalLabel];
        }
    }
    cell.userInteractionEnabled = NO;
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
    CGFloat hieght = _eurocupsContentSwitcher.selectedSegmentIndex == 1 ? 82 : 44;
    if([self showGoalsAtIndexPath:indexPath] == YES){
        if (_eurocupsContentSwitcher.selectedSegmentIndex == 1) {
            PlayoffsMatchScoreInfo *firstMatch = _playoffs[indexPath.section][indexPath.row][0];
            if (firstMatch.homeTeamScorers.count != 0 || firstMatch.guestTeamScorers.count != 0) {
                NSInteger multiplier = firstMatch.homeTeamScore > firstMatch.guestTeamScore ? firstMatch.homeTeamScorers.count : firstMatch.guestTeamScorers.count;
                hieght = hieght + 14 * multiplier; //chech first value!!!
            }
            PlayoffsMatchScoreInfo *secondMatch = _playoffs[indexPath.section][indexPath.row][1];
            if (secondMatch.homeTeamScorers.count != 0 || secondMatch.guestTeamScorers.count != 0) {
                NSInteger multiplier = secondMatch.homeTeamScore > secondMatch.guestTeamScore ? secondMatch.homeTeamScorers.count : secondMatch.guestTeamScorers.count;
                hieght = hieght + 14 * multiplier;
            }
        } else {
            MatchScoreInfo *match = _tours[indexPath.section][indexPath.row];
            if (match.homeTeamScorers.count != 0 || match.guestTeamScorers.count != 0) {
                NSInteger multiplier = match.homeTeamScore > match.guestTeamScore ? match.homeTeamScorers.count : match.guestTeamScorers.count;
                hieght = 33 + 15 * multiplier;
            }
        }
    }
    if(self.contentType == 2){
        hieght = 44;
    }
    return hieght;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.contentType == 0) {
        if (_isEurocups) {
            return !_teamsResults ? 0 : [_teamsResults[section] count];
        } else {
            return !_teamsResults ? 0 : _teamsResults.count;
        }
    } else if(self.contentType == 1){
        NSInteger numberOfRows = !_tours ? 0 : [_tours[section] count];
        if(_eurocupsContentSwitcher.selectedSegmentIndex == 1){
            numberOfRows = !_playoffs ? 0 : [_playoffs[section] count];
        }
        return numberOfRows;
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
    } else if(self.contentType == 1) {
        if(_eurocupsContentSwitcher.selectedSegmentIndex == 1){
            return _playoffs.count;
        } else {
            return _tours.count;
        }
    } else {
        return 1;
    }
}

+(NSString *)groupNameInSection:(NSInteger)section{
    NSArray *groupNames = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L"];
    return groupNames[section];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.goalsAreShowedAtIndexPathes addObject:indexPath];
    [_tableView reloadData];
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
    _contentType = 0;
    _goalsAreShowedAtIndexPathes = nil;
    if (switcher.selectedSegmentIndex == 0) {
        [_contentSwitcher insertSegmentWithTitle:@"Таблица" atIndex:0 animated:YES];
        [_tableView reloadData];
        _tableView.allowsSelection = YES;
        [_tableView scrollsToTop];
    } else {
        [_contentSwitcher removeSegmentAtIndex:0 animated:YES];
        if(!_playoffs){
            _tableView.hidden = YES;
            [_loadingActivity startAnimating];
            NSInteger tournament = 1;
            if ([_baseURL isEqualToString:@"champions-league"]) {
                tournament = 0;
            }
            [ContentController downloadAndParsePlayoffsForTournament:tournament completionHandler:^(NSMutableArray *stages) {
                _playoffs = stages;
                [_loadingActivity stopAnimating];
                _tableView.hidden = NO;
                _tableView.allowsSelection = YES;
                [_tableView reloadData];
            } error:^(NSError *error) {
                NSLog(@"%@", error.description);
            }];
        } else {
            [_tableView reloadData];
        }
    }
    [_contentSwitcher setSelectedSegmentIndex:0];
}

- (IBAction)switchContent:(id)sender {
    UISegmentedControl *controller = (UISegmentedControl *)sender;
    _contentType = controller.selectedSegmentIndex;
    if (self.contentType == 0) {
        if (!_teamsResults) {
            [self parseTable];
        }
        _tableView.allowsSelection = NO;
        [_tableView scrollsToTop];
        
    } else if(self.contentType == 1){
        if (!_tours) {
            [self parseCalendar];
        }
        _tableView.allowsSelection = YES;
        if (_tours.count > _currentTour) {
            NSIndexPath *nearestTourToPlay = [NSIndexPath indexPathForRow:0 inSection:_currentTour];
            [_tableView scrollToRowAtIndexPath:nearestTourToPlay atScrollPosition:(UITableViewScrollPositionTop) animated:NO];
        }
    } else if(self.contentType == 2){
        if (!_scorers) {
            [self parseScorers];
        }
        _tableView.allowsSelection = NO;
    }
    [_tableView reloadData];
}

-(void)parseTable{
    if (_isEurocups) {
        [ContentController dowloadAndParseTableAndCalendarForLeague:_baseURL completionHandler:^(NSMutableDictionary *info) {
            _teamsResults = [info objectForKey:@"groupsTable"];
            _tours = [info objectForKey:@"calendar"];
            [_loadingActivity stopAnimating];
            [_tableView reloadData];
            _tableView.hidden = NO;
        } error:^(NSError *error) {
            
        }];
    } else {
        [ContentController dowloadAndParseTableForLegue:_baseURL completionHandler:^(NSMutableArray *info) {
            _currentTour = [[info lastObject] integerValue];
            [info removeLastObject];
            _teamsResults = info;
            [_loadingActivity stopAnimating];
            [_tableView reloadData];
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

-(NSMutableArray *)goalsAreShowedAtIndexPathes{
    if(!_goalsAreShowedAtIndexPathes){
        _goalsAreShowedAtIndexPathes = [[NSMutableArray alloc] init];
    }
    return _goalsAreShowedAtIndexPathes;
}

-(BOOL)showGoalsAtIndexPath:(NSIndexPath *)indexPath{
    BOOL show = NO;
    for(NSIndexPath *toCheck in _goalsAreShowedAtIndexPathes){
        if([toCheck isEqual:indexPath]){
            show = YES;
        }
    }
    return show;
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
