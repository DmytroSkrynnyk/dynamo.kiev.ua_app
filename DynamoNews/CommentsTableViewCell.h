//
//  CommentsTableViewCell.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 15.02.15.
//  Copyright (c) 2015 AlPono.inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicCommentsTableViewCell.h"

@interface CommentsTableViewCell : BasicCommentsTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *rating;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UILabel *date;

@end
