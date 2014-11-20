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
@property (weak, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation MatchCenterTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [ContentController dowloadAndParseMatchCenterPageWithCompletionHandler:^(NSMutableArray *info) {
        _content = info;
        [_tableView reloadData];
    } error:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
    [ContentController dowloadAndParseMainPageWithCompletionHandler:^(MatchScoreInfo *match) {
        [self updateCentralMatch:match];
    } error:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
  UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(reloadContent) forControlEvents:UIControlEventValueChanged];
}
-(void)updateCentralMatch:(MatchScoreInfo *)match{
    if (match) {
//        match.homeTeamScorers =  [NSArray arrayWithObjects:@"10' ffffdfsfsdjjjjjjjjj", @"22'fwsdfsjdf", @"33' fdffwfetrhrthrt", nil];
        _homeTeamGoalsScored = match.homeTeamScore;
        _guestTeamGoalsScored = 0;//match.guestTeamScore;
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
    }
//    CGRect noGoalsMatchViewFrame = _matchView.frame;
//    noGoalsMatchViewFrame.size.height = 50;
//    [_matchView setFrame:noGoalsMatchViewFrame];
    [self hideCentralMatchView:NO];
    [self noGoalsCentralMatchUIposition];
}
-(void)hideCentralMatchView:(BOOL)hide{
    NSArray *matchSubviews =  self.matchView.subviews;
    for (UIView *view in matchSubviews) {
        if ([view isKindOfClass:[UIActivityIndicatorView class]]) {
            UIActivityIndicatorView *activity =  (UIActivityIndicatorView *)view;
            activity.hidden = !hide;
        } else {
            view.hidden = hide;
        }
    }
}

-(void)addHomeTeamScorersLabel:(NSArray *)scorers{
    if (_homeTeamGoalsScored > 0) {
        NSInteger yPosition = 79;
        for (NSString *scorer in scorers) {
            CGRect scrorerLabelPosition = CGRectMake(8, yPosition, 111, 21);
            UILabel *scorerLabel = [[UILabel alloc] initWithFrame:scrorerLabelPosition];
            scorerLabel.text = scorer;
            scorerLabel.textAlignment = NSTextAlignmentRight;
            scorerLabel.font = [UIFont fontWithName:@"System" size:5];
            [_matchView addSubview:scorerLabel];
            yPosition += 16;
        }
    }
}

-(void)addGuestTeamScorersLabel:(NSArray *)scorers{
    if (_guestTeamGoalsScored > 0) {
        NSInteger yPosition = 79;
        for (NSString *scorer in scorers) {
            CGRect scrorerLabelPosition = CGRectMake(201, yPosition, 111, 21);
            UILabel *scorerLabel = [[UILabel alloc] initWithFrame:scrorerLabelPosition];
            scorerLabel.text = scorer;
            scorerLabel.font = [UIFont fontWithName:scorerLabel.font.familyName size:5];
            [_matchView addSubview:scorerLabel];
            yPosition += 16;
        }
    }
}


-(void)noGoalsCentralMatchUIposition{
    if (_homeTeamGoalsScored < 1 && _guestTeamGoalsScored < 1) {
        CGRect noGoalsFrame = _date.frame;
        noGoalsFrame.origin.y = 80;
        [_date setFrame:noGoalsFrame];
        noGoalsFrame = _matchView.frame;
        noGoalsFrame.size.height = 180;
        [_matchView setFrame:noGoalsFrame];
    }

}
-(void)reloadContent{
    [ContentController dowloadAndParseMatchCenterPageWithCompletionHandler:^(NSMutableArray *info) {
        _content = info;
        [_tableView reloadData];
    } error:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
    [ContentController dowloadAndParseMainPageWithCompletionHandler:^(MatchScoreInfo *match) {
        [self updateCentralMatch:match];
    } error:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}
-(void)infoPrepared:(NSNotification *)info{
        _content = info.object;
        [_tableView reloadData];
    [self.refreshControl endRefreshing];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_content count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_content[section] count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    MatchScoreInfo *firstMatchInSection = _content[0];
    return firstMatchInSection.tournament;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_content.count == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"No Matches"];
        return cell;
    } else {
        MatchScoreInfo *match = _content[indexPath.section][indexPath.row];
        MatchCenterTableViewCell *cell;
        if (match.homeTeamScore == -1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"EqualMatch"];
            cell.score.text = @"- : -";
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
}

@end
