//
//  StartingViewController.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 20.08.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import "StartingViewController.h"
#import "NewsViewController.h"
#import "ContentController.h"

@implementation StartingViewController

-(void)viewDidLoad{
    ContentController *controller = [[ContentController alloc] initWithType:NEWS_TYPE];
    if ([controller loadNextPageUsingType:DOWNLOAD_TO_BOTTOM]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushMainView:) name:@"infoPrepared" object:nil];
    } else{
        [_loadingIndicator stopAnimating];
        _internetStatus.text = @"No internet connection";
    }
}

-(void)pushMainView:(NSNotification *)notification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_loadingIndicator stopAnimating];
    UITabBarController *tabBarCon = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarCon"];
    UINavigationController *newsNavigation = [tabBarCon.viewControllers objectAtIndex:0];
    NewsViewController *newsView = [newsNavigation.viewControllers objectAtIndex:0];
    newsView.content = notification.object;
    [self presentViewController:tabBarCon animated:YES completion:nil];
}
@end
