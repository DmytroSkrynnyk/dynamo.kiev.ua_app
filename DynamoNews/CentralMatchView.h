//
//  CentralMatchView.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 22.03.15.
//  Copyright (c) 2015 AlPono.inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MatchScoreInfo;

@interface CentralMatchView : UIView
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *homeTeam;
@property (weak, nonatomic) IBOutlet UILabel *homeTeamCity;
@property (weak, nonatomic) IBOutlet UILabel *guestTeam;
@property (weak, nonatomic) IBOutlet UILabel *guestTeamCity;
@property (weak, nonatomic) IBOutlet UILabel *score;
@property (weak, nonatomic) IBOutlet UILabel *tournament;
@property (nonatomic) NSInteger homeTeamGoalsScored;
@property (nonatomic) NSInteger guestTeamGoalsScored;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *centralMatchLoadingActivity;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centralMatchHieght;
@property (nonatomic) BOOL isCentralMatchLoaded;

-(void)updateCentralMatch:(MatchScoreInfo *)match;
-(void)hideCentralMatchView:(BOOL)hide;
-(void)addHomeTeamScorersLabel:(NSArray *)scorers;
-(void)addGuestTeamScorersLabel:(NSArray *)scorers;

@end
