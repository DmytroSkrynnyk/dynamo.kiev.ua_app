//
//  PlayerGoalsStatsTableViewCell.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 10.02.15.
//  Copyright (c) 2015 AlPono.inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerGoalsStatsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *team;
@property (weak, nonatomic) IBOutlet UILabel *goalsScored;
@property (weak, nonatomic) IBOutlet UILabel *homeGoals;
@property (weak, nonatomic) IBOutlet UILabel *guestGoals;
@property (weak, nonatomic) IBOutlet UILabel *penaltyScored;
@property (weak, nonatomic) IBOutlet UILabel *position;

@end
