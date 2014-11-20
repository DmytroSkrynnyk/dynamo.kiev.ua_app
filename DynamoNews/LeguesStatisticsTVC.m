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
    _leagueBaseURLs = [NSArray arrayWithObjects:@"/ukraine/", @"/champions-league/",  @"/europa-league/", @"/england-premier-league/", @"/italy-Serie-A/", @"/spain-primera/", @"/germany-bundesliga/", @"/france-Ligue1/", @"/ukraine-under21/", @"/ukraine-first-league/", nil];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    StatisticsViewController *svc = (StatisticsViewController *)segue.destinationViewController;
    svc.baseURL = sender;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"Statistics" sender:[_leagueBaseURLs objectAtIndex:indexPath.row]];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}
@end
