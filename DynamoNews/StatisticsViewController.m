//
//  StatisticsViewController.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 01.10.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import "StatisticsViewController.h"
#import "TeamResults.h"
#import "ContentController.h"
#import "LoadingTableViewCell.h"
#import "MatchCenterTableViewCell.h"
#import "MatchScoreInfo.h"

@interface StatisticsViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *contentSwitcher;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *tours;
@property (strong, nonatomic) NSMutableArray *teamsResults;
@property (strong, nonatomic) NSMutableArray *scorers;
@property (nonatomic) NSInteger contentType;
@end

@implementation StatisticsViewController

#pragma mark - DataSource delegate TableView methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MatchCenterTableViewCell *cell;
    MatchScoreInfo *match = _tours[indexPath.section][indexPath.row];
    if (match.homeTeamScore == -1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NotPlayedMatch"];
    } else {
        if (match.homeTeamScore != match.guestTeamScore) {
            if (match.homeTeamScore < match.guestTeamScore) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"GuestTeamWon"];
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:@"HomeTeamWon"];
            }
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"EqualMatch"];
        }
        cell.score.text = [NSString stringWithFormat:@"%ld - %ld", (long)match.homeTeamScore, (long)match.guestTeamScore];
    }
    cell.leftTeam.text = match.homeTeam;
    cell.rightTeam.text = match.guestTeam;
    cell.date.text = match.date;
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *header;
    if ([_baseURL isEqualToString:@"/champions-league/"] || [_baseURL isEqualToString:@"/europa-league/"]) {
        header = [NSString stringWithFormat:@"Группа %@", [self groupNameInSection:section]];
    } else {
        header = [NSString stringWithFormat:@"%li-й тур",section + 1];
    }
    return header;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[_tours objectAtIndex:section] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_tours count];
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
    [self startingParsing];
//    [ContentController dowloadAndParseTableForLegue:_baseURL];
}

- (IBAction)switchContent:(id)sender {
    
}

-(void)startingParsing{
    if ([_baseURL isEqualToString:@"/champions-league/"] || [_baseURL isEqualToString:@"/europa-league/"]) {
        [ContentController dowloadAndParseTableAndCalendarForLeague:_baseURL completionHandler:^(NSMutableDictionary *info) {
            NSMutableDictionary *tableAndCalendar = info;
            _teamsResults = [tableAndCalendar objectForKey:@"groupsTable"];
            _tours = [tableAndCalendar objectForKey:@"calendar"];
            [_tableView reloadData];
        } error:^(NSError *error) {
            NSLog(@"%@", error.description);
        }];
    } else {
        [ContentController dowloadAndParseScheduleForLegue:_baseURL completionHandler:^(NSMutableArray *info) {
            _tours = info;
            [_tableView reloadData];
        } error:^(NSError *error) {
            NSLog(@"%@", error.description);
        }];
    }
}

@end
