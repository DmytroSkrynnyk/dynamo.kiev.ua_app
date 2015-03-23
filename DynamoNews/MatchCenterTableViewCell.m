//
//  MatchCenterTableViewCell.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 28.09.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import "MatchCenterTableViewCell.h"

@implementation MatchCenterTableViewCell

-(void)prepareForReuse{
    [super prepareForReuse];
    if (self.tag == 1) {
        for (UIView *view in self.contentView.subviews) {
            if (view.tag == 1) {
                [view removeFromSuperview];
            }
        }
    }
    self.userInteractionEnabled = YES;
    [self setLoadingCellState:NO];
}

-(void)setLoadingCellState:(BOOL)isLoading{
    _leftTeam.hidden = isLoading;
    _rightTeam.hidden = isLoading;
    _score.hidden = isLoading;
    _date.hidden = isLoading;
    isLoading ? [_loadingActivity startAnimating] : [_loadingActivity stopAnimating];
}

@end
