//
//  CommentsViewController.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 15.02.15.
//  Copyright (c) 2015 AlPono.inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArticleContent.h"

@interface CommentsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) ArticleContent *articleToShow;

-(void)prepareContent;
@end
