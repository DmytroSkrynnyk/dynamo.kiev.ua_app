//
//  AppDelegate.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 19.07.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Reachability.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) NetworkStatus netStatus;
@property (strong, nonatomic) Reachability *internetReachability;

-(void)updateIntenetconnectionStatus:(Reachability*) curReach;

@end
