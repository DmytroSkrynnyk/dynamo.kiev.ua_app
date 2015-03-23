//
//  MatchCenterTableViewCell.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 28.09.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MatchCenterTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *leftTeam;
@property (weak, nonatomic) IBOutlet UILabel *score;
@property (weak, nonatomic) IBOutlet UILabel *rightTeam;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivity;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scorePosition;

-(void)setLoadingCellState:(BOOL)isLoading;
@end
