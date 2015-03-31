//
//  LeguesStatisticsTVC.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 30.09.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import "LeguesStatisticsTVC.h"
#import "StatisticsViewController.h"

@interface LeguesStatisticsTVC ()
@property (strong, nonatomic) NSArray *leagueBaseURLs;
@end

@implementation LeguesStatisticsTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _leagueBaseURLs = @[@"ukraine", @"champions-league",  @"europa-league", @"england-premier-league", @"italy-Serie-A", @"spain-primera", @"germany-bundesliga", @"france-Ligue1", @"ukraine-under21", @"ukraine-first-league"];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    StatisticsViewController *svc = (StatisticsViewController *)segue.destinationViewController;
    svc.baseURL = sender;
    if ([sender isEqualToString:@"champions-league"] || [sender isEqualToString:@"europa-league"]) {
        svc.isEurocups = YES;
    }

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"Statistics" sender:[_leagueBaseURLs objectAtIndex:indexPath.row]];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}
@end
