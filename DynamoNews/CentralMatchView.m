//
//  CentralMatchView.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 22.03.15.
//  Copyright (c) 2015 AlPono.inc. All rights reserved.
//

#import "CentralMatchView.h"
#import "MatchScoreInfo.h"

@implementation CentralMatchView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)updateCentralMatch:(MatchScoreInfo *)match{
    if (match) {
        _homeTeamGoalsScored = match.homeTeamScore;
        _guestTeamGoalsScored = match.guestTeamScore;
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
        NSInteger multiplier;
        if (_homeTeamGoalsScored == -1) {
            multiplier = 0;
        } else {
            multiplier = _homeTeamGoalsScored > _guestTeamGoalsScored ? _homeTeamGoalsScored : _guestTeamGoalsScored;
        }
        [_centralMatchLoadingActivity stopAnimating];
        _centralMatchHieght.constant = 99 + 15 * multiplier;
        [self hideCentralMatchView:NO];
    } else {
        [_centralMatchLoadingActivity stopAnimating];
        _centralMatchHieght.constant = 1;
    }
}

-(void)hideCentralMatchView:(BOOL)hide{
    NSArray *matchSubviews =  self.subviews;
    for (UIView *view in matchSubviews) {
        if ([view isKindOfClass:[UIActivityIndicatorView class]]) {
            UIActivityIndicatorView *activity = (UIActivityIndicatorView *) view;
            activity.hidden = !hide;
        } else {
            view.hidden = hide;
        }
        
    }
}

-(void)addHomeTeamScorersLabel:(NSArray *)scorers{
    if (_homeTeamGoalsScored > 0) {
        NSInteger yPosition = 80;
        for (NSString *scorer in scorers) {
            CGRect scrorerLabelPosition = CGRectMake(0, yPosition, self.bounds.size.width / 2 - 33, 15);
            UILabel *scorerLabel = [[UILabel alloc] initWithFrame:scrorerLabelPosition];
            scorerLabel.text = scorer;
            scorerLabel.textAlignment = NSTextAlignmentRight;
            scorerLabel.font = [UIFont systemFontOfSize:12.0];
            [self addSubview:scorerLabel];
            yPosition += 15;
        }
    }
}

-(void)addGuestTeamScorersLabel:(NSArray *)scorers{
    if (_guestTeamGoalsScored > 0) {
        NSInteger yPosition = 80;
        for (NSString *scorer in scorers) {
            CGRect scrorerLabelPosition = CGRectMake(self.bounds.size.width / 2 + 33, yPosition, 111, 15);
            UILabel *scorerLabel = [[UILabel alloc] initWithFrame:scrorerLabelPosition];
            scorerLabel.text = scorer;
            scorerLabel.font = [UIFont systemFontOfSize:12.0];
            [self addSubview:scorerLabel];
            yPosition += 15;
        }
    }
}
@end
