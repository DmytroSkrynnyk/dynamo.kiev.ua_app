//
//  BlogsViewController.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 04.09.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsViewController.h"
#import "ContentController.h"

@interface BlogsViewController : NewsViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) ContentController *footballBlogsContent;
@property (strong, nonatomic) ContentController *otherBlogsContent;
@property (weak, nonatomic) IBOutlet UISegmentedControl *blogsTypeSwitcher;
@end
