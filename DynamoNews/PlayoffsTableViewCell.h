//
//  PlayoffsTableViewCell.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 25.03.15.
//  Copyright (c) 2015 AlPono.inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayoffsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *firstMatchHomeTeam;
@property (weak, nonatomic) IBOutlet UILabel *firstMatchGuestTeam;
@property (weak, nonatomic) IBOutlet UILabel *firstMatchScoreOrDate;
@property (weak, nonatomic) IBOutlet UILabel *secondMatchHomeTeam;
@property (weak, nonatomic) IBOutlet UILabel *secondMatchGuestTeam;
@property (weak, nonatomic) IBOutlet UILabel *secondMatchScoreOrDate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spacingBetweenMatches;

@end
