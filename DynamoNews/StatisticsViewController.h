//
//  StatisticsViewController.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 01.10.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatisticsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSString *baseURL;
@property (nonatomic) BOOL isEurocups;
@end
