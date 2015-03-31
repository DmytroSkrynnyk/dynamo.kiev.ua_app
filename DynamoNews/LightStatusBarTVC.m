//
//  LightStatusBarTVC.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 30.03.15.
//  Copyright (c) 2015 AlPono.inc. All rights reserved.
//

#import "LightStatusBarTVC.h"

@interface LightStatusBarTVC ()

@end

@implementation LightStatusBarTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
