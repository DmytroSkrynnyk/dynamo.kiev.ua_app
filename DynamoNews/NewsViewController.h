//
//  ViewController.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 19.07.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContentController;
@interface NewsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) ContentController *content;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

- (void)stopRefresh;
- (void)reloadContent;
- (void)updateUI;
- (void)updateVisibles;

@end
