//
//  TeamResults`TableViewCell.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 04.11.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeamResults_TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *position;
@property (weak, nonatomic) IBOutlet UILabel *teamName;
@property (weak, nonatomic) IBOutlet UILabel *teamCity;
@property (weak, nonatomic) IBOutlet UILabel *gamesPlayed;
@property (weak, nonatomic) IBOutlet UILabel *gamesWon;
@property (weak, nonatomic) IBOutlet UILabel *gamesTied;
@property (weak, nonatomic) IBOutlet UILabel *gamesLoosed;
@property (weak, nonatomic) IBOutlet UILabel *goalsDifference;
@property (weak, nonatomic) IBOutlet UILabel *points;

@end
