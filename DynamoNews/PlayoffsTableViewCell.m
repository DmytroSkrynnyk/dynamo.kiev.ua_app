//
//  PlayoffsTableViewCell.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 25.03.15.
//  Copyright (c) 2015 AlPono.inc. All rights reserved.
//

#import "PlayoffsTableViewCell.h"

@implementation PlayoffsTableViewCell

-(void)prepareForReuse{
    self.firstMatchHomeTeam.textColor = [UIColor blackColor];
    self.firstMatchGuestTeam.textColor = [UIColor blackColor];
    self.secondMatchHomeTeam.textColor = [UIColor blackColor];
    self.secondMatchGuestTeam.textColor = [UIColor blackColor];
    self.spacingBetweenMatches.constant = 4;
    self.userInteractionEnabled = NO;
    for(UIView *view in self.contentView.subviews){
        if(view.tag == 1){
            [view removeFromSuperview];
        }
    }
}

@end
